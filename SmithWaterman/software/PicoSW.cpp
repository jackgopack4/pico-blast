/*
* File Name     : PicoSW.cpp
*
* Author        : Corey Olson
*
* Description   : This is the top-level file for a Smith-Waterman system.  This
* 				  lets users align queries to a database (both in FASTA format).
* 				  Note that this will either do Smith-Waterman (local) or Needleman-Wunsch (global)
* 				  alignment of the query to the target.
*                   
*                 This module implements multi-threading and it is a test program to check 
*                 the number of times software receives good result when database sequence 
*                 was sent by the software to the hardware.
*
* 				  Note that this is part of the Pico Bioinformatics Accelerated
* 				  Suite (PicoBASe).  This Smith-Waterman software is based upon
* 				  the CUDASW++ work done by Liu Yongchao
* 				  (http://cudasw.sourceforge.net/).
*
* Copyright     : 2013, Pico Computing, Inc.
*/

/* Traceback calculation
* Description	: Created a new thread for receiving the traceback matrix from the FPGA via stream
*		  Calling a function which constructs the traceback matrix with either a match or a gap value in it
*
*/

#include "CParams.h"
#include "kseq.h"
#include "PicoSW.h"

// turn this define on to enable VERBOSE debug printing
#define VERBOSE                 true

///////////////
// FUNCTIONS //
///////////////

/*
 * This writes the scoring matrix to the FPGA via the PicoBus.
 *
 * Here is the PicoBus addressing scheme for the different scores:
 * address      data
 * -------------------
 * 0xBEEF0000   matchBonus
 * 0xBEEF0010   mismatchPenalty
 * 0xBEEF0020   gapOpenCost
 * 0xBEEF0030   gapExtendCost
 *
 * Note: we may want to think about a better way to do this in 
 * hardware than to just write this via the PicoBus due to timing 
 * concerns.
 */
