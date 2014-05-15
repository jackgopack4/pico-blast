/*
 * File Name     : PicoBlastScan.v
 *
 * Creation Date : Mon 25 Feb 2013 11:07:53 AM CDT
 *
 * Author        : Yashwardhan Singh 
 *
 * Last Modified : Wed 03 Apr 2013 09:10:32 AM CDT
 *
 * Description   : 

 */

`include "PicoDefines.v"

module PicoBlastScan #(
		       parameter NAME                      = "PicoBlastScan",           
                       // name of this module
		       parameter VERBOSE                   = 0,            // set to 1 for verbose debugging statements in simulation
		       parameter PICOBUS_ADDR              = 0             // base address for reading/writing this module via the PicoBus
		       )
   (
    // The clk and rst signals are shared between all the streams in this module
    input 	       clk,
    input 	       rst,

    ///////////////////
    // Stream 1 ///////
    ///////////////////
   
    // Stream 1 - Used for writing Database Sequence : Using input lines

    input 	       s1i_valid,
    output 	       s1i_rdy,
    input [127:0]      s1i_data,
   
    output 	       s1o_valid,
    input 	       s1o_rdy,
    output [127:0]     s1o_data,

    ///////////////////
    // Stream 2 ///////
    ///////////////////

    // Stream 2 - Used for writing Database Offset and Query Offset	

    input 	       s2i_valid,
    output 	       s2i_rdy,
    input [127:0]      s2i_data,
   
    output 	       s2o_valid,
    input 	       s2o_rdy,
    output [127:0]     s2o_data,


    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input 	       PicoClk, 
    input 	       PicoRst,
    input [31:0]       PicoAddr,
    input [127:0]      PicoDataIn, 
    input 	       PicoRd, 
    input 	       PicoWr,
    output reg [127:0] PicoDataOut
    );

   ////////////////
  // PARAMETERS //
  ////////////////
    
   // all the parameters that get used in this system are set in this file
   //   `include "PicoBlastScanParameters.v"

   //////////////////////
   // INTERNAL SIGNALS //
   //////////////////////


   // Input signals
   wire 	       si_valid        [0:1];
   wire 	       si_rdy          [0:1];
   wire [127:0]        si_data         [0:1];
   
   // Output signals
   wire 	       so_valid        [0:1];
   wire 	       so_rdy          [0:1];
   wire [127:0]        so_data         [0:1];
   

   /////////////////////////////
   // ASSIGNING ALL THE WIRES //
   /////////////////////////////

   // Store the input and output signals in the array. These array
   // elements can be easiy accessed in the generate for loop.

   // Stream 0
   assign si_valid [0] = s1i_valid;
   assign si_data  [0] = s1i_data;
   assign s1i_rdy      = si_rdy    [0];

   assign s1o_valid    = so_valid  [0];
   assign s1o_data     = so_data   [0];
   assign so_rdy   [0] = s1o_rdy;
   assign si_rdy[0] = buffer_empty;

   // Stream 1

   assign si_rdy[1] = ~(sending_data);
   assign so_valid[1]= sending_data_to_stream;

   assign si_valid [1] = s2i_valid;
   assign si_data  [1] = s2i_data;
   assign s2i_rdy      = si_rdy    [1];
   
   assign s2o_valid    = so_valid  [1];
   assign s2o_data     = subject_send_data[127:0];
   assign so_rdy   [1] = s2o_rdy;



   // Regisster Declarations to be used for BLast Scan function

   // Register to store the Query  
   reg [1:0] 	       query_reg [4095:0];
   reg [1:0] 	       query_reg_next [4095:0];
   reg [8191:0]        query_debug;

   // Register to store the Query length
   reg [11:0] 	       query_length;

   // Register to store the value of flag to indicate if the value present in query_length register is valid or not
   reg 		       valid_query_length;
   
   // Register to store the Subject length
   reg [31:0] 	       subject_length;

   // Register to store the value of flag to indicate if the value present in subject_length register is valid or not
   reg 		       valid_subject_length;
   reg 		       valid_query_reg;

   // Valid subject reg 
   reg 		       valid_subject_reg;

   // Register to store the Subject Sequence.It stores 32 bit subject id and last 2 bits of nucleotide base. 
   reg [1:0] 	       subject_reg [4095:0];

   // Register to store the subject buffer which is a parallel load shift register
   reg [127:0] 	       subject_buffer;	

   // Temporary register to hold the subject_buffer
   reg [127:0] 	       subject_buffer_next;	

   // Flag to indicate whether data in subject buffer is valid or not
   reg 		       valid_subject_buffer;

   // Counter to generate the subject ID
   reg [31:0] 	       subject_cntr ;
   
   // Flag to indicate if subject buffer is empty
   reg 		       buffer_empty;

   // Flag to indicate which bits in 4096 bits matched
   reg [4095:0]        found_hit;
   reg [4095:0]        found_hit_next;
   reg [4095:0]        found_hit_ff;

   // Temporary register used to store query in query _reg
   reg [127:0] 	       query_store;

   // Temporary register used to store query in query _reg
   reg [127:0] 	       query_store_next;

   // Total number of hits 
   reg [11:0] 	       hit_cnt;
   reg [11:0] 	       hit_cnt_next;
   reg [11:0] 	       hit_cnt_ff;

   // cnt is  register used for writing query
   reg [11:0] 	       cnt;

   // Loop counters
   integer 	       i,j,k,m,cntr,n,loop_cntr;

   // Auxillary registers used to store the database
   reg [9:0] 	       subject_shift_index;
   reg [31:0] 	       sub_cnt;

   // Variables for State Machine
   reg [1:0] 	       state,next_state;

   // If any hit is find in comparison of 4096 bits of query and database
   reg 		       hit_found;
   reg 		       hit_found_next;

   // Flag to indicate sending of data is complete
   reg 		       send_data_complete;
   reg 		       sending_data_to_stream;

   // Flag to indicate that data is being sent
   reg 		       sending_data;

   // Buffer to store data to be sent 
   reg [127:0] 	       subject_send_data;

   // Buffer which holds the value os subject_cntr
   reg [127:0] 	       subject_data;

   // fifo_cntr counter to keep track of how much of 4096 bytes has been sent
   reg [7:0] 	       fifo_cntr;

   reg [11:0] 	       length;
   reg [11:0] 	       temp_length;
   reg [11:0] 	       final_length;

   
   // State Variable Parameters
   parameter[1:0]      START = 2'b00;
   parameter[1:0]      CHECK_FOR_HIT = 2'b01;
   parameter[1:0]      SENDING_HITS = 2'b10;
   parameter[1:0]      ERROR_STATE = 2'b11;
   
   //-----------------------------------------------------
   // S T A T E     M A C H I N E 
   //-----------------------------------------------------


   always @(posedge clk)
     begin
	if(rst)
	  state<=START;
	else
	  state<=next_state;
     end

   /*****************************************************
    States of the State Machine
    1. START STATE - Initial State
    2. CHECK_FOR_HIT STATE - State in which comparison is made
    3. SENDING_HITS STATE - State in which data is being sent
    4. ERROR STATE - Invalid State
    *******************************************************/  

   always @(*)
     begin
	next_state = START;
	case(state)
	  START : begin
	     if(valid_subject_reg==1'b1 && valid_query_reg==1'b1)
	       next_state = CHECK_FOR_HIT;
	     else
	       next_state = START;
	  end

	  CHECK_FOR_HIT : begin
	     if(hit_found_next==1'b1) 	
	       next_state = SENDING_HITS;
	     else
	       next_state = CHECK_FOR_HIT;
	  end

	  ERROR_STATE :	  begin 
	     next_state = START;
	  end

	  SENDING_HITS :	  begin 
	     if(send_data_complete == 1'b1)
	       next_state = CHECK_FOR_HIT;
	     else
	       next_state = SENDING_HITS;  
	  end
	endcase
	
     end

   /***********************************************************
    // Writing the Query at Address starting from 0h
    // Also reading the Query length which will help 
    // us in knowing whether we are done with writing query 
    ***********************************************************/
   
   always @(posedge PicoClk)
     begin
	// If Reset
	if(PicoRst)      
	  begin
	     valid_query_length<=1'b0;
	     valid_subject_length<=1'b0;
	     query_length<=4096;
	     cnt<=0;
	     
	  end
	else
	  begin
	     // Writing the Query in the query_Store register which stores it temproraily and then is stored in query_store
	     // cnt is used to keep track of the query length and upto where in my query reg have I filled the data

             if (PicoWr && PicoAddr[31:0]!=32'h4000)
               begin
        	  query_store <= PicoDataIn[127:0];
 		  cnt<=cnt+1;
	       end
             // Used to read the query length and the database length
	     else if(PicoWr && PicoAddr[31:0]==32'h4000)
	       begin
	          query_length<=PicoDataIn[43:32];
	          subject_length<=PicoDataIn[31:0];
	          valid_query_length<=1;
	          valid_subject_length<=1;
	       end
	     // Used to write the value of total number of hits found till time using Pico Bus
	     else if(PicoRd && PicoAddr[31:0]==32'h4000)
	       begin
                  PicoDataOut<=hit_cnt_ff;
	       end
 	     // Used to write the value of subject counter on PicoBus
	     else if(PicoRd && PicoAddr[31:0]==32'h3000)
	       begin
                  PicoDataOut<=subject_cntr;
	       end
	     else
	       begin
        	  query_store <= query_store;
 		  cnt<=cnt;
	       end	
	  end	
     end

   /**************************************************************
    // Always Block to write the query in query_reg
    **************************************************************/
   always @(cnt)
     begin
	if(cnt>0)
	  begin
	     query_store_next=query_store;
	     if((cnt)*64>query_length*16)
	       begin
		  query_store_next = query_store_next << (((cnt*64)-(query_length*16))*2);
		  for(i=0;i<64;i=i+1)
		    begin
		       if(i<(64-(cnt*64)-(query_length*16)))
			 begin
 	     		    query_reg_next[(cnt-1)*64+i][1:0]=query_store_next[127:126];
       			    query_store_next=query_store_next<<2;
			 end
		    end
	       end
	     else
	       begin
		  for(i=0;i<64;i=i+1)
       		    begin
		       length = (cnt-1)*64+i;
 		       query_reg_next[(cnt-1)*64+i][1:0]=query_store_next[127:126];
       		       query_store_next=query_store_next<<2;
 		    end
	       end
	     if(cnt*4>=query_length && valid_query_length==1'b1)
	       begin
		  valid_query_reg=1'b1;
	       end
	     else
	       valid_query_reg=1'b0;
	  end
     end
   
   always @(posedge clk)
     begin
	for(i=0;i<4096;i=i+1)
	  query_reg[i]<=query_reg_next[i];
	final_length<=temp_length;
     end

   /**************************************************************
    // Always Block to write the Subject Sequence
    **************************************************************/

   always @(posedge clk) begin
      if (rst) begin
         // we'll start off with known reset values when the system asserts PicoRst at startup.
         valid_subject_buffer<=0;
         sub_cnt<=0;
         valid_subject_reg<=1'b0;
      end 
      else 
        begin
	   
           // Writing Subject Sequence to a buffer and signal whenever buffer is empty for the next stream to arrive
           // This buffer is used to pass the data directly to the shift register which is used for comparison
           if(si_rdy[0]==1'b1 && si_valid[0]==1'b1)
             begin
     		subject_buffer[127:0] <= si_data[0][127:0];
     		valid_subject_buffer<=1'b1;
        	sub_cnt<=sub_cnt+1;
                valid_subject_reg<=1'b1;
             end
           else
             begin
     		subject_buffer[127:0] <= subject_buffer[127:0];
     		valid_subject_buffer<=1'b0;
             end
        end // else: !if(rst)
   end // always @ (posedge PicoClk)
   


   /***************************************************************
    // Always Block which checks if current state is CHECK_FOR_HITS
    // If current state is CHECK_FOR_HIT then shift the subject_buffer register by 2 bits
    // And then shifting subject_reg by 2
    // The Shift is only done if the current state is CHECK_FOR_HIT
    ***************************************************************/
   always @(posedge clk)
     begin
        if(rst)
          begin
     	     subject_cntr<=0;
             buffer_empty<=1'b1;
             subject_shift_index<=0;
          end
        else begin
           if(state == CHECK_FOR_HIT) // Checking if the state is CHECK_FOR_HIT
             begin
     		if(subject_cntr%64==0 && subject_cntr>0 && subject_shift_index!=0) // Checking if the register is empty and we are not entering for the first time
		  begin
     		     buffer_empty<=1'b1;
		     subject_shift_index<=0;
		     subject_cntr<=subject_cntr+1;
		     
		  end
		else if(subject_shift_index==8'd0) // Checking if entering for the first time after buffer was empty
		  begin
     		     buffer_empty<=1'b0;
		     subject_shift_index<=subject_shift_index+1;
		  end
     		else
     		  begin
		     if(subject_shift_index==1'b1) 
		       begin
			  subject_buffer_next<=subject_buffer;
			  subject_shift_index<=subject_shift_index+1;
		       end
		     else
		       begin

			  // Shifting the shift register 
     			  if(valid_subject_length == 1'b1 && subject_cntr<=((subject_length*16)+(query_length*16)-1)&& found_hit_next == 1'b0)
     			    begin
     		     	       for(j=1;j<4096;j=j+1)
     		      		 subject_reg[j]<=subject_reg[j-1];
			       if(subject_cntr<subject_length*16)
     				 subject_reg[0][1:0] <= subject_buffer_next[127:126];
			       else
     				 subject_reg[0][1:0] <= 2'b0;
     			       subject_shift_index<=subject_shift_index+1;
			       if(subject_shift_index!=2)
     				 subject_cntr<=subject_cntr+1;
     			       subject_buffer_next<=subject_buffer_next<<2;
     			       buffer_empty<=1'b0;
     			       //valid_subject_reg<=1;
			    end
     		       end
     		  end // else: !if(subject_shift_index==8'd0)
		
             end // if (state == CHECK_FOR_HIT)
	   
	   else
	     begin
     		for(j=0;j<4096;j=j+1)
     		  subject_reg[j]<=subject_reg[j];
		
	     end // else: !if(state == CHECK_FOR_HIT)
	   
        end // else: !if(rst)
	
     end // always @ (posedge clk)
   
   /******************************************************
    // Always block which depending upon the state 
    // If it is CHECK_FOR_HIT then compare for hit
    // If current state is SENDING_HITS, send the data
    ******************************************************/
   always @(posedge clk)
     begin
	// If Reset
	if(rst)
	  begin
	     found_hit<=4096'b0;
	     hit_cnt<=0;
             hit_found <=1'b0;
	     send_data_complete <=1'b0;
	     sending_data_to_stream <=1'b0;
	     sending_data <=1'b0;
	  end

	
	else
	  begin
	     // If current state is CHECK_FOR_HIT then comparing for hit
	     // Using 4096 bits to indicate which offsets have a hit

             if(state == CHECK_FOR_HIT)
               begin
		  fifo_cntr<=0;
                  send_data_complete <= 1'b0;
		  sending_data <=1'b0;
        	  
               end // if (next_state == CHECK_FOR_HIT)

	     // If the present state is SENDING HITS : making sending_data as 1'b1 and reseting hit_found as 0
             // Storing the data in subject_send_data and sending it using stream 2 and then shifting it by 128	      
	     // Using fifo_cntr to keep track that how much data has been sent

	     else if(state == SENDING_HITS)
	       begin
		  if(sending_data ==1'b0)
		    begin
        	       found_hit<=found_hit_ff;
		       hit_found <=hit_found_next;
		       hit_cnt<=hit_cnt_ff;
		       sending_data <=1'b1;
		       subject_data<=subject_cntr;
		    end
		  else
		    begin
		       if(fifo_cntr !=32)
			 begin
			    found_hit <= found_hit >>128;
			    fifo_cntr <=fifo_cntr+1;
			    sending_data_to_stream<=1'b1;
			 end
		       else
			 begin
			    send_data_complete <= 1'b1;
			    sending_data_to_stream<=1'b0;
			    hit_found<=1'b0;
			 end
		    end
		  
	       end
	     
	     
	  end // else: !if(rst)
	

     end // always @ (posedge clk)


   /************************************************************************************************************
    Combination Block that operate on every clock cycle , checks for hit , if there is hit then flops the value
    and triggers the state change to SENDING_DATA
    ************************************************************************************************************/
   always@(posedge clk)
     begin
	if(state == START)
	  begin
	     hit_found_next = 0;
	     hit_cnt_next = 0;
	     found_hit_next = 0;
	  end
	else if(state == CHECK_FOR_HIT)
	  begin
	     for(k=0;k<=4096-8;k=k+1)
      	       begin
		  if(k<=query_length*16-8)
		    begin
		       if(subject_reg[(query_length*16-1)-(k)]==query_reg[k]&&subject_reg[(query_length*16-1)-(k+1)]==query_reg[k+1]
		      	  &&subject_reg[(query_length*16-1)-(k+2)]==query_reg[k+2]&&subject_reg[(query_length*16-1)-(k+3)]==query_reg[k+3]&&
		      	  subject_reg[(query_length*16-1)-(k+4)]==query_reg[k+4]&&subject_reg[(query_length*16-1)-(k+5)]==query_reg[k+5]&&
		      	  subject_reg[(query_length*16-1)-(k+6)]==query_reg[k+6]&&subject_reg[(query_length*16-1)-(k+7)]==query_reg[k+7])
        		 begin
        		    found_hit_next[k]=1'b1;
			    hit_found_next =1'b1;
			    hit_cnt_next=hit_cnt_next+1;
        		 end
		       
		       else
        		 begin
        		    found_hit_next[k]=1'b0;
        		 end // else: !if(subject_reg[k]==query_reg[k]&&subject_reg[k+1]==query_reg[k+1]...
		    end
        	  
               end // for (k=0;k<=4096-8;k=k+1)

	  end
	else if(send_data_complete==1'b1)
	  begin
	     hit_found_next = 0;
	     found_hit_next = 0;
	  end
     end

   /*****************************************************************************
    Always block which flops the value of hit_cnt and found_hit buffer whenever a hit is found
    *****************************************************************************/
   always @(hit_cnt_next)
     begin
	found_hit_ff<=found_hit_next;
        hit_cnt_ff<=hit_cnt_next;
	
     end
endmodule // PicoBlastScan






