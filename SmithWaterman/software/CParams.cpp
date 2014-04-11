/*
* File Name     : CParams.h
*
* Creation Date : Fri 22 Feb 2013 11:08:02 AM CST
*
* Author        : Corey Olson
*
* Last Modified : Wed 03 Apr 2013 02:17:00 PM CDT
*
* Description   : Object for parsing and managing the command-line parameters.
*
* Copyright     : 2012, Pico Computing, Inc.
*/

#include "CParams.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

CParams::CParams() {
    setDefaultArgs();
    setBitFileNames();
}
CParams::~CParams() {
}
void CParams::getSysTime(double *dtime) {
    struct timeval tv;

    gettimeofday(&tv, NULL);

    *dtime = (double) tv.tv_sec;
    *dtime = *dtime + (double) (tv.tv_usec) / 1000000.0;
}
void CParams::printUsage() {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "./picosw [options]\n");
    fprintf(stderr, "Required options:\n");
    fprintf(stderr, "\t-query <string>\t\t: specify the query sequence file\n");
    fprintf(stderr, "\t-db <string>\t\t: specify the database sequence file\n");
    fprintf(stderr, "\t-bit <string>\t\t: bitfile name to use to program the FPGA\n");
    fprintf(stderr, "Standard options:\n");
        /*fprintf(stderr,
                "\t-mat <string>\t\t: specify the substitution matrix name (default blosum62)\n");
        fprintf(stderr,
                "\t\t\t\tsupported = {blosum45, blosum50, blosum62, blosum80}\n");*/
    fprintf(stderr,
            "\t-gapo <int>\t\t: specify the gap open panelty (0 ~ 255), (default %d)\n", gapOpen);
    fprintf(stderr,
            "\t-gape <int>\t\t: specify the gap extension panelty (0 ~ 255), (default %d)\n", gapExtend);
    fprintf(stderr,
            "\t-min_score <int>\t: specify the minimum score reported(default %d)\n", scoreThreshold);
    fprintf(stderr,
            "\t-topscore_num <int>\t: specify the number of top scores reported(default %d)\n", topScoresNum);
    fprintf(stderr, "\t-num_fpgas <int>\t: number of FPGAs, (default %d)\n", numFPGAs);
    fprintf(stderr, "\t-query_len <int>\t: maximum query length, (default %d)\n", maxQueryLength);
    fprintf(stderr, "\t-version\t\t: print out the version\n");
    fprintf(stderr, "\t-help\t\t\t: print out this message\n");
}

// returns false if the parsing of parameters fails
// returns true if the parsing of parameters succeeds
bool CParams::parseParams(int argc, char* argv[]) {
    bool queryAvail = false;
    bool dbAvail = false;
    bool bitAvail = false;

    int index;
    //display usages
    if (argc < 2 || !strcmp(argv[1], "-help") || !strcmp(argv[1], "-?")) {
        printUsage();
        return false;
    }

    index = 1;
    // parse other arguments
    char* arg;
    for (; index < argc; index++) {
        arg = argv[index];
        if (index >= argc) {
            fprintf(stderr,
                    "The number of the specified arguments does not match!");
            printUsage();
            return false;
        } else if (strcmp(arg, "-mat") == 0) {
            subMatName = argv[++index];
        } else if (strcmp(arg, "-query") == 0) {
            queryFile = argv[++index];
            queryAvail = true;
        } else if (strcmp(arg, "-db") == 0) {
            dbFile = argv[++index];
            dbAvail = true;
        } else if (strcmp(arg, "-bit") == 0) {
            bitFile = argv[++index];
            bitAvail = true;
        } else if (strcmp(arg, "-gapo") == 0) {
            sscanf(argv[++index], "%d", &gapOpen);
            if (gapOpen < 0 || gapOpen > 255) {
                gapOpen = DEFAULT_GAPO;
                fprintf(stderr, "using the default gap open penalty: %d\n",
                        gapOpen);
            }
            ScoreMatrix.gapOpen = gapOpen;
        } else if (strcmp(arg, "-gape") == 0) {
            sscanf(argv[++index], "%d", &gapExtend);
            if (gapExtend < 0 || gapExtend > 255) {
                gapExtend = DEFAULT_GAPE;
                fprintf(stderr, "using the default gap extension penalty: %d\n",
                        gapExtend);
            }
            ScoreMatrix.gapExtend = gapExtend;
        } else if (strcmp(arg, "-min_score") == 0) {
            sscanf(argv[++index], "%d", &scoreThreshold);
            if (scoreThreshold < 0) {
                scoreThreshold = 0;
            }
        } else if (strcmp(arg, "-topscore_num") == 0) {
            sscanf(argv[++index], "%d", &topScoresNum);
            if (topScoresNum < 1) {
                topScoresNum = 1;
            }
        } else if (strcmp(arg, "-num_fpgas") == 0) {
            sscanf(argv[++index], "%d", &numFPGAs);
            if (numFPGAs < 1) {
                numFPGAs = 1;
            }
            if (numFPGAs > 48) {
                numFPGAs = 48;
            }
        } else if (strcmp(arg, "-query_len") == 0) {
            sscanf(argv[++index], "%d", &maxQueryLength);
            if (maxQueryLength < 0) {
                maxQueryLength = DEFAULT_MAX_QUERY_LENGTH;
                fprintf(stderr, "using the default max query length: %d\n",
                                        maxQueryLength);
            }
            if (maxQueryLength > 250) {
                maxQueryLength = 250;
                fprintf(stderr, "using the max supported query length: %d\n",
                                                        maxQueryLength);
            }
        } else if (strcmp(arg, "-help") == 0 || strcmp(arg, "-?") == 0) {
            printUsage();
            return false;
        } else if (strcmp(arg, "-version") == 0) {
            fprintf(stderr, "PicoSW version: %s\n", version.c_str());
            return false;
        } else {
            fprintf(stderr, "\n************************************\n");
            fprintf(stderr, "Unknown option: %s;\n", arg);
            fprintf(stderr, "\n************************************\n");
            printUsage();
            return false;
        }
    }

    if (!queryAvail) {
        fprintf(stderr, "Please specify the query sequence file\n");
        printUsage();
        return false;
    }
    if (!dbAvail) {
        fprintf(stderr, "Please specify the database sequence file\n");
        printUsage();
        return false;
    }
    if (!bitAvail) {
        fprintf(stderr, "Please specify a bitfile to program the FPGA\n");
        printUsage();
        return false;
    }

    return true;
}

