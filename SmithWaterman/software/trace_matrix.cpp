#include "trace_matrix.h"

int trace_matrix_generate(int *traceback, uint64_t *buffer, int query_size, int subject_size)
{
	int **trace_matrix;
	int buffer_index=0,row_index=1, column_index=1;
	int trace_matrix_size,iter_row_index,iter_col_index,num_iter=0,iter_num=0;	
 if(PRINT)
 {
 	printf("The query size is:%d\n ",query_size);
	printf("The subject size is:%d\n ",subject_size);
 }
	int max_num_iterations=query_size+subject_size-1;	//total iterations required at the maximum
	if(PRINT)
		printf("The max_num_iterations are:%d\n ",max_num_iterations);
	bool flag=false,even;
	
	int traceback_size=query_size+subject_size-1;
//	traceback=new int[traceback_size]();	//DO NOT FORGET TO INITIALIZE THIS ARRAY IN THE CALLING FUNCTION
	
 if(PRINT)	
 	printf("The size of buffer is:%d\n",(query_size+subject_size)*2);	

	even=(((query_size+subject_size)%2)==0)?true:false;	//boolean variable which decides the calculation based on if /
//	it is even or odd
	
	
	trace_matrix_size=(query_size+1)*(subject_size+1);	//the size of the trace matrix
	
	if(PRINT)
	  printf("The size of trace_matrix is: %d\n", trace_matrix_size);

	trace_matrix = new int*[query_size+1];	//allocating the trace matrix
	for(int i=0; i<=query_size; i++)
		trace_matrix[i]=new int[subject_size+1];

	trace_matrix[0][0]=TARGET;

	for(int r_i=1; r_i<=query_size; r_i++)	//filling the first column of the traceback matrix
		trace_matrix[r_i][0]=UP;
	
	for(int c_i=1; c_i<=subject_size; c_i++)	//filling the first row of the traceback matrix
	  trace_matrix[0][c_i]=LEFT;

	if (PRINT)
	  printf("initial population of matrix\n");
	for(int n=max_num_iterations; n>0; n--)	//calculating the values of trace matrix
	{
		if(PRINT)
		  printf("The clock cycle number is: %d\n",n);
		iter_row_index=row_index;
		iter_col_index=column_index;

		if(even)
		{
			if((max_num_iterations-n)<((query_size+subject_size)/2))
				num_iter++;
			else
				num_iter--;
		}
		else
		{
			if((max_num_iterations-n)<((query_size+subject_size-1)/2))
				num_iter++;
			else if((max_num_iterations-n)==((query_size+subject_size-1)/2))
				num_iter=num_iter;
			else
				num_iter--;
		}
		
 if(PRINT)
	printf("The value of num_iter is:%d\n ",num_iter);
		iter_num=0;
		for(int iter=0;(iter<num_iter)&&(iter_row_index>0)&&(iter_col_index<subject_size);iter++)	//the number of matrix elements filled at each iteration
		{
			 if(PRINT)
			 {
			//	printf("The value of iter is:%d\n ",iter);
			//	printf("The value of iter_num is:%d\n ",iter_num);
			 }
			if(iter_num==64)	//since we have buffer size as 64 bits
			{
				buffer_index++;
        iter_num=0;
        flag=true;
			}

			if(PRINT)
			{
			//	printf("The value of buffer_index is:%d\n ",buffer_index);
			//	printf("The value of iter_row_index is:%d\n ",iter_row_index);
			//	printf("The value of iter_col_index is:%d\n ",iter_col_index);
			}
			//the actual assignment at each iteration
			trace_matrix[iter_row_index][iter_col_index]=((buffer[buffer_index]>>iter_num)&3);
			
			if(PRINT) {
			//  printf("The Trace Matrix Element is:%d\t%d\t%d\n ",trace_matrix[iter_row_index][iter_col_index],iter_row_index,iter_col_index);
			}
	    iter_row_index--;
      iter_col_index++;
      iter_num+=2;
		}
if(PRINT){
        printf("We are here\n ");
	printf("The value of row index is: %d\n", row_index);
	printf("The value of col index is: %d\n", column_index);
	printf("The value of buffer_index is: %d\n", buffer_index);
}
		if(row_index<query_size)
			row_index++;
		else
			column_index++;

		if(flag){
			buffer_index++;
			flag=false;
		}
		else
			buffer_index+=2;
	if(PRINT)
                  printf("The clock cycle number at the end is: %d\n",n);	
	}
	if(PRINT)
          printf("We are here again\n");
	// if(PRINT)
	// {
	//   cout<<"The trace matrix is:"<<'\n';
	// 	for(int i=0;i<=query_size;i++)
	// 	{
	// 		for(int j=0;j<=subject_size;j++)
	// 			cout<<trace_matrix[i][j]<<'\t';
	// 		cout<<'\n';
	// 	}
	// 	cout<<'\n';
	// }
	
	if(PRINT)
	  printf("Calling traceback function\n");

int err=traceback_function(trace_matrix,traceback,query_size,subject_size);	//the function which computes the traceback
	
	if(PRINT)
          printf("Traceback function completed\n");	
	// if(PRINT)
	// {
	// 	for(int j=0;j<=traceback_size;j++)
	// 		{
	// 			cout<<traceback[j]<<'\t';
	// 			if(traceback[j]==7)
	// 				break;
	// 		}
	// 	cout<<'\n';
	// }

	for(int i=0; i<=query_size; i++)
		delete trace_matrix[i];
	delete trace_matrix;

	return err;
}
