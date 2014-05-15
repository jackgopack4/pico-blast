/**
 *   File: ScanSubject.cpp
 *   
 *   This module is a simple command line utility to independently process the
 *   hardware search of a BLASTn search using word length 8.
 *   
 *   The file sets up two streams; one to send the database through and one to
 *   continuously receive results from the FPGA. Any time there are hits in the
 *   query of up to 4096 length, a snapshot of the 4096 bases are sent (1 for
 *   hit, 0 for miss) in every index. In addition, the number of matches in
 *   that set of bases will be sent first, so that the software can see if it's
 *   gotten all matches and skip out a little more quickly of the loop.
 *   The results are returned as an integer value of the number of hits found,
 *   in addition to being stored inside a union, or two-slot array with query
 *   and database position for each hit. As the absolute query location is
 *   indicated as well as the relative database location, these two values are
 *   easily computed in software.
 *
 *   Parameters: 
 *   const BLAST_SequenceBlk * subject: database struct pointer
 *   const BLAST_SequenceBlk * query:   query struct pointer
 *   int max_hits: maximum number of hits to return (not implemented yet)
 *   int * scan_range: Two-item array with start position and end position. On
 *                      exit, scan_range[0] is updated with stopping position
 */

#include <stdio.h>
#include <string.h>
#include <picodrv.h>
#include <pico_errors.h>

#define FULL_128_BITS 16
#define WRITESTREAM false
#define READSTREAM true
#define COMPRESSIONRATIO 4

#define QUERYADDRESS 0x0
#define READYADDRESS 0x10
#define QUERYSUBJECTLENGTH 0x4000
#define NUMRESULTSADDRESS 0x4000
#define SUBJECTINDEXADDRESS 0x3000


/** Structure holding a pair of offsets. Used for storing offsets for the
 * initial seeds. In most programs the offsets are query offset and subject 
 * offset of an initial word match. For PHI BLAST, the offsets are start and 
 * end of the pattern occurrence in subject, with no query information, 
 * because all pattern occurrences in subjects are aligned to all pattern 
 * occurrences in query.
 */
typedef union BlastOffsetPair {
  struct {
    int q_off;  /**< Query offset */
    int s_off;  /**< Subject offset */
  } qs_offsets;     /**< Query/subject offset pair */
  struct {
    int s_start;/**< Start offset of pattern in subject */
    int s_end;  /**< End offset of pattern in subject */
  } phi_offsets;    /**< Pattern offsets in subject (PHI BLAST only) */
} BlastOffsetPair;

/** A structure containing two integers, used e.g. for locations for the 
 * lookup table.
 */
typedef struct SSeqRange {
  int left;  /**< left endpoint of range (zero based) */
  int right;  /**< right endpoint of range (zero based) */
} SSeqRange;

typedef struct BlastSeqLoc {
  struct BlastSeqLoc *next;  /**< next in linked list */
  SSeqRange *ssr;            /**< location data on the sequence. */
} BlastSeqLoc;


typedef struct BlastMaskLoc {
  /** Total size of the BlastSeqLoc array below. This is always the number 
      of queries times the number of contexts. Note that in the case of 
      translated query searches, these locations must be provided in protein 
      coordinates to BLAST_MainSetUp.
      @sa BLAST_GetNumberOfContexts 
      @sa BlastMaskLocDNAToProtein
  */
  int total_size; 

  /** Array of masked locations. 
      Every query is allocated the number of contexts associated with the 
      program. In the case of nucleotide searches, the strand(s) to search 
      dictatate which elements of the array for a given query are filled. For 
      translated searches, this should also be the same (by design) but the 
      C toolkit API does NOT implement this, it rather fills all elements 
      for all queries with masked locations in protein coordinates (if any). 
      The C++ API does follow the convention which populates each element, only
      if so dictated by the strand(s) to search for each query.
      @sa BLAST_GetNumberOfContexts
  */
  BlastSeqLoc** seqloc_array; 
} BlastMaskLoc;

