/*
* File Name     : CParams.h
*
* Creation Date : Fri 22 Feb 2013 11:08:02 AM CST
*
* Author        : Corey Olson
*
* Last Modified : Wed 03 Apr 2013 02:16:48 PM CDT
*
* Description   : Header file for parameter object
*
* Copyright     : 2012, Pico Computing, Inc.
*/

#ifndef _CPARAMS_H
#define _CPARAMS_H

#include <string>

#include "Defs.h"

using namespace std;

// Default parameter values
#define DEFAULT_MATCH                   2
#define DEFAULT_MISMATCH                2
#define DEFAULT_GAPO                    10
#define DEFAULT_GAPE                    2
#define DEFAULT_MIN_SCORE               100
#define DEFAULT_TOPSCORE_NUM            10

#define DEFAULT_MAX_QUERY_LENGTH        100

// this is the scoring matrix that we write to the FPGA
typedef struct ScoreMatrix {
    int             match;      // (positive)
    int             mismatch;   // (negative)
    int             gapOpen;    // (negative)
    int             gapExtend;  // (negative)
} ScoreMatrix_t;

class CParams
{
public:
    CParams();
    ~CParams();

    // returns the current system time
    static void getSysTime(double * dtime);

    // parses the command-line parameters into this object
    bool parseParams(int argc, char* argv[]);

    // returns the current gap open score
    int getGapOpen() {
        return gapOpen;
    }

    // returns the current gap extension score
    int getGapExtend() {
        return gapExtend;
    }

    // returns the name of the substitution matrix
    string getSubMatrixName() {
        return subMatName;
    }
    
    // returns a pointer to the simple scoring matrix
    ScoreMatrix_t* getScoreMatrix(){
        return &ScoreMatrix;
    }

    // returns the name of the query file
    string getQueryFile() {
        return queryFile;
    }

    // returns the name of the database file
    string getDbFile() {
        return dbFile;
    }

    // returns a substitution matrix based upon the name
    //void getMatrix(string name, int matrix[32][32]);

    // returns the current substitution matrix
    //void getMatrix(int matrix[32][32]);

    // returns the score threshold (below which scores will not be reported)
    int getScoreThreshold() {
        return scoreThreshold;
    }

    // sets the score threshold (below which scores will not be reported)
    void setScoreThreshold(int score) {
        scoreThreshold = score;
    }

    // return the value for the number of top scores that will be reported
    int getTopScoresNum() {
        return topScoresNum;
    }

    // sets the value for the number of top scores that will be reported
    void setTopScoresNum(int num) {
        topScoresNum = num;
    }

    // returns the number of FPGAs that will be used in the alignment
    int getNumFPGAs() {
        return numFPGAs;
    }

    // returns the maximum number of queries allowed in a single FPGA
    int getQueriesPerFPGA(){
        return maxQueriesPerFPGA;
    }

    // selects the active bitfile based upon the maximum query length
    void setActiveBitfile(int maxQueryLength);
    
    // selects the active bitfile name based upon the input string
    void setActiveBitfile(int maxQueryLength, const char* newBitfileName);

    // returns the maximum query length for this run
    int getMaxQueryLength(){
        return maxQueryLength;
    }

    // returns the name of the active bitfile
    string getActiveBitfile(){
        return activeBitfile;
    }
    
    // returns the name of the input argument bitfile
    string getBitfile(){
        return bitFile;
    }

private:

    // prints the proper usage for the command-line arguments
    void printUsage();

    // sets the default arguments
    void setDefaultArgs();

    // checks that the input matrix is mirrored about the diagonal
    void checkMatrix(int matrix[32][32]);

    // sets the supported bitfile names
    void setBitFileNames(){
        // query length = 0 is simulation model
        bitFileNames[0]     = "/home/pico/PicoBASe/SmithWaterman/firmware/m505lx325.fwproj";
        bitFileNames[25]    = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[50]    = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[75]    = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[100]   = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[150]   = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[200]   = "../firmware/M505_LX325T_SmithWaterman.bit";
        bitFileNames[250]   = "../firmware/M505_LX325T_SmithWaterman.bit";
    }

    // sets the supported number of queries in a single FPGA
    // Note: currently this is based upon the assumption that we fit 600 systolic cells in a K7325T
    void setQueriesPerFPGA(){
        queriesPerFPGA[0]   = 1;    // simulation model
        queriesPerFPGA[25]  = 24;
        queriesPerFPGA[50]  = 12;
        queriesPerFPGA[75]  = 8;
        queriesPerFPGA[100] = 6;
        queriesPerFPGA[150] = 4;
        queriesPerFPGA[200] = 3;
        queriesPerFPGA[250] = 2;
    }

    // sets the maximum number of queries per FPGA, based upon the maximum query length
    void setMaxQueriesPerFPGA(int maxQueryLength){
        maxQueriesPerFPGA = queriesPerFPGA[maxQueryLength];
    }

    static const int blosum45[32][32];
    static const int blosum50[32][32];
    static const int blosum62[32][32];
    static const int blosum80[32][32];

    // array of bitfile names for the various supported query lengths
    string bitFileNames [251];

    // the number of smith-waterman engines in a single FPGA (selectable via query length)
    int queriesPerFPGA [251];

    //gap open penalty
    int gapOpen;
    //gap extension penalty
    int gapExtend;
    //score threshold
    int scoreThreshold;
    //number of top alignment scores
    int topScoresNum;
    // number of FPGAs used in the system
    int numFPGAs;

    /*simple scoring matrix*/
    ScoreMatrix_t   ScoreMatrix;

    /*scoring matrix name*/
    string subMatName;

    /*query file name*/
    string queryFile;

    /*database file name*/
    string dbFile;
    
    /*bitfile name*/
    string bitFile;

    /*maximum query length*/
    int maxQueryLength;

    /*maximum number of queries per FPGA*/
    int maxQueriesPerFPGA;

    /*version number*/
    string version;

    /* active bitfile name*/
    string activeBitfile;
};
#endif

