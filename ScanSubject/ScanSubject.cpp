/**
*   File: ScanSubject.cpp
*   
*   This module is a simple command line utility to independently process the
*   hardware search of a BLASTn search using word length 8.
*   Parameters: 
*   const BLAST_SequenceBlk * subject: database struct pointer
*   const BLAST_SequenceBlk * query:   query struct pointer
*   Int4 max_hits: maximum number of hits to return (not implemented yet)
*   Int4 * scan_range: Two-item array with start position and end position. On
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


int main(int argc, char* argv[]) {
  int         err, i, j, stream;
  uint32_t    buf[1024], u32, addr;
  char        ibuf[1024];
  PicoDrv    *pico;
  const char* bitFileName;
  
  const BLAST_SequenceBlk * subject, query;
  Int4 max_hits;
  Int4 * scan_range[2];

  Uint1 *s;                 // Pointer for current address of database index
  Uint1 *abs_start, *s_end; // Pointer for address of absolute start, end
  Int4 total_hits;          // Total number of hits, updated from FPGA memory
  Int4 word_length = 8;     // Number for word length. Plan to take as input in
                            // the future and support more word lengths in FPGA

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
  fprintf(stdout, "Absolute start address of subject sequence is: 0x%08x", abs_start);
  s = abs_start + scan_range[0] / COMPRESSIONRATIO;     // 4 bases per byte
  s_end = abs_start + scan_range[1] / COMPRESSIONRATIO;

  // Write the query of given length to an address in the FPGA

  // Stream out the database in compressed format 

  // while the number of hits is less than the number of hits and haven't 
  // reached the end of the database yet

    // Read memory address for hits counter
    
    // If hits read greater than hits recorded
      
      // Read back 128 bits the number of times of difference between two
      // Upper 64 bits is query index, lower 64 bits is database index
      
      // Convert this back to result format, store it to result array

      // Continue until hits read = hits recorded
}
