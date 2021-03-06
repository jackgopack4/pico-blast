/*
* File Name	: traceback.cpp
*
* Description	: This file takes the 2D trace matrix calculated based on the traceback
*			stream received from FPGA and computes the actual traceback path.
*			This function can basically be described as flattening of the 2D 
*			trace matrix in to a 1D traceback path.
*/

#include "traceback.h"

int traceback_function(int **trace_matrix,int *traceback, int query_size, int subject_size)
{
	int traceback_index=0,row_index, column_index;
	int size;	//this is the actual size of the traceback matrix

	row_index=query_size;	//the last row of the matrix from the traceback will start
	column_index=subject_size;	//the last column of the matrix from the traceback will start

	if(PRINTING)
		printf("Starting traceback\n");	
	while(traceback_index<(query_size+subject_size-1))	//till we reach the start of traceback matrix
	{
	if(PRINTING)
                printf("Traceback index is: %d\n",traceback_index); 
		if(trace_matrix[row_index][column_index]==DIAGONAL)	//if we get a MATCH
		{
			traceback[traceback_index]=MATCH;
			traceback_index++;
			row_index--;
			column_index--;
		}
		else if(trace_matrix[row_index][column_index]==UP)	//indicates a gap in db (insertion)
		{
			traceback[traceback_index]=GAP_IN_SUBJECT;
			traceback_index++;
			row_index--;
		}
		else if(trace_matrix[row_index][column_index]==LEFT)	//indicates a gap in query(deletion)
		{
			traceback[traceback_index]=GAP_IN_QUERY;
      traceback_index++;
			column_index--;
		}
		else if(trace_matrix[row_index][column_index]==INVALID)
		{
			return 0;
		}
		if((row_index==0)&&(column_index==0))	//traced back to the target
		{
			traceback[traceback_index]=DONE;
			break;
		}
	}
	size=traceback_index;
	
	return size;
}
