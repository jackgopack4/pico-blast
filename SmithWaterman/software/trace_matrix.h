/*
* File Name	: trace_matrix.h
*
* Description	: This is the header file for the file which receives the values of traceback data from a stream from FPGA.
*                       This is then stored in a 2D matrix which is then sent to another function to
*                       perform the calculation of the traceback result. 
*
*/
#ifndef TRACE_MATRIX
#define TRACE_MATRIX
//#include <iostream>
#include "traceback.h"
#include "PicoSW.h"
//#include<cstdint>
//#include<vector>
using namespace std;
int trace_matrix_generate(int *,uint64_t*,int,int);
int get_size(int);
//typedef unsigned long long uint64_t;
#define BUFFER_WIDTH 64
#define PRINT 0
#define TARGET 7
#define DIAGONAL 3
#define UP 2
#define LEFT 1
#endif  //TRACE_MATRIX

