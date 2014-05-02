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
*   Int4 max_hits: maximum number of hits to return (not implemented yet)
*   Int4 * scan_range: Two-item array with start position and end position. On
*                      exit, scan_range[0] is updated with stopping position
*/

#include <stdio.h>
#include <string.h>
#include "includes/picodrv.h"
#include "includes/pico_errors.h"

#include "includes/blast_nalookup.h"
#include "includes/blast_nascan.h"
#include "includes/blast_util.h" /* for NCBI2NA_UNPACK_BASE */

#define FULL_128_BITS 16
#define WRITESTREAM false
#define READSTREAM true
#define COMPRESSIONRATIO 4

#define QUERYADDRESS 0x0
#define READYADDRESS 0x10
#define NUMRESULTSADDRESS 0x20
#define SUBJECTINDEXADDRESS 0x30

int main(int argc char * arg[]) {
  LookupTableWrap * lookup;
  BLAST_SequenceBlk * subj;
  BlastOffsetPair * NCBI_RESTRICT offset[50];
  Int4 max = 1000;
  Int4 *range[2];
  range[0] = 0;
  range[1] = 100;
  char * subject_data[30];
  char * query_data[5]; 
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
  Int4 results = s_BlastNaScanSubject_8_4(lookup, subj, offset,max,range);
  
}

static Int4 s_BlastNaScanSubject_8_4(const LookupTableWrap * lookup_wrap,
                                     const BLAST_SequenceBlk * subject,
                                     BlastOffsetPair * NCBI_RESTRICT offset_pairs,
                                     Int4 max_hits, Int4 * scan_range) {
  int         err, i, j, stream;
  uint32_t    buf[1024], u32, addr, numHitsBuffer[4],indexBuffer[4];
  char        ibuf[1024];
  PicoDrv    *pico;
  const char* bitFileName;
  
  const BLAST_SequenceBlk * subject, query;
  Int4 max_hits;
  Int4 * scan_range[2];

  Uint1 *s = subject->sequence; // Pointer for current address of database index
  Uint1 *abs_start, *s_end; // Pointer for address of absolute start, end
                            // s_end not yet implemented yet
  Int4 total_hits;          // Total number of hits, updated from FPGA memory
  Int4 current_hits;
  Int4 word_length = 8;     // Number for word length. Plan to take as input in
                            // the future and support more word lengths in FPGA

  Uint1 *q = query->sequence;

  int count;                            // Used for incrementing
  Int4 queryLength = query->length;     // Length parameter for query.
  Int4 subjectLength = subject->length;
  Int4 queryLengthBytes = queryLength / 4;
  Int4 subjectLengthBytes = subjectLength / 4;
  Uint1 tempResults[FULL_128_BITS];
  
  Int4 current_query_index;
  Int4 current_database_index;
  
  Uint1 database_stream = 1;
  Uint1 results_stream  = 2;

  BlastOffsetPair * offset_pairs; // Passed in and allocated earlier on in the function

  // specify the .bit file name on the command line
  bitFileName = argv[1];
  
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
  printf("Absolute start address of subject sequence is: 0x%08x", abs_start);
  s = abs_start + scan_range[0] / COMPRESSIONRATIO;     // 4 bases per byte
  s_end = abs_start + scan_range[1] / COMPRESSIONRATIO;
  q = query->sequence;
  // Write the query of given length to an address in the FPGA
  current_query_index = 0;
  printf("Begin writing query to register in FPGA");
  while(current_query_index < queryLengthBytes) {
    pico->WriteDeviceAbsolute(QUERYADDRESS, abs_start, FULL_128_BITS);
    current_query_index+=FULL_128_BITS;
  }
  // Stream out the database in compressed format 
  current_database_index = 0;
  uint32_t database_stream_length = (uint32_t) (scan_range[1] - scan_range[0])*4;
  uint32_t database_base_length = database_stream_length / 2;
  pico->WriteStream(database_stream, s,database_stream_length); 
  
  while((current_database_index < database_base_length) // Haven't exceeded database width
             && (total_hits < max_hits)) { // Also haven't exceeded max desired hits
    if(pico->ReadDeviceAbsolute(READYADDRESS, tempResults, 16) & 0x1) { // new data ready
      pico->ReadDeviceAbsolute(NUMRESULTSADDRESS, numHitsBuffer, 16); // read # of results
      pico->ReadDeviceAbsolute(SUBJECTINDEXADDRESS,indexBuffer, 16); // read subject addr 
      while(current_hits < numHitsBuffer[0]) { // still more hits in this frame of the query
        pico->ReadStream(results_stream, tempResults, 16); // Receive 128-bit query hit
        Int4 sampleResult = tempResults[0] << 4 + tempResults[1] >> 4;
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
