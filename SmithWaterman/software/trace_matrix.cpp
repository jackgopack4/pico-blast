/*
* File Name	: trace_matrix.cpp
*
* Description	: This is the file which receives the values of traceback data from a stream from FPGA.
*			This is then stored in a 2D matrix which is then sent to another function to
*			perform the calculation of the traceback result. 
* 
*/


#include "trace_matrix.h"

int trace_matrix_generate(int *traceback, uint64_t *buffer, int query_size, int subject_size)
{
	int **trace_matrix;	//the 2D matrix which is calculated based on the values received from FPGA
	int buffer_index=0,row_index=1, column_index=1;	//the index which point to begin location at each iteration
	int trace_matrix_size,iter_row_index,iter_col_index,num_iter=0,iter_num=0;
	if(PRINT)
	{
		printf("The query size is:%d\n ",query_size);
		printf("The subject size is:%d\n ",subject_size);
	}
	int max_num_iterations=query_size+subject_size-1;	//total iterations required at the maximum
	int flag=get_size(query_size*2);	//based on the width of buffer
	if(PRINT){
		printf("The max_num_iterations are:%d\n ",max_num_iterations);
		printf("The flag value and buffer is : %d\n",flag);
	}
	int negflag;
	bool even;
	
	int traceback_size=query_size+subject_size-1;	//the size of the 1D traceback path array
	
 if(PRINT)	
 	printf("The size of buffer is:%d\n",(query_size+subject_size)*2);	

	trace_matrix_size=(query_size+1)*(subject_size+1);	//the size of the trace matrix
	
	if(PRINT)
	  printf("The size of trace_matrix is: %d\n", trace_matrix_size);

	trace_matrix = new int*[query_size+1];	//memory allocation of the trace matrix
	for(int i=0; i<=query_size; i++)
		trace_matrix[i]=new int[subject_size+1];

	trace_matrix[0][0]=TARGET;	//indicates that the path has been traced completely

	for(int r_i=1; r_i<=query_size; r_i++)	//filling the first column of the traceback matrix(Initialization)
		trace_matrix[r_i][0]=UP;
	
	for(int c_i=1; c_i<=subject_size; c_i++)	//filling the first row of the traceback matrix
	  trace_matrix[0][c_i]=LEFT;

	if (PRINT)
	  printf("initial population of matrix\n");
	for(int n=max_num_iterations; n>0; n--)	//calculating the values of trace matrix
	{
		if(PRINT)
		  printf("The clock cycle number is: %d\n",n);
		iter_row_index=row_index;	//the row index for each location of the matrix in single iteration
		iter_col_index=column_index;	//the column index for each location of the matrix in single iteration

		num_iter++;	//the maximum number of locations which keeps increasing for every iteration
		if(PRINT)
			printf("The value of num_iter is:%d\n ",num_iter);
		iter_num=0;
		for(int iter=0;(iter<num_iter)&&(iter_row_index>0)&&(iter_col_index<subject_size+1);iter++)	//the number of matrix elements filled at each iteration
		{
			 if(PRINT)
			 {
				printf("Stopping at : %d\n",n);
				printf("The value of iter is:%d\n ",iter);
				printf("The value of iter_num is:%d\n ",iter_num);
				printf("The value of num_iter is:%d\n ",num_iter);
			 }
			if(iter_num==BUFFER_WIDTH)	//since we contain only BUFFER_WIDTH wide information in one row
			{
				buffer_index++;
        iter_num=0;
        negflag++;
			}

			if(PRINT)
			{
				printf("The value of buffer_index is:%d\n ",buffer_index);
				printf("The value of iter_row_index is:%d\n ",iter_row_index);
				printf("The value of iter_col_index is:%d\n ",iter_col_index);
			}

			while((buffer[buffer_index]>>iter_num&3)==0)	//if the received information is invalid
			{
				iter_num+=2;
				if(iter_num==BUFFER_WIDTH)
				{
					buffer_index++;
					negflag++;
					if(negflag>flag)
						return 0;
					iter_num=0;
				}
			}	
			//the actual assignment at each iteration
			trace_matrix[iter_row_index][iter_col_index]=((buffer[buffer_index]>>iter_num)&3);

			if(PRINT)
				printf("The matrix Value at index [%d] [%d] is %lx \n",iter_row_index,iter_col_index, ((buffer[buffer_index]>>iter_num)&3));
	
			
			if(PRINT) 
			{
			  printf("The Trace Matrix Element is:%d\t%d\t%d\n ",trace_matrix[iter_row_index][iter_col_index],iter_row_index,iter_col_index);
			}
		  iter_row_index--;
	    iter_col_index++;
    	iter_num+=2;
		}
		if(PRINT)
		{
			printf("The value of row index is: %d\n", row_index);
			printf("The value of col index is: %d\n", column_index);
			printf("The value of buffer_index is: %d\n", buffer_index);
		}
		if(row_index<query_size)
			row_index++;
		else
			column_index++;
		buffer_index+=flag-negflag;
		negflag=0;
	if(PRINT)
    printf("The clock cycle number at the end is: %d\n",n);	
	}
	
	if(PRINT);
	  printf("Calling traceback function\n");
	if(PRINT)
	{
		printf("The trace matrix is: \n");
		for(int i=1;i<=query_size;i++)
		{
			for(int j=1;j<=subject_size;j++)
			{
				printf("%d\t",trace_matrix[i][j]);
			}
			printf("\n");
		}
	}

	int err=traceback_function(trace_matrix,traceback,query_size,subject_size);	//the function which computes the traceback
	if(PRINT)
          printf("Traceback function completed\n");	

	for(int i=0; i<=query_size; i++)	//de-allocating the matrix memory
		delete trace_matrix[i];
	delete trace_matrix;

	return err;
}


/* This functions returns the number of lines a single word 
* corresponds in the buffer for the traceback stream
*/
int get_size(int size)
{
	int count=0;
	if(size<BUFFER_WIDTH)
		return 1;
	else
		while((size-BUFFER_WIDTH)>0)
		{
			size-=BUFFER_WIDTH;
			count++;
		}
	count++;
	return count;
}
