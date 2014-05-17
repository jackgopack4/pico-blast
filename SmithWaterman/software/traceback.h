/*
* File Name : traceback.h
*
* Description : This is the header file for the file that takes the 2D trace matrix calculated based on the traceback
*     stream received from FPGA and computes the actual traceback path.
*     This function can basically be described as flattening of the 2D 
*     trace matrix in to a 1D traceback path.
*/

#ifndef TRACEBACK
#define TRACEBACK
//#include <iostream>
#include "trace_matrix.h"
//#include<vector>
//using namespace std;
//#include "PicoSw.h"
int traceback_function(int **,int*,int,int);
#define PRINTING 0
#define DONE 7
#define INVALID 0
#define MATCH 4	//DIAGONAL
#define GAP_IN_QUERY 5	//LEFT
#define GAP_IN_SUBJECT 6 //UP
#endif	//TRACEBACK