int WriteScoringMatrix(PicoDrv* aligner, ScoreMatrix_t* score_matrix, fpga_cfg_t* cfg){
    
    int     err;
    int     addr=SCORE_MATRIX_ADDR;
    int     score;

    printf("Writing the substitution matrix via the PicoBus\n"); 
    
    // match - must be >= 0
    addr    = SCORE_MATRIX_ADDR;
    score   = score_matrix->match;
    if (score < 0) score = 0 - score;
    if (VERBOSE) printf("Writing match score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;
    
    // mismatch - must be <= 0
    addr    += 16;
    score   = score_matrix->mismatch;
    if (score > 0) score = 0 - score;
    if (VERBOSE) printf("Writing mismatch score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;
    
    // gap open - must be <= 0
    addr    += 16;
    score   = score_matrix->gapOpen;
    if (score > 0) score = 0 - score;
    if (score < (-1*cfg->info[15])){
        printf("abs(gap open) = %i must be <= %i\n", score_matrix->gapOpen, cfg->info[15]);
        return -1;
    }
    if (VERBOSE) printf("Writing gap open score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;
    
    // gap extend - must be <= 0
    addr    += 16;
    score   = score_matrix->gapExtend;
    if (score > 0) score = 0 - score;
    if (score < (-1*cfg->info[16])){
        printf("abs(gap extend) = %i must be <= %i\n", score_matrix->gapExtend, cfg->info[16]);
        return -1;
    }
    if (VERBOSE) printf("Writing gap extend score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;

    return err;
}

/*
 * This reads the current Smith-Waterman configuration info from the FPGA.
 * This includes:
 *  -version;
 *  -picobus_addr_incr;
 *  -num_extra_tx;
 *  -status;
 *  -max_query_length;
 *  -q_pos_w;
 *  -max_target_length;
 *  -t_pos_w;
 *  -num_sw_units;
 *  -sw_clk_freq;
 *  -score_w;
 *  -stream_w;
 *  -int_stream_w;
 *  -stream_base_w;
 *  -int_base_w;
 *  -max_gap_open;
 *  -max_gap_extend;
 */
int ReadConfig(PicoDrv* aligner, fpga_cfg_t* cfg){

    int         err;
    uint32_t    addr    = CONFIG_ADDR;
    uint32_t    cmd;
    
    printf("Reading the config from the FPGA\n");

    // read all the info from the FPGA
    for (int i=0; i<(sizeof(cfg->info)/sizeof(cfg->info[0])); ++i, addr+=16){
        if (VERBOSE) printf("%i: Reading FPGA address 0x%X", i, addr);
        if ((err = aligner->ReadDeviceAbsolute(addr, &cmd, 4)) < 0) return err;
        if (VERBOSE) printf(" = 0x%X\n", cmd);
        cfg->info[i] = cmd;
    }
    return err;
}

/*
 * This method sends a query and a db to the FPGA for alignment.  
 * The most important thing that this method does is handle the formatting of the data on the input stream.
 * See PicoSmithWaterman.v for the proper input stream format.
 */
int AlignQueryToDB(StreamInfo_t* info){

    int         err;
    kseq_t*     query           = info->start_info.query_seq;
    kseq_t*     db              = info->start_info.db_seq;
    int         stream_base_w   = info->cfg->info[13];
    int         max_query_len   = info->cfg->info[4];
    int         max_db_len      = info->cfg->info[6];
    int         num_extra_tx    = info->cfg->info[2];
    int         prev_score      = 0;
    int         buf_ptr         = 0;
    uint64_t*   tx_buf;
    int         buf_size;

    printf("Starting alignment of query to db\n");
    if (VERBOSE){
        printf("query           = %s\n", query->seq.s);
        printf("query length    = %i\n", (int) query->seq.l);
        printf("db              = %s\n", db->seq.s);
        printf("db length       = %i\n", (int) db->seq.l);
        printf("stream_base_w   = %i\n", stream_base_w);
    }

    // check that the query and target don't violate the max length requirements
    if ((int) query->seq.l > max_query_len){
        fprintf(stderr, "query length = %i violates the max query length = %i\n", (int) query->seq.l, max_query_len);
        return -1;
    }else if ((int) db->seq.l > max_db_len){
        fprintf(stderr, "db length = %i violates the max db length = %i\n", (int) db->seq.l, max_db_len);
        return -1;
    }

    // first we create a buffer which we are going to use for sending our data
    buf_size        =   16 * (
                        ((query->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w)) +  // query bases
                        ((db->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w))    +  // db bases
                        1 + 1 + num_extra_tx);                                              // query len, target len, extra @ end
    tx_buf = new uint64_t[buf_size/sizeof(uint64_t)];
    memset(tx_buf,0,buf_size/sizeof(tx_buf[0]));
    
    // now we start putting our stream information into the transmit buffer
    // QUERY
    tx_buf[buf_ptr] = query->seq.l;
    buf_ptr += 16 / sizeof(tx_buf[0]);
    memcpy(&tx_buf[buf_ptr], query->seq.s, query->seq.l);
    buf_ptr += (16 / sizeof(tx_buf[0])) * ((query->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w));
    
    // TARGET
    tx_buf[buf_ptr] = (prev_score<<16) | db->seq.l;
    buf_ptr += 16 / sizeof(tx_buf[0]);
    memcpy(&tx_buf[buf_ptr], db->seq.s, db->seq.l);

    // send the contents of the transmit buffer to the FPGA
    if (VERBOSE) printf("Writing %i B to stream handle %i\n", buf_size, info->stream);
    err = info->pico->WriteStream(info->stream, tx_buf, buf_size);

    // even if we had an error, we better clean up our allocated memory
    delete [] tx_buf;
    return err;
}

/*
 * This method receives a score from the FPGA for a query/db alignment.
 * The most important thing that this method does is handle the formatting of the data on the output stream.
 * See PicoSmithWaterman.v for the proper output stream format.
 * For now, this function only returns a score, but we have a LOT more data available if desired.
 */
int ReceiveScore(StreamInfo_t* info){

    int         err;
    kseq_t*     query           = info->start_info.query_seq;
    kseq_t*     db              = info->start_info.db_seq;
    int         stream_base_w   = info->cfg->info[13];
    int         num_extra_tx    = info->cfg->info[2];
    EndInfo_t*  results         = &info->end_info;
    int         score_index;
    int32_t*    rx_buf;
    int         buf_size;
    
    // first we create a buffer which we are going to use for sending our data
    buf_size        =   16 * (
                        ((query->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w)) +  // query bases
                        ((db->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w))    +  // db bases
                        1 + 1 + num_extra_tx);                                              // query len, target len, extra @ end
    rx_buf          = new int32_t[buf_size/sizeof(int32_t)];
    score_index     = (buf_size/sizeof(rx_buf[0])) - 10;
    memset(rx_buf,0,buf_size/sizeof(rx_buf[0]));
    
    // send the contents of the transmit buffer to the FPGA
    if (VERBOSE) printf("Reading %i B from stream handle %i\n", buf_size, info->stream);
    err = info->pico->ReadStream(info->stream, rx_buf, buf_size);

    // rip through the received scores
    //if (VERBOSE) for (int i=score_index; i<buf_size/sizeof(rx_buf[0]); ++i) printf("%i: 0x%X\n", i, rx_buf[i]);

    // pick out the local and global score info
    if (VERBOSE) printf("Reading scores from index %i\n", score_index);
    results->localScore         = (int16_t) rx_buf[1];
    results->localQueryBase     = (int)     rx_buf[score_index];    score_index += 2;
    results->localTargetBase    = (int)     rx_buf[score_index];    score_index += 2;
    results->globalTargetBase   = (int)     rx_buf[score_index];    score_index += 2;
    results->globalScore        = (int16_t) rx_buf[score_index];

    // even if we had an error, we better clean up our allocated memory
    delete [] rx_buf;
    return err;
}

/* This method gathers all of the traceback data from a single stream.  All of the data is 
 * put into an array in the stream info struct.  The argument passed in is expected to be 
 * of type args_t.  This function is indended to be the start point of a new thread and
 * not called directly.  All data is returned through the structs contained in the argument.
 */
void * ReceiveTracebackData(void* arg){

  args_t *a = (args_t *) arg;
  StreamInfo_t *info = a->streaminfo;
  int index = a->thread_index;
  printf("Reading the resulting traceback from the FPGA\n");

  int         err;
  kseq_t*     query           = info->start_info.query_seq;
  kseq_t*     db              = info->start_info.db_seq;
  uint64_t*    rx_buf;
  int         buf_size;
  int         buf_len;
  char            ibuf    [1024];
    
  // first we create a buffer which we are going to use for receiving our data
  //  buf_len         = a->buffer_length;
  buf_len = (query->seq.l + db->seq.l - 1) *2;
  buf_size        = sizeof(uint64_t) * buf_len;
  if (VERBOSE) printf("Thread %d, Creating uint64_t buffer w/ %i entries, %i B per entry, %i B total\n", index, buf_len, (int) sizeof(uint64_t), buf_len*((int)sizeof(uint64_t)));
  rx_buf          = (uint64_t*) calloc(buf_len, sizeof(uint64_t));
  // receive the contents of buffer from the FPGA
  if (VERBOSE) printf("Thread %d, Reading %i B from stream handle %i\n", index, buf_size, info->traceback_stream[index]);
  if ((err = info->pico->ReadStream(info->traceback_stream[index], rx_buf, buf_size)) < 0){
    fprintf(stderr, "RunBitFile error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
    exit(EXIT_FAILURE);
  }

  if (VERBOSE) 
    for (int i=0; i < buf_len; i++)
      printf("%lx\n", rx_buf[i]);

  info->traceback_buffer[index] = rx_buf;
}


/* This function combines the traceback data arrays from multiple threads into a single buffer in the 
 * ordering that is expected from the traceback functions. 
 */
int combineStreamData(uint64_t **stream_data, int num_streams, int length, uint64_t* out_buffer) {
  
  int index = 0;
  for (int l=0; l<length*2; l+=2){ // 2s due to each stream being divided into 64bit halves
    for (int s=0; s<num_streams; s++) {
      out_buffer[index++] = stream_data[s][l];
      out_buffer[index++] = stream_data[s][l+1];
    }
  }

  return 0;
}


//////////
// MAIN //
//////////
int main(int argc, char* argv[]) {

	// command-line arguments
	CParams         args;

	// handles to the Smith-Waterman FPGA systems
	PicoDrv*        aligner;
    fpga_cfg_t      cfg;

	// query and db FASTA file handlers
	gzFile          queryFile;
	gzFile          dbFile;

	// kseq pointers for parsing FASTA files
	kseq_t*         querySeq;
	kseq_t*         dbSeq;

    // alignment score
    int             score;

    // info that we need to create different threads
    // 1 thread used to send the query to the FPGA
    // 1 thread used to send the db to the FPGA
    // the main thread used to read results from the FPGA
    StreamInfo_t*   query_db_info;
    
    // temporary variables
    int             err;
    char            ibuf    [1024];

    ////////////////////////
    // PARSE COMMAND LINE //
    ////////////////////////
	
    if (!args.parseParams(argc, argv)){
		return EXIT_FAILURE;
	}

	// select a bitfile based upon query length
	args.setActiveBitfile(args.getMaxQueryLength(), args.getBitfile().c_str());

    //////////////////
    // PROGRAM FPGA //
    //////////////////
    
    // program the device
    printf("Programming FPGA with %s\n", args.getActiveBitfile().c_str()); 
    if ((err = RunBitFile(args.getActiveBitfile().c_str(), &aligner)) < 0){
		fprintf(stderr, "RunBitFile error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
		return EXIT_FAILURE;
	}

    // read the FPGA configuration info
    // here we read some config info about the programming file that we just used, including the max query length, the number of aligners, etc.
    if (VERBOSE) printf("Reading the configuration info from the FPGA\n");
    if ((err = ReadConfig(aligner, &cfg)) < 0){
		fprintf(stderr, "ReadConfig error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
		return EXIT_FAILURE;
	}
    
    // create the right number of StreamInfo structs
    query_db_info = new StreamInfo_t[cfg.info[7]];

    // create the streams to talk to the separate alignment units
    // also, populate the StreamInfo structs w/ the info that we know so far
    for (int i=1; i<=cfg.info[8]; ++i){
        if (VERBOSE) printf("Creating stream %i\n", i);
        if ((err = aligner->CreateStream(i)) < 0){
		    fprintf(stderr, "CreateStream error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
		    return EXIT_FAILURE;
        }
        if (VERBOSE) printf("Stream handle = %i\n", err);
        query_db_info[i-1].stream   = err;
        query_db_info[i-1].cfg      = &cfg;
        query_db_info[i-1].pico     = aligner;
    }

    ////////////////////
    // SCORING MATRIX //
    ////////////////////
	
    if ((err = WriteScoringMatrix(aligner, args.getScoreMatrix(), &cfg)) < 0){
		fprintf(stderr, "WriteScoringMatrix error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
		return EXIT_FAILURE;
    }
    
    ///////////////////////////
    // PARSE QUERY FROM FILE //
    ///////////////////////////
    
    printf("Reading in the query from %s\n", args.getQueryFile().c_str());
	
    // open the query file
	queryFile   = gzopen(args.getQueryFile().c_str(), "r");
    if (queryFile == Z_NULL){
		fprintf(stderr, "Unable to open query file: %s\n", args.getQueryFile().c_str());
        return EXIT_FAILURE;
    }
	querySeq    = kseq_init(queryFile);

    // read the query in from the file
    err                                     = kseq_read(querySeq);
    query_db_info[0].start_info.query_seq   = querySeq;

    ////////////////////////
    // PARSE DB FROM FILE //
    ////////////////////////
    
    // Open the files for the database sequence
    dbFile      = gzopen(args.getDbFile().c_str(), "r");
    if (dbFile == Z_NULL){
		fprintf(stderr, "Unable to open db file: %s\n", args.getQueryFile().c_str());
        return EXIT_FAILURE;
    }
    dbSeq       = kseq_init(dbFile);
    
    // read the db in from the file
    err                                     = kseq_read(dbSeq);
    query_db_info[0].start_info.db_seq      = dbSeq;
    
    ////////////////////////////////
    // SEND THE QUERY/DB TO INPUT //
    ////////////////////////////////

    // send the query and the DB to the FPGA for alignment
    printf("Sending the query and the db to the FPGA for alignment\n");
    if ((err = AlignQueryToDB(&query_db_info[0])) < 0){
        fprintf(stderr, "AlignQueryToDB error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
        return EXIT_FAILURE;
    }
    
    ////////////////////////////////
    // RECEIVE RESULT FROM OUTPUT //
    ////////////////////////////////
    
    // Create traceback stream(s)
    pthread_t traceback_thread[8];
    int stream_count = get_size(query_db_info[0].start_info.query_seq->seq.l);
    int buffer_length = (query_db_info[0].start_info.query_seq->seq.l + query_db_info[0].start_info.db_seq->seq.l - 1) *2;
    args_t *a = new args_t[stream_count];
    for (int n=0; n<stream_count; n++){
      if ((err = aligner->CreateStream(12+n)) < 0){
	fprintf(stderr, "CreateStream error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
	return EXIT_FAILURE;
      }
      query_db_info[0].traceback_stream[n] = err;

      // Create thread to read traceback stream into buffer
      a[n].streaminfo = &query_db_info[0];
      a[n].thread_index = n;
      if (buffer_length <= (64 + query_db_info[0].start_info.db_seq->seq.l - 1)*2)
	a[n].buffer_length = buffer_length;
      else 
	a[n].buffer_length = (64 + query_db_info[0].start_info.db_seq->seq.l - 1)*2;
      buffer_length -= (64 + query_db_info[0].start_info.db_seq->seq.l - 1)*2;
      err = pthread_create(&traceback_thread[n], NULL, ReceiveTracebackData, (void *) &a[n]);
      if (err != 0){
	fprintf(stderr, "Thread creation error: %d\n", err);
	return EXIT_FAILURE;
      }
    }
    // this just returns the score
    // we can add a LOT more functionality here if we want
    printf("Reading the resulting score from the FPGA\n");
    if ((err = ReceiveScore(&query_db_info[0])) < 0){
        fprintf(stderr, "ReceiveScore error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
        return EXIT_FAILURE;
    }
    printf("Alignment score = %i at base %i\n", 
            query_db_info[0].end_info.globalScore,
            query_db_info[0].end_info.globalTargetBase);

    // Wait for traceback thread to finish reading
    for (int n=0; n<stream_count; n++){
      if ((err = pthread_join(traceback_thread[n], NULL)) != 0){
	fprintf(stderr, "Thread join error: %d\n", err);
	return EXIT_FAILURE;
      }
    }

    // Combine data from multiple streams into single traceback data array.
    if (VERBOSE)
      printf("Combining stream data.\n");
    int traceback_size = query_db_info[0].start_info.query_seq->seq.l + query_db_info[0].start_info.db_seq->seq.l - 1;
    uint64_t *buffer = (uint64_t *)calloc(traceback_size*2*stream_count, sizeof(uint64_t));
    combineStreamData(&(query_db_info[0].traceback_buffer[0]), stream_count, traceback_size, buffer);
		      
    // print out the data that we just received
    if (VERBOSE) 
      for (int i=0; i < traceback_size*2*stream_count; i++)
    	printf("index: %d, %lx\n", i, buffer[i]);

    printf("Starting traceback calculation.\n");
    int * traceback = new int[traceback_size];

    // Perform traceback calculations
    err = trace_matrix_generate(traceback, buffer,
    				query_db_info[0].start_info.query_seq->seq.l,  
    				query_db_info[0].start_info.db_seq->seq.l);

    if (VERBOSE) {
      if(err==0) {
        printf("Traceback calculation failed\n");
        printf("The trace matrix data received is invalid\n");
      }
      else {
        printf("Traceback calculation successfull\n");
        printf("Traceback matrix is:\n");
        for(int i=0;i<err;i++)
          printf("%d\t",traceback[i]);
        printf("\n");
      }
    }


    /////////////
    // CLEANUP //
    /////////////

    // close the input and output files for sequences
    kseq_destroy(querySeq);
    gzclose(queryFile);
    kseq_destroy(dbSeq);
	gzclose(dbFile);

    // free up allocated memory
    for (int n=0; n<get_size(query_db_info[0].start_info.query_seq->seq.l); n++){
      free(query_db_info[0].traceback_buffer[n]);
    }
    delete      aligner;
    delete []   query_db_info;
    
    return EXIT_SUCCESS;
}
