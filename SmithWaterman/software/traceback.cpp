#include "traceback.h"

int traceback_function(int **trace_matrix,int *traceback, int query_size, int subject_size)
{
	int traceback_index=0,row_index, column_index;

	row_index=query_size;	//the last row of the matrix from the traceback will start
	column_index=subject_size;	//the last column of the matrix from the traceback will start
	
	while(traceback_index<(query_size+subject_size-1))	//till we reach the start of traceback matrix
	{
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
		if((row_index==0)&&(column_index==0))	//traced back to the target
		{
			traceback[traceback_index]=DONE;
			traceback_index=query_size+subject_size;
		}
	}
	
	return 1;
}
