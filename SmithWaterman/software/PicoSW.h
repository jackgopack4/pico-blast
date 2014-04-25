/*
* File Name     : PicoSW.cpp
*
* Creation Date : Fri 22 Feb 2013 11:08:02 AM CST
*
* Author        : Corey Olson
*
* Last Modified : Wed 03 Apr 2013 04:34:39 PM CDT
*
* Description   : This is the main header file of a Smith-Waterman system.  This
* 				  lets users align queries to a database (both in FASTA format).
* 				  Note that the Smith-Waterman algorithm performs local
* 				  alignment of the query to the target.
*
* 				  Note that this is part of the Pico Bioinformatics Accelerated
* 				  Suite (PicoBASe).  This Smith-Waterman software is based upon
* 				  the CUDASW++ work done by Liu Yongchao
* 				  (http://cudasw.sourceforge.net/).
*
* Copyright     : 2013, Pico Computing, Inc.
*/

#ifndef PICOSW_H_
#define PICOSW_H_

#include <zlib.h>
#include <stdio.h>
#include <stdlib.h>

#include <string>

#include <pico_drv.h>
#include <pico_errors.h>

#include "CParams.h"
#include "kseq.h"

// declare the type of file handler and the read() function
KSEQ_INIT(gzFile, gzread)

/////////////
// STRUCTS //
/////////////

// this struct contains the special info needed to kick off a new alignment of a query to a a db
typedef struct StartStreamInfo {
    kseq_t*         query_seq;
    kseq_t*         db_seq;
} StartInfo_t;

// this struct contains the special info needed to gather the results of an alignment
typedef struct EndStreamInfo {
    int             localScore;
    int             localTargetBase;
    int             localQueryBase;
    int             globalScore;
    int             globalTargetBase;
} EndInfo_t;

// this is the configuration info for the selected FPGA programming file
typedef struct fpga_cfg {
    int             info            [18];
    /*
0:  int             version
1:  int             picobus_addr_incr;
2:  int             num_extra_tx;
3:  int             status;
4:  int             max_query_length;
5:  int             q_pos_w;
6:  int             max_target_length;
7:  int             t_pos_w;
8:  int             num_sw_units;
9:  int             sw_clk_freq;
10: int             score_w;
11: int             stream_w;
12: int             int_stream_w;
13: int             stream_base_w;
14: int             int_base_w;
15: int             max_gap_open;
16: int             max_gap_extend;
17: int             use_local_alignment
    */
} fpga_cfg_t;

// this struct contains all the info needed to either start or new alignment
// or to gather the results for an alignment
typedef struct StreamInfo {
    pthread_t       thread;
    PicoDrv*        pico;
    int             stream;
    int             traceback_stream;
    fpga_cfg_t*     cfg;
    StartInfo_t     start_info;
    EndInfo_t       end_info;
    uint64_t*       traceback_buffer;
} StreamInfo_t;

///////////////
// CONSTANTS //
///////////////

// this is the start PicoBus address for the configuration information
#define CONFIG_ADDR             0x0

// PicoBus address for writing to the affine gap model scores
#define SCORE_MATRIX_ADDR       0x140

// we use this PicoBus address to write a low and high score threshold to the PicoBus
#define THRESHOLD_SCORE_ADDR    0xBEEF0040

// number of bits used to represent the score
#define SCORE_BITS          10

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
int WriteScoringMatrix(PicoDrv* aligner, ScoreMatrix_t* score_matrix);

/*
 * This reads the current Smith-Waterman configuration info from the FPGA.
 */
int ReadConfig(PicoDrv* aligner, fpga_cfg_t* cfg);

/*
 * This method sends a query and a db to the FPGA for alignment.  
 * The most important thing that this method does is handle the formatting of the data on the input stream.
 * See PicoSmithWaterman.v for the proper input stream format.
 */
int AlignQueryToDB(StreamInfo_t* info);

/*
 * This method receives a score from the FPGA for a query/db alignment.
 * The most important thing that this method does is handle the formatting of the data on the output stream.
 * See PicoSmithWaterman.v for the proper output stream format.
 * For now, this function only returns a score, but we have a LOT more data available if desired.
 */
int ReceiveScore(StreamInfo_t* info);

void *ReceiveTraceback(StreamInfo_t* info);

#endif /* PICOSW_H_ */
