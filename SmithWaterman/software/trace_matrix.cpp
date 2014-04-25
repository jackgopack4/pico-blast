#include "trace_matrix.h"

int trace_matrix_generate(int *traceback; uint64_t *buffer; int query_size; int subject_size;)
{
	int **trace_matrix;
	int buffer_index=0,row_index=1, column_index=1;
	int trace_matrix_size,iter_row_index,iter_col_index,num_iter=0,iter_num=0;	
	if(PRINT)
	{
		cout<<"Enter the query size: "<<query_size;
		cout<<'\n';
		cout<<"Enter the subject size: "<<subject_size;
  	cout<<'\n';
	}
	int max_num_iterations=query_size+subject_size-1;	//total iterations required at the maximum
	if(PRINT)
		cout<<"The max_num_iter is: "<<max_num_iterations<<'\n';
	bool flag=false,even;
	
	int traceback_size=query_size+subject_size-1;
//	traceback=new int[traceback_size]();	//DO NOT FORGET TO INITIALIZE THIS ARRAY IN THE CALLING FUNCTION
	
	if(PRINT)	
		cout<<"The size of buffer is:"<<(query_size+subject_size)*2<<'\n';	

	even=(((query_size+subject_size)%2)==0)?true:false;	//boolean variable which decides the calculation based on if /
//	it is even or odd
	
	
	trace_matrix_size=(query_size+1)*(subject_size+1);	//the size of the trace matrix
	
	if(PRINT)
		cout<<"The size of trace_matrix is:"<<trace_matrix_size<<'\n';

	trace_matrix = new int*[query_size+1];	//allocating the trace matrix
	for(int i=0; i<=query_size; i++)
		trace_matrix[i]=new int[subject_size+1];

	trace_matrix[0][0]=TARGET;

	for(int r_i=1; r_i<=query_size; r_i++)	//filling the first column of the traceback matrix
		trace_matrix[r_i][0]=UP;
	
	for(int c_i=1; c_i<=subject_size; c_i++)	//filling the first row of the traceback matrix
    trace_matrix[0][c_i]=LEFT;

	for(int n=max_num_iterations; n>0; n--)	//calculating the values of trace matrix
	{
		if(PRINT)
			cout<<"The clock cycle number is: "<<n<<'\n';
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
			cout<<"The value of num_iter is: "<<num_iter<<'\n';
		iter_num=0;
		for(int iter=0;iter<num_iter;iter++)	//the number of matrix elements filled at each iteration
		{
			if(PRINT)
			{
				cout<<"The iteration number is: "<<iter<<'\n';
				cout<<"The iter number is: "<<iter_num<<'\n';
			}
			if(iter_num>=64)	//since we have buffer size as 64 bits
			{
				buffer_index++;
        iter_num=0;
        flag=true;
			}

			if(PRINT)
			{
				cout<<"The buffer index is: "<<buffer_index<<'\n';
				cout<<"The iteration row index is: "<<iter_row_index<<'\n';
				cout<<"The iteration column index is: "<<iter_col_index<<'\n';
			}
			//the actual assignment at each iteration
			trace_matrix[iter_row_index][iter_col_index]=((buffer[buffer_index]>>iter_num)&3);
			
			if(PRINT)
				cout<<"The Trace Matrix Element is: "<<trace_matrix[iter_row_index][iter_col_index]<<'\n';
  
	    iter_row_index--;
      iter_col_index++;
      iter_num+=2;
		}

		if(row_index<query_size)
			row_index++;
		else
			column_index++;

		if(flag)
			buffer_index++;
		else
			buffer_index+=2;
		
		flag=false;
	}

	if(PRINT)
	{
		cout<<"The trace matrix is:"<<'\n';
		for(int i=0;i<=query_size;i++)
		{
			for(int j=0;j<=subject_size;j++)
				cout<<trace_matrix[i][j]<<'\t';
			cout<<'\n';
		}
		cout<<'\n';
	}
	
	traceback_function(trace_matrix,traceback,query_size,subject_size);	//the function which computes the traceback
	
	if(PRINT)
	{
		for(int j=0;j<=traceback_size;j++)
			{
				cout<<traceback[j]<<'\t';
				if(traceback[j]==7)
					break;
			}
		cout<<'\n';
	}

	for(int i=0; i<=query_size; i++)
		delete trace_matrix[i];
	delete trace_matrix;

	return 1;
}
