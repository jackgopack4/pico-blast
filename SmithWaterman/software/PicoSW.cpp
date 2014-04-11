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
int WriteScoringMatrix(PicoDrv* aligner, ScoreMatrix_t* score_matrix){
    
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
    if (VERBOSE) printf("Writing gap open score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;
    
    // gap extend - must be <= 0
    addr    += 16;
    score   = score_matrix->gapExtend;
    if (score > 0) score = 0 - score;
    if (VERBOSE) printf("Writing gap extend score = %i to address = 0x%X\n", score, addr);
    if ((err = aligner->WriteDeviceAbsolute(addr, &score, 4)) < 0) return err;

    return err;
}

/*
 * This reads the current Smith-Waterman configuration info from the FPGA.
 * This includes:
 *  -version;
 *  -picobus_addr_incr;
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
                        1 + 1 + 3);                                                         // query len, target len, 3 extra @ end
    tx_buf = new uint64_t[buf_size/sizeof(uint64_t)];
    memset(tx_buf,0,buf_size/sizeof(tx_buf[0]));
    
    // now we start putting our stream information into the transmit buffer
    // QUERY
    tx_buf[buf_ptr] = query->seq.l;
    buf_ptr += 16 / sizeof(tx_buf[0]);
    memcpy(&tx_buf[buf_ptr], query->seq.s, query->seq.l);
    buf_ptr += (16 / sizeof(tx_buf[0])) * ((query->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w));
    
    // TARGET
    tx_buf[buf_ptr] = (0<<16) | db->seq.l;
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
    int16_t*    rx_buf;
    int         buf_size;
    
    // first we create a buffer which we are going to use for sending our data
    buf_size        =   16 * (
                        ((query->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w)) +  // query bases
                        ((db->seq.l + (128/stream_base_w) - 1) / (128/stream_base_w))    +  // db bases
                        1 + 1 + 3);                                                         // query len, target len, 3 extra @ end
    rx_buf = new int16_t[buf_size/sizeof(int16_t)];
    memset(rx_buf,0,buf_size/sizeof(rx_buf[0]));
    
    // send the contents of the transmit buffer to the FPGA
    if (VERBOSE) printf("Reading %i B from stream handle %i\n", buf_size, info->stream);
    err = info->pico->ReadStream(info->stream, rx_buf, buf_size);

    // pick out the score that we want to return
    if (err >= 0) err = (int) rx_buf[1];

    // even if we had an error, we better clean up our allocated memory
    delete [] rx_buf;
    return err;
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
    for (int i=1; i<=cfg.info[7]; ++i){
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
	
    if ((err = WriteScoringMatrix(aligner, args.getScoreMatrix())) < 0){
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
    
    // this just returns the score
    // we can add a LOT more functionality here if we want
    printf("Reading the resulting score from the FPGA\n");
    if ((err = ReceiveScore(&query_db_info[0])) < 0){
        fprintf(stderr, "ReceiveScore error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
        return EXIT_FAILURE;
    }
    printf("Alignment score = %i\n", err);
    
    /////////////
    // CLEANUP //
    /////////////

    // close the input and output files for sequences
    kseq_destroy(querySeq);
    gzclose(queryFile);
    kseq_destroy(dbSeq);
	gzclose(dbFile);

    // free up allocated memory
	delete      aligner;
    delete []   query_db_info;

	return EXIT_SUCCESS;
}
