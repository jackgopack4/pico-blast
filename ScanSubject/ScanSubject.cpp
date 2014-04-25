#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <picodrv.h>
#include <pico_errors.h>
#define STREAMWRITE false
#define STREAMREAD  true
#define WRITE_DATA_SIZE 1048576
#define DATABASELENGTH 32768
int main(int argc, char* argv[]) {
    int err, i, j, stream;
    uint32_t buf[1024], results[8192];
    void * currentResults;
    BlastOffsetPair * NCBI_RESTRICT offset_pairs; // add offsets
    PicoDrv *pico;
    void* query, database;
    const char* bitFileName = "M501_PicoBus128_HelloWorld.bit";
    int num_hits;
    int total_hits = 0;
    int lut_word_length = 8;

    // allocate 128 bits for currentResults;
    currentResults = malloc(16);
    // Load bit file here
    bitFileName = argv[1];
    runBitFile(bitFileName, &pico);

    // Take query and database pointers as inputs
    query = atoi(argv[2]);
    database = atoi(argv[3]);

    // We will put the query directly into a register of 8192 bits (or break 
    // it up into separate registers, I don't know if 8192 width is possible
    // It is also possible that writing directly to the registers takes
    // too long, we might need to break it up. Ask corey about this.
    pico->WriteDeviceAbsolute(0, query, queryLength);

    //output stream for database
    databaseStream = pico->CreateStream(1);
    resultStream = pico->CreateStream(3);

    // get bytes of room available in stream to firmware
    i=pico->GetBytesAvailable(databaseStream, STREAMWRITE);
    if (i > DATABASELENGTH*lut_word_length) {
        i = DATABASELENGTH*lut_word_length;
    }
    // Query and Database will be in same format
    // Empty character followed by two-bit compressed sequence
    // A: 00
    // C: 01
    // G: 10
    // T: 11
    // Last byte contains the last 0-3 bases (residues)
    // Last two bits of last byte contains number of residues in the byte
    // e.g. if the last byte is 10000001 the byte has one residue base: G

    // Stream in database
    pico->WriteStream(databaseStream, database, i);     
    // Close stream when done
    pico->CloseStream(databaseStream);

    // process results as they return
    // while current result is inside database
    pico -> ReadStream(resultStream,currentResults,16); 
    // calculate absolute index of current offset pairs
    // query index = index value
    // database index = index value + database counter
    offset_pairs[j]->q_off = queryIndex;
    offset_pairs[j]->s_off = queryIndex + databaseCounter;

    // Return results
    i = pico->GetBytesAvailable(resultStream,STREAMREAD);
    pico->ReadStream(resultStream, results, i);
    pico->CloseStream(resultStream);
    return 0;
}
