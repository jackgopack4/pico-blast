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
#define DIAGONAL 3
#define UP 2
#define LEFT 1
#define MATCH 4
#define GAP_IN_QUERY 5	//LEFT
#define GAP_IN_SUBJECT 6 //UP
#endif	//TRACEBACK