/** Define the possible subject masking types */
typedef enum ESubjectMaskingType {
  eNoSubjMasking,
  eSoftSubjMasking,
  eHardSubjMasking
} ESubjectMaskingType;



/** Structure to hold a sequence. */
typedef struct BLAST_SequenceBlk {
  int* sequence; /**< Sequence used for search (could be translation). */
  int* sequence_start; /**< Start of sequence, usually one byte before 
			  sequence as that byte is a NULL sentinel byte.*/
  int length;         /**< Length of sequence. */
  int frame; /**< Frame of the query, needed for translated searches */
  int subject_strand; /**< Strand of the subject sequence for translated searches. 
			 Uses the same values as ENa_strand. */
  int oid; /**< The ordinal id of the current sequence */
  bool sequence_allocated; /**< TRUE if memory has been allocated for 
			      sequence */
  bool sequence_start_allocated; /**< TRUE if memory has been allocated 
				    for sequence_start */
  int* sequence_start_nomask; /**< Query sequence without masking. */
  int* sequence_nomask; /**< Start of query sequence without masking. */
  bool nomask_allocated; /**< If false the two above are just pointers to
			    sequence and sequence_start. */
  int* oof_sequence; /**< Mixed-frame protein representation of a
			nucleotide sequence for out-of-frame alignment */
  bool oof_sequence_allocated; /**< TRUE if memory has been allocated 
				  for oof_sequence */
  int* compressed_nuc_seq; /**< 4-to-1 compressed version of sequence */
  int* compressed_nuc_seq_start; /**< start of compressed_nuc_seq */
  BlastMaskLoc* lcase_mask; /**< Locations to be masked from operations on 
			       this sequence: lookup table for query; 
			       scanning for subject. */
  bool lcase_mask_allocated; /**< TRUE if memory has been allocated for 
				lcase_mask */
  int chunk;  /**< Used for indexing only: the chunk number within the 
		 subject sequence. */
  int *gen_code_string;  /**< for nucleotide subject sequences (tblast[nx]),
			    the genetic code used to create a translated
			    protein sequence (NULL if not applicable). This
			    field is NOT owned by this data structure, it's
			    owned by the genetic code singleton. 
			    @sa gencode_singleton.h
			 */
  /* BEGIN: Data members needed for masking subjects from a BLAST database */
  SSeqRange* seq_ranges;   /**< Ranges of the sequence to search */
  int num_seq_ranges;    /**< Number of elements in seq_ranges */
  bool seq_ranges_allocated;   /**< TRUE if memory has been allocated for
				  seq_ranges */
  ESubjectMaskingType mask_type;          /**< type of subject masking */
  /* END: Data members needed for masking subjects from a BLAST database */

  int bases_offset; /* Bases offset in first byte for SRA seq */

} BLAST_SequenceBlk;

/** Types of the lookup table */
typedef enum {
  eMBLookupTable,  /**< megablast lookup table (includes both
		      contiguous and discontiguous megablast) */
  eSmallNaLookupTable,  /**< lookup table for blastn with small query*/
  eNaLookupTable,  /**< blastn lookup table */
  eAaLookupTable,  /**< standard protein (blastp) lookup table */
  eCompressedAaLookupTable,  /**< compressed alphabet (blastp) lookup table */
  ePhiLookupTable,  /**< protein lookup table specialized for phi-blast */
  ePhiNaLookupTable,  /**< nucleotide lookup table for phi-blast */
  eRPSLookupTable, /**< RPS lookup table (rpsblast and rpstblastn) */
  eIndexedMBLookupTable, /**< use database index as a lookup structure */
  eMixedMBLookupTable /**< use when some volumes are searched with index and 
			 some are not */
} ELookupTableType;