/*
void CParams::getMatrix(string name, int matrix[32][32]) {
    if (name.compare("blosum45") == 0) {
        memcpy(matrix, blosum45, 32*32*sizeof(int));
    } else if (name.compare("blosum50") == 0) {
        memcpy(matrix, blosum50, 32*32*sizeof(int));
    } else if (name.compare("blosum62") == 0) {
        memcpy(matrix, blosum62, 32*32*sizeof(int));
    } else if (name.compare("blosum80") == 0) {
        memcpy(matrix, blosum80, 32*32*sizeof(int));
    } else {
        fprintf(stderr, "*************************************************\n");
        fprintf(stderr, "the scoring matrix (%s) can not be found\n", name.c_str());
        fprintf(stderr, "the default scoring matrix (BLOSUM62) is used\n");
        fprintf(stderr, "*************************************************\n");
        memcpy(matrix, blosum62, 32*32*sizeof(int));
    }
    checkMatrix(matrix);
}
*/

// matrix MUST be mirrored about the diagonal
// i.e. matrix[i][j] == matrix[j][i]
void CParams::checkMatrix(int matrix[32][32]){
    //check the validity of the matrix;
    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j <= i; ++j) {
            if (matrix[i][j] != matrix[j][i]) {
                printf("values[%i][%i] are not equal (%d %d)\n", i,j,matrix[i][j],
                        matrix[j][i]);
                getchar();
                break;
            }
        }
    }
}

/*
void CParams::getMatrix(int matrix[32][32]) {
    getMatrix(getSubMatrixName(), matrix);
}
*/

// sets the default runtime parameters
void CParams::setDefaultArgs(){

    gapOpen         = DEFAULT_GAPO;
    gapExtend       = DEFAULT_GAPE;
    scoreThreshold  = DEFAULT_MIN_SCORE;
    topScoresNum    = DEFAULT_TOPSCORE_NUM;
    numFPGAs        = 1;
    maxQueryLength  = DEFAULT_MAX_QUERY_LENGTH;

    subMatName      = '\0';
    queryFile       = '\0';
    dbFile          = '\0';
    bitFile         = '\0';

    ScoreMatrix.match       = DEFAULT_MATCH;
    ScoreMatrix.mismatch    = DEFAULT_MISMATCH;
    ScoreMatrix.gapOpen     = DEFAULT_GAPO;
    ScoreMatrix.gapExtend   = DEFAULT_GAPE;

    version         = PICO_SW_VERSION;
};

// selects the active bitfile based upon the maximum query length
// also sets the maximum number of queries in a single FPGA
void CParams::setActiveBitfile(int queryLength){

    if (queryLength < 0){
        printf("Max query length must be > 0\n");
        exit(EXIT_FAILURE);
    }else if (queryLength == 0){
        printf("Running with max query length = 100 against simulation\n");
        maxQueryLength = 0;
    }else if (queryLength <= 25){
        maxQueryLength = 25;
    }else if (queryLength <= 50){
        maxQueryLength = 50;
    }else if (queryLength <= 75){
        maxQueryLength = 75;
    }else if (queryLength <= 100){
        maxQueryLength = 100;
    }else if (queryLength <= 150){
        maxQueryLength = 150;
    }else if (queryLength <= 200){
        maxQueryLength = 200;
    }else if (queryLength <= 250){
        maxQueryLength = 250;
    }else{
        printf("Currently max supported query length = 250\n");
        exit(EXIT_FAILURE);
    }
    activeBitfile = bitFileNames[maxQueryLength];
    setMaxQueriesPerFPGA(maxQueryLength);
}

// selects the active bitfile name based upon the input string
void CParams::setActiveBitfile(int queryLength, const char* newBitfileName){
    
    // first set the query length
    setActiveBitfile(queryLength);

    // now override the bitfile name
    bitFileNames[getMaxQueryLength()] = newBitfileName;
    activeBitfile = bitFileNames[getMaxQueryLength()];
}
