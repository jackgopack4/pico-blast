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
#define NUMRESULTSADDRESS 0x20
#define SUBJECTINDEXADDRESS 0x30


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


static int s_BlastNaScanSubject_8_4(const LookupTableWrap * lookup_wrap,
                                     const BLAST_SequenceBlk * subject,
                                     BlastOffsetPair * __restrict__ offset_pairs,
                                     int max_hits, int * scan_range) {
  int         err, i, j, stream;
  unsigned int  buf[1024], u32, addr, numHitsBuffer[4],indexBuffer[4];
  char        ibuf[1024];
  PicoDrv    *pico;
  const char* bitFileName;
  
  BLAST_SequenceBlk *query;
  query = (BLAST_SequenceBlk *)malloc(sizeof(BLAST_SequenceBlk));
  int a[]={1,45,77,34};
  query->sequence = a;

  int *s = subject->sequence; // Pointer for current address of database index
  int *abs_start, *s_end; // Pointer for address of absolute start, end
                            // s_end not yet implemented yet
  int total_hits;          // Total number of hits, updated from FPGA memory
  int current_hits;
  int word_length = 8;     // Number for word length. Plan to take as input in
                            // the future and support more word lengths in FPGA

  int *q = query->sequence;

  int count;                            // Used for incrementing
  int queryLength = query->length;     // Length parameter for query.
  int subjectLength = subject->length;
  int queryLengthBytes = queryLength / 4;
  int subjectLengthBytes = subjectLength / 4;
  int tempResults[FULL_128_BITS];
  
  int current_query_index;
  int current_database_index;
  
  int database_stream = 1;
  int results_stream  = 2;

  // specify the .bit file name on the command line
  bitFileName = "../firmware/m505lx325.fwproj";
  
  // The RunBitFile function will locate a Pico card that can run the given bit
  // file, and is not already opened in exclusive-access mode by another
  // program. It requests exclusive access to the Pico card so no other programs
  // will try to reuse the card and interfere with us.
  printf("Loading FPGA with '%s' ...\n", bitFileName);
  err = RunBitFile(bitFileName, &pico);
  if(err < 0) {
    fprintf(stderr, "RunBitFile error: %s\n", 
              PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
    exit(1);
  }
  
  // database goes out via stream #1
  printf("Opening stream to Database Shift Register\n");
  stream = pico->CreateStream(database_stream);
  if(stream < 0) {
    fprintf(stderr, "couldn't open stream 1! (return code: %i)\n", stream);
    exit(1);
  }
  
  // open stream for results on stream #2
  printf("Opening stream from Result stream\n");
  stream = pico->CreateStream(results_stream);
  if(stream < 0) {
    fprintf(stderr, "couldn't open stream 2! (return code: %i)\n", stream);
    exit(1);
  }
  
  abs_start = subject->sequence;
  printf("Absolute start address of subject sequence is: %p \n", abs_start);
  s = abs_start + scan_range[0] / COMPRESSIONRATIO;     // 4 bases per byte
  s_end = abs_start + scan_range[1] / COMPRESSIONRATIO;
  q = query->sequence;
  // Write the query of given length to an address in the FPGA
  current_query_index = 0;
  printf("Begin writing query to register in FPGA \n");
  while(current_query_index < queryLengthBytes) {
    pico->WriteDeviceAbsolute(QUERYADDRESS, abs_start, FULL_128_BITS);
    current_query_index+=FULL_128_BITS;
  }
//  // Stream out the database in compressed format 
  current_database_index = 0;
  unsigned int database_stream_length = (uint32_t)(scan_range[1] - scan_range[0])*4;
  unsigned int database_base_length = database_stream_length / 2;
  pico->WriteStream(database_stream, s,database_stream_length); 
        printf("\nDone with Sending data - Now in Receive Mode");
  
  while((current_database_index < database_base_length) // Haven't exceeded database width
             && (total_hits < max_hits)) { // Also haven't exceeded max desired hits
        printf("\n Receive Mode : Receiving Data Please be patient");
    if(pico->ReadDeviceAbsolute(READYADDRESS, tempResults, 16) & 0x1) { // new data ready
      pico->ReadDeviceAbsolute(NUMRESULTSADDRESS, numHitsBuffer, 16); // read # of results
      pico->ReadDeviceAbsolute(SUBJECTINDEXADDRESS,indexBuffer, 16); // read subject addr 
      while(current_hits < numHitsBuffer[0]) { // still more hits in this frame of the query
        pico->ReadStream(results_stream, tempResults, 16); // Receive 128-bit query hit
        int sampleResult = tempResults[0] << 4 + tempResults[1] >> 4;
        printf("First result at index: %08x", sampleResult);
        // Read the query index from the 12-bit numbers saved in tempResults
        // Then, store each one into offset_pairs
        // Calculating the subject index as well as the query index
        // offset_pairs[total_hits].qs_offsets.q_off = tempResults[
      }
    }
  }
  return 1000;
}


int main(int argc,char **argv) {
  LookupTableWrap * lookup;
  BLAST_SequenceBlk * subj;
  subj = (BLAST_SequenceBlk *)malloc(sizeof(BLAST_SequenceBlk));
  BlastOffsetPair * __restrict__ offset;
  int max = 1000;
  int range[2];
  range[0] = 0;
  range[1] = 100;
  int subject_data[30];
  char query_data[5]; 
  int i = 0;
  while(i<5) {
    query_data[i] = i;
    subject_data[i] = i;
    i++;
  } 
  while(i<30) {
    subject_data[i] = i;
    i++;
  }
 subj->sequence = subject_data;
  int results = s_BlastNaScanSubject_8_4(lookup, subj, offset,max,range);
  
}