typedef struct LookupTableWrap {
  ELookupTableType lut_type; /**< What kind of a lookup table it is? */
  void* lut; /**< Pointer to the actual lookup table structure */
  void* read_indexed_db; /**< function used to retrieve hits
			    from an indexed database */
  void* check_index_oid; /**< function used to check if seeds
			    for a given oid are present */
  void * end_search_indication; /**< function used to report that
				   a thread is done iterating over
				   the database in preliminary
				   search */
  void* lookup_callback;    /**< function used to look up an
			       index->q_off pair */
} LookupTableWrap;


// Structure defined for streaming data in threads
typedef struct StreamInfo {
  pthread_t       thread;
  PicoDrv*        pico;
  int             stream;
} StreamInfo_t;


// Structure for holding arguments that need to be passed to two threads
typedef struct args {
  StreamInfo_t* streaminfo;
  const BLAST_SequenceBlk* subject;
  const BLAST_SequenceBlk* query;
  int max_hits;
  BlastOffsetPair * __restrict__ offset_pairs;
} args_t;

/*************************************************************************
 // Thread writestream
 // This thread streams data to FPGA which is processed by FPGA for Match
 // The Arguments to this thread is structure of type StreamInfo which holds
 // all the information regarding the setting up of stream
 // The second argument is Subject Sequence which needs to be streamed
 // This stream works in parallel with receive stream
 *************************************************************************/


void *writestream(void * arg){
  // Writing the database in the FPGA
  args_t *a = (args_t *) arg;
  StreamInfo_t *info = a->streaminfo;
  PicoDrv* pico = a->streaminfo->pico;
  const BLAST_SequenceBlk *subject = a->subject;
  pico->WriteStream(info->stream,subject->sequence ,subject->length*4); 
  // Writing Thread complete
}


/****************************************************************************
 // Thread receivestream
 // This thread receives the procssed hit from the FPA
 // In this thread using pico bus current number of hits is continously read
 // If the number of hits have increased then we read the subject counter value
 // and 4096 bits found_hit register
 // Then we process the found hit register to calculate the offset and store in
 // object of type BlastOffsetpair
 ****************************************************************************/

void *receivestream(void *arg){
  // Receiving the hits database in the FPGA
  args_t *a = (args_t *)arg;
  StreamInfo_t *info = a->streaminfo; // Stream information
  PicoDrv* pico = a->streaminfo->pico; // Object of type pico
  const BLAST_SequenceBlk *subject = a->subject; // Subject Sequence
  const BLAST_SequenceBlk *query = a->query; // Query Sequence
  int current_database_index=0; // Initializing the value of current database index to 0
  int total_hits=0;          // Total number of hits, updated from FPGA memory
  int temp[8]; // this is temporary variable used to process the hits
  int current_hits; // Current number of hits that  has been already processed
  int numHitsBuffer[4]; //It reads the value of total number of hits genearted by FPA using Pico Bus
  int max_hits = a->max_hits; // Maximum number of hits supported
  int tempResults[4]; // It stores the value of subject counter read using Pico Bus when a hit is identified
  char queryHitsBuffer[512]; // 4096 bit buffer in which we read the value from FPGA 
  int offset_pairs_index = 0;// counter to keep track of blast offset pairs
  int current_query_index;// stores the value of current query index 
  BlastOffsetPair * __restrict__ offset_pairs = (BlastOffsetPair *)malloc(sizeof(BlastOffsetPair)*max_hits);

  while((current_database_index < (subject->length*16+query->length*16)) && (total_hits < max_hits)) {
    // our current database index is less than the length of the given database
    // and our total number of hits received is less than the maximum hits value given
    pico->ReadDeviceAbsolute(NUMRESULTSADDRESS, numHitsBuffer, 16);
    if(total_hits < numHitsBuffer[0]) {
      // the total hits we have processed in software is less than those found in hardware so far
      // so we stream in the 4096-bit array with the hits contained in it
      // first, take the index of the database (subject) to be able to calculate offset
      pico->ReadDeviceAbsolute(SUBJECTINDEXADDRESS, tempResults, 16);
      current_database_index = tempResults[0];
      total_hits = numHitsBuffer[0];
      // next, read 4096 bits (or 512 bytes) from the results_stream
      pico->ReadStream(info->stream, queryHitsBuffer, 512);


      // then, loop through the buffer containing that 4096 bit array
      // and if a bit is 1, store the result in offset_pairs
      // Processing the buffer eceived to grab the index
      for(int i = 0; i<512; i++) {
	int test;
	current_query_index = i*8;
	if(queryHitsBuffer[i]>0) {
	  //       // put the query index into the offset_pairs
	  temp[0] = queryHitsBuffer[i] & 0x01; // Storing the first bit
	  temp[1] = queryHitsBuffer[i] & 0x02; // Storing the second bit
	  temp[2] = queryHitsBuffer[i] & 0x04; // Storing the third bit
	  temp[3] = queryHitsBuffer[i] & 0x08; // Storing the fourth bit
	  temp[4] = queryHitsBuffer[i] & 0x10; // Storing the fifth bit
	  temp[5] = queryHitsBuffer[i] & 0x20; // Storing the sixth bit
	  temp[6] = queryHitsBuffer[i] & 0x40; // Storing the seventh bit
	  temp[7] = queryHitsBuffer[i] & 0x80; // Storing the eighth bit
	  for(int j=0;j<8;j++){
	    if(temp[j]>0){
	      offset_pairs[offset_pairs_index].qs_offsets.q_off = current_query_index+j;
	      if(current_database_index<=(subject->length*16)){
		test = current_database_index+(query->length*16-(current_query_index+j));
		offset_pairs[offset_pairs_index].qs_offsets.s_off = current_database_index+(query->length*16-(current_query_index+j));
	      }else
		{
		  test = (subject->length*16-(query->length*16))+(current_query_index+j);
		  offset_pairs[offset_pairs_index].qs_offsets.s_off = (subject->length*16-(query->length*16))+(current_query_index+j);
		}
	      offset_pairs_index++;
	    }
	  }
	}
      }
    }

  }

}

static int s_BlastNaScanSubject_8_4(const LookupTableWrap * lookup_wrap,
				    const BLAST_SequenceBlk * subject,
				    const BLAST_SequenceBlk *query,
				    BlastOffsetPair * __restrict__ offset_pairs,
				    int max_hits, int * scan_range) {
  int         err, i, j, stream,stream_result;
  unsigned int  buf[1024], u32, addr,indexBuffer[4];
  char        ibuf[1024];
  PicoDrv    *pico;
  const char* bitFileName;
  
  int *s = subject->sequence; // Pointer for current address of database index
  int *abs_start, *s_end; // Pointer for address of absolute start, end
  // s_end not yet implemented yet
  int word_length = 8;     // Number for word length. Plan to take as input in
  // the future and support more word lengths in FPGA


  int count;                            // Used for incrementing
  int queryLength = query->length;     // Length parameter for query.
  int subjectLength = subject->length;
  int queryLengthBytes = queryLength*4;
  int subjectLengthBytes = subjectLength*4;

  int current_query_index;
  int database_stream = 1;
  int results_stream  = 2;
  int length[2]={subject->length,query->length};
  pthread_t threads[4]; 

  // specify the .bit file name on the command line
  bitFileName = "../firmware/m505lx325.fwproj";
  
  // The RunBitFile function will locate a Pico card that can run the given bit
  // file, and is not already opened in exclusive-access mode by another
  // program. It requests exclusive access to the Pico card so no other programs
  // will try to reuse the card and interfere with us.

  // Loading FPGA with bitFileName
  err = RunBitFile(bitFileName, &pico);
  if(err < 0) {
    fprintf(stderr, "RunBitFile error: %s\n", 
	    PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
    exit(1);
  }


  //Begin writing query length and subject length to register in FPGA
  pico->WriteDeviceAbsolute(QUERYSUBJECTLENGTH,length , FULL_128_BITS);
  // Done writing query to register in FPGA 

  abs_start = subject->sequence;
  s = abs_start + scan_range[0] / COMPRESSIONRATIO;     // 4 bases per byte
  s_end = abs_start + scan_range[1] / COMPRESSIONRATIO;
  // Write the query of given length to an address in the FPGA
  current_query_index = 0;
  int cntr=0;

  // Begin writing query to register in FPGA 

  while(current_query_index < queryLengthBytes) {
    //Writing query to register in FPGA 
    pico->WriteDeviceAbsolute(QUERYADDRESS, query->sequence+cntr, FULL_128_BITS);
    current_query_index+=FULL_128_BITS;
    cntr=cntr+4;
  }
  //Done writing query and subject length to register in FPGA ;




  // database goes out via stream #1
  // Opening stream to Database Shift Register
  stream = pico->CreateStream(database_stream);
  if(stream < 0) {
    fprintf(stderr, "couldn't open stream 1! (return code: %i)\n", stream);
    exit(1);
  }
  
  // open stream for results on stream #2
  // Opening stream from Result stream\n"
  stream_result = pico->CreateStream(results_stream);
  if(stream_result < 0) {
    fprintf(stderr, "couldn't open stream 2! (return code: %i)\n", stream_result);
    exit(1);
  }
  //  // Stream out the database in compressed format 


  args_t *a=(args_t *)malloc(4*sizeof(args_t));
  StreamInfo_t *streaminfo = (StreamInfo_t *)malloc(sizeof(StreamInfo_t));
  streaminfo->pico = pico;
  streaminfo->stream = database_stream;
  BLAST_SequenceBlk * sub = (BLAST_SequenceBlk *)malloc(sizeof(BLAST_SequenceBlk));
  sub->sequence = subject->sequence ;
  sub->length = subject->length; 
  a[0].streaminfo = streaminfo;
  a[0].subject = sub;


  StreamInfo_t *rcvstreaminfo = (StreamInfo_t *)malloc(sizeof(StreamInfo_t));
  rcvstreaminfo->pico = pico;
  rcvstreaminfo->stream = results_stream;
  a[1].streaminfo = rcvstreaminfo;
  a[1].max_hits = max_hits;
  a[1].subject = sub;
  a[1].query = query;
  a[1].offset_pairs = offset_pairs;
 
  

  err = pthread_create(&threads[0], NULL, writestream, (void *) &a[0]);
  if (err != 0){
    fprintf(stderr, "Write Thread creation error: %d\n", err);
    return EXIT_FAILURE;
  }


  err = pthread_create(&threads[1], NULL, receivestream, (void *) &a[1]);
  if (err != 0){
    fprintf(stderr, "Read Thread creation error: %d\n", err);
    return EXIT_FAILURE;
  }
  
  return 1000;
}

/******************************************************************************
Main Function : To generate Subject and Query Sequence and call the function s_BlastNaScanSubject
******************************************************************************/


int main(int argc,char **argv) {
  LookupTableWrap * lookup;
  BLAST_SequenceBlk * subj;
  BLAST_SequenceBlk *query;
  int query_len,seq_len;
  subj = (BLAST_SequenceBlk *)malloc(sizeof(BLAST_SequenceBlk));
  query = (BLAST_SequenceBlk *)malloc(sizeof(BLAST_SequenceBlk));
  BlastOffsetPair * __restrict__ offset;
  int max = 1000;
  int range[2];
  range[0] = 0;
  range[1] = 100;
  int i = 0;
  subj->sequence=(int *)malloc(sizeof(int)*60); 
  query->sequence=(int *)malloc(sizeof(int)*40); 
  while(i<60) {
    subj->sequence[i] = rand();
    i++;
  } 
  i=0;
  while(i<40) {
    query->sequence[i] = rand();
    i++;
  }
  query->length=40;
  subj->length=60;
  
  int results = s_BlastNaScanSubject_8_4(lookup, subj,query,offset,max,range);
  sleep(180);
  return 0;
  
}


