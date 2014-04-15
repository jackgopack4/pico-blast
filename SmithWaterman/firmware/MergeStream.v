/*
* File Name     : MergeStream.v
*
* Author        : Corey Olson
*
* Description   : This module accepts 2 input streams, and its job is to merge
*                 that data into a single output stream.  Essentially, this
*                 module needs to take some results from the SmWaWrapper and
*                 merge them back into the data that was stored in the bypass
*                 FIFO.
*
*                 -Format of data on input stream 1 (from SmWaWrapper):
*                 TX #      bits                                                    Description
*                 -------------------------------------------------------------------------------------
*                 0         2*SCORE_W+2*T_POS_W+Q_POS_W-1 : 2*SCORE_W+2*T_POS_W     local score query base
*                           2*SCORE_W+2*T_POS_W-1         : 2*SCORE_W+T_POS_W       local score target base
*                           2*SCORE_W+T_POS_W-1           : SCORE_W+T_POS_W         local score
*                           SCORE_W+T_POS_W-1             : SCORE_W                 global score target base
*                           SCORE_W-1                     : 0                       global score
*
*                 -Format of data on input stream 2 (from bypass FIFO):
*                 TX #      bits                Description
*                 --------------------------------------------
*                 0         Q_POS_W-1:0         query length
*                 1         127:0               query bases [63:0]
*                 2         127:0               query bases [127:64] 
*                 3         ...                 ...
*                 ...
*                 N-1       127:0               query bases [query length - 1:query length - 64]
*                 N         T_POS_W-1:0         target length
*                           16+SCORE_W:16       H0 = prior query-target alignment score
*                 N+1       127:0               target bases [63:0]
*                 N+2       127:0               target bases [127:64] 
*                 N+3       ...                 ...
*                 ...
*                 M-1       127:0               target bases [target length - 1:target length - 64]
*                 M         127:64              *mat
*                           63:0                m
*                 M+1       127:64              gape
*                           63:0                gapo
*                 M+2       127:64              end_bonus
*                           63:0                w
*                 M+3       127:64              *_qle
*                           63:0                zdrop
*                 M+4       127:64              *_gtle
*                           63:0                *_tle
*                 M+5       127:64              *_max_off
*                           63:0                *_gscore
*
*                 -Format of data on output stream:
*                 TX #      bits                Description
*                 --------------------------------------------
*                 0         Q_POS_W-1:0         query length
*                           16+SCORE_W:16       returned local alignment score = max
*                 1         127:0               query bases [63:0]
*                 2         127:0               query bases [127:64] 
*                 3         ...                 ...
*                 ...
*                 N-1       127:0               query bases [query length - 1:query length - 64]
*                 N         T_POS_W-1:0         target length
*                           16+SCORE_W:16       H0 = prior query-target alignment score
*                 N+1       127:0               target bases [63:0]
*                 N+2       127:0               target bases [127:64] 
*                 N+3       ...                 ...
*                 ...
*                 M-1       127:0               target bases [target length - 1:target length - 64]
*                 M         127:64              *mat
*                           63:0                m
*                 M+1       127:64              gape
*                           63:0                gapo
*                 M+2       127:64              end_bonus
*                           63:0                w
*                 M+3       127:64              *_qle
*                           63:0                zdrop
*                 M+4       127:64              *_gtle
*                           63:0                *_tle
*                 M+5       127:64              *_max_off
*                           63:0                *_gscore
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
module MergeStream #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation

    parameter STREAM_BASE_W             = 0,            // width of a single query/target base on the input stream

    parameter MAX_QUERY_LEN             = 0,            // maximum number of bases in a single query
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN),
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
    parameter MAX_TARGET_LEN            = 0,            // maximum sequence length on stream 1 length
    parameter T_POS_W                   = clogb2(MAX_TARGET_LEN),
                                                        // log(max_target_length) = number of bits required to store the number of bases in the target
    
    parameter SCORE_STREAM_W            = 128,          // width of the score stream
    parameter STREAM_W                  = 128,          // width of a stream
    parameter SCORE_W                   = 9,            // width of the signed score in this cell
    
    parameter NUM_EXTRA_TX              = 0,            // number of extra transfers that are sitting in the bypass FIFO (beyond the query and target data)

    parameter PICOBUS_ADDR              = 0
)
(
    // The clk and rst signals are shared between all the streams in this module,
    //   which are: stream #1 in, and stream #1 out.
    input                               clk,
    input                               rst,
    
    // this is the data that we receive from the SmWaWrapper module
    input                               s1i_valid,
    output reg                          s1i_rdy,
    input       [SCORE_STREAM_W-1:0]    s1i_data,

    // this is the data that we receive from the bypass FIFO
    input                               s2i_valid,
    output reg                          s2i_rdy,
    input       [STREAM_W-1:0]          s2i_data,
    
    // this is the result of the merge.  this data is sent to the output
    // stream
    output reg                          s1o_valid,
    input                               s1o_rdy,
    output reg  [STREAM_W-1:0]          s1o_data,
    
    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input                               PicoClk, 
    input                               PicoRst,
    input  [31:0]                       PicoAddr,
    input  [31:0]                       PicoDataIn, 
    input                               PicoRd, 
    input                               PicoWr,
    output reg [31:0]                   PicoDataOut
);
    
    //////////////////////
    // LOCAL PARAMETERS //
    //////////////////////

    // width of the input reference data bus and the reference data shift
    // register
    localparam BASES_PER_TX             = STREAM_W / STREAM_BASE_W;
    
    // = log(BASES_PER_TX)
    localparam LOG_BASES_PER_TX         = clogb2(BASES_PER_TX);
    
    // the max between the Q_POS_W and the T_POS_W
    localparam MAX_POS_W                = max(Q_POS_W,T_POS_W);

    ///////////////
    // FUNCTIONS //
    ///////////////
    
    // computes ceil( log( x ) ) 
    function integer clogb2;
        input [31:0] value;
        begin
            value = value - 1;
            // want log2(0) = 1
            if (value == 0) begin
                value = 1;
            end
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
                value = value >> 1;
            end
        end
    endfunction
    
    // computes the max between 2 integers
    // does not tell you which one is the max, just returns the largest value
    function integer max;
        input integer a;
        input integer b;
        max = (a < b) ? b : a;
    endfunction
    
    // extracts the length field from the header info on the input stream
    function [MAX_POS_W-1:0] GetLength;
        input   [STREAM_W-1:0]  data;
        input                   isTarget;
        begin
            // the query length field may be different than the target length
            // field, so we must extract only those length bits
            // if we are getting the target length
            if (isTarget) begin
                GetLength = data[T_POS_W-1:0];
            end
            // else we are getting the query length
            else begin
                GetLength = data[Q_POS_W-1:0];
            end
        end
    endfunction
    
    // extracts the local field from the stream of data from the SmWaWrapper
    // module
    function signed [SCORE_W-1:0] GetScore;
        input   [STREAM_W-1:0]  data;
        input                   isLocal;
        begin
            if (isLocal) begin
                GetScore        = data [2*SCORE_W+T_POS_W-1           : SCORE_W+T_POS_W     ];
            end else begin
                GetScore        = data [SCORE_W-1                     : 0                   ];
            end
        end
    endfunction

    // extracts the global/local query/target alignment base index from the 
    // SmWaWrapper data stream
    // Note that in global alignment, the global alignment query base is
    // always the last base in the query
    function    [63:0]          GetBase;
        input   [STREAM_W-1:0]  data;
        input                   isTarget;
        input                   isGlobal;
        begin
            if (isGlobal) begin
                GetBase         = data  [SCORE_W+T_POS_W-1             : SCORE_W            ];
            end else if (isTarget) begin
                GetBase         = data  [2*SCORE_W+2*T_POS_W-1         : 2*SCORE_W+T_POS_W  ];
            end else begin
                GetBase         = data  [2*SCORE_W+2*T_POS_W+Q_POS_W-1 : 2*SCORE_W+2*T_POS_W];
            end
        end
    endfunction
    
    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////

    // our state register
    reg     [10:0]                  state=0;
    reg     [10:0]                  nextState=0;
    
    // these are control signals that we assert to load the info about the
    // sequence (e.g. length, etc.)
    reg                             loadInfo=0;

    // when this flag is asserted, we want to load the number of extra data
    // transfers into the txRemaining register
    reg                             loadExtra=0;

    // this signal is used to load the output data register
    // when asserted, the output register should be loaded w/ next_s1o_data
    reg                             loadData=0;

    // this is the data to be loaded into the output stream register. this
    // gets set by our state machine
    reg     [STREAM_W-1:0]          next_s1o_data=0;
    reg                             next_s1o_valid=0;

    // this is the length of the query/target sequence in bases
    wire    [MAX_POS_W-1:0]         nextLength;
    reg     [MAX_POS_W-1:0]         txRemaining;
    reg     [MAX_POS_W-1:0]         nextLength_1;

    // this is asserted if we are processing the target, else we are processing
    // the query
    reg                             doTarget=0;

    // this is just a temporary variable that we use to compute and then
    // sign-extend the new score
    reg     [SCORE_W-1:0]           score;

    /////////
    // FSM //
    /////////

    // states
    localparam  WAIT        = 'b00000000001,    // wait for valid input data on s1i
                HEADER_Q    = 'b00000000010,    // send the header for the query
                DATA_Q      = 'b00000000100,    // send the data for the query
                INFO_T      = 'b00000001000,    // load the info for the target
                HEADER_T    = 'b00000010000,    // send the header for the target
                DATA_T      = 'b00000100000,    // load the data for the target
                LOAD_EXTRA  = 'b00001000000,    // load the number fo extra TX into txRemaining
                EXTRA       = 'b00010000000,    // send the extra transfers to s1o
                Q_BASE      = 'b00100000000,    // send the ending query base to s1o
                T_BASE      = 'b01000000000,    // send the ending target base to s1o (both global and local)
                G_SCORE     = 'b10000000000;    // send the global alignment score to s1o
    // FSM
    always @ (posedge clk) begin
        if (rst) begin
            state   <= WAIT;
        end else begin
            state   <= nextState;
        end
    end

    // next state logic
    always @ (*) begin

        nextState       = state;
        doTarget        = 0;
        loadInfo        = 0;
        loadData        = 0;
        score           = 'hX;
        next_s1o_data   = 'hX;
        next_s1o_valid  = 0;
        s1i_rdy         = 0;
        s2i_rdy         = 0;
        loadExtra       = 0;
        
        case (state)

            // wait for valid result data from the SmWaWrapper.  we need valid
            // data, because we must embed the returned local alignment score
            // in the first transfer to s1o
            // Note: we assume that if we get a valid result from SmWaWrapper,
            // then we must at least have all query and target header and
            // sequence data in the side-band FIFO (s2i)
            WAIT: begin
                loadInfo            = 1;
                if (s1i_valid) begin
                    nextState       = HEADER_Q;
                end
            end

            // in this state, we send the query header from input stream 2,
            // but we also insert the local alignment score from stream 1 into
            // the header
            // Note: in this state, we know we just came from WAIT, where we
            // already checked for valid input data. therefore, we know that
            // s1i_valid and s2i_valid are asserted
            HEADER_Q: begin

                // we can accept the header from the sideband fifo if we can
                // load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;

                // this is the new header that we are forming for the output
                // stream
                score               = GetScore(s1i_data,1);
                next_s1o_valid      = 1;
                next_s1o_data[31:16]= {{(16-SCORE_W){score[SCORE_W-1]}},score};
                next_s1o_data[15:0] = nextLength_1;
                
                // now send the query header to the output stream
                if (s2i_rdy) begin
                    loadData        = 1;
                    nextState       = DATA_Q;
                end
            end

            // in this state, we send the query sequence to the output stream.
            // recall that we've already assumed the entire query and target
            // sequences are in the side-band FIFO, so don't need to check for
            // valid data in that FIFO
            DATA_Q: begin
                
                // we can accept query sequence data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;
                
                // just want to pass the data from the sideband fifo to the
                // output here
                next_s1o_data       = s2i_data;
                next_s1o_valid      = 1;

                // we are done sending data when we are sending a transaction,
                // and it is the last one
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (txRemaining == 1) begin
                        nextState   = INFO_T;
                    end
                end
            end

            // load the info for the next target sequence from the sideband fifo
            // we load this info into our txRemaining register
            INFO_T: begin
                doTarget            = 1;
                loadInfo            = 1;
                nextState           = HEADER_T;
            end

            // in this state, we send the target header to the output stream
            // from the sideband fifo.  we do not insert any additional data
            // recall that we've already assumed the entire query and target
            // sequences are in the side-band FIFO, so don't need to check for
            // valid data in that FIFO
            HEADER_T: begin
                doTarget            = 1;
                
                // we can accept the header from the sideband fifo if we can
                // load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;

                // we send the unmodified target header from the sideband fifo
                next_s1o_data       = s2i_data;
                next_s1o_valid      = 1;

                // we are only sending a single transfer (the header) to the
                // output stream
                if (s2i_rdy) begin
                    loadData        = 1;
                    nextState       = DATA_T;
                end
            end
            
            // in this state, we send all the target data from the sideband
            // fifo to the output stream
            // recall that we've already assumed the entire query and target
            // sequences are in the side-band FIFO, so don't need to check for
            // valid data in that FIFO
            DATA_T: begin
                doTarget            = 1;

                // we can accept target sequence data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;
                
                // just want to pass the data from the sideband fifo to the
                // output here
                next_s1o_data       = s2i_data;
                next_s1o_valid      = 1;

                // we are done sending data when we are sending a transaction,
                // and it is the last one
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (txRemaining == 1) begin
                        nextState   = LOAD_EXTRA;
                    end
                end
            end

            // in this state, we load a number into our txRemaining register
            // this represents the number of extra TX that we need to pull out
            // of the sideband FIFO, beyond just the query and target data
            LOAD_EXTRA:  begin
                loadExtra           = 1;
                if (NUM_EXTRA_TX > 0) begin
                    nextState       = EXTRA;
                end else begin
                    nextState       = Q_BASE;
                end
            end

            // this this state, we have NUM_EXTRA_TX transfers that we
            // need to send to the output stream from the sideband fifo (s2i)
            EXTRA: begin

                // we can accept this extra data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;
                
                // just want to pass the data from the sideband fifo to the
                // output here
                next_s1o_data       = s2i_data;
                next_s1o_valid      = s1i_valid;
                
                // send the data to the output stream by asserting loadData
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (s2i_valid && (txRemaining == 1)) begin
                        nextState   = Q_BASE;
                    end
                end
            end
            
            // we stay in this state for exactly 1 transfer to the output
            // stream
            // it's purpose is to insert the query alignment base index for
            // local alignment into the output stream.  this query alignment
            // base should come from the SmWaWrapper stream (s1i)
            Q_BASE: begin
                
                // we can accept this extra data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;

                // we take the ZDROP parameter from the sideband fifo and we
                // insert the local alignment query base index for this
                // transfer to the output stream
                next_s1o_data       = { GetBase(s1i_data,0,0),
                                        s2i_data[63:0]};
                next_s1o_valid      = s2i_valid;

                // send the data to the output stream by asserting loadData
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (s2i_valid) begin
                        nextState   = T_BASE;
                    end
                end

            end
            
            // we stay in this state for exactly 1 transfer to the output
            // stream
            // it's purpose is to insert the target alignment base indices for
            // local and global alignment into the output stream.  
            // these target alignment bases should come from the 
            // SmWaWrapper stream (s1i)
            T_BASE: begin
                
                // we can accept this extra data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;

                // all of our data in this state comes from the s1i stream
                next_s1o_data       = { GetBase(s1i_data,1,1),
                                        GetBase(s1i_data,1,0)};
                next_s1o_valid      = s2i_valid;

                // send the data to the output stream by asserting loadData
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (s2i_valid) begin
                        nextState   = G_SCORE;
                    end
                end

            end
            
            // we stay in this state for exactly 1 transfer to the output
            // stream
            // it's purpose is to insert the global alignment score into the
            // output stream.  this alignment score should come from the
            // SmWaWrapper input stream (s1i)
            G_SCORE: begin
                
                // we can accept this extra data from the sideband fifo if 
                // we can load it into our output register
                s2i_rdy             = ~s1o_valid | s1o_rdy;

                // we take the _max_off parameter from the sideband fifo and we
                // insert the global alignment score for this transfer to the
                // output stream
                // Note: assume the score should be 16 bits on the output
                // stream
                score               = GetScore(s1i_data,0);
                next_s1o_valid      = s2i_valid;
                next_s1o_data[127:16]= s2i_data[127:16];
                next_s1o_data[15:0] = {{(16-SCORE_W){score[SCORE_W-1]}},score};

                // send the data to the output stream by asserting loadData
                if (s2i_rdy) begin
                    loadData        = 1;
                    if (s2i_valid) begin
                        s1i_rdy     = 1;
                        nextState   = WAIT;
                    end
                end

            end
        endcase
    end

    /////////////////
    // STREAM INFO //
    /////////////////

    // compute what our next length would be
    // this is mainly used to compute the number of transfers required to get
    // all the data for a query/target sequence from the input stream
    assign nextLength = GetLength(s2i_data, doTarget);

    // track the number of transactions that we have remaining until we have
    // sent all the required transfers from s2i
    always @ (posedge clk) begin
        if (loadExtra) begin
            txRemaining             <= NUM_EXTRA_TX;
        end else if (loadInfo) begin
            txRemaining             <= 1 + ((nextLength + BASES_PER_TX - 1) >> LOG_BASES_PER_TX);
        end else if (s2i_valid && s2i_rdy) begin
            txRemaining             <= txRemaining - 1;
        end
        nextLength_1                <= nextLength;
    end
    
    /////////////////
    // STREAM DATA //
    /////////////////
    
    // this is just a debug counter that is later reported via the PicoBus
    // we declare it here, becase we want to print its value whenever we
    // accept a new piece of data to be sent to ouput stream 1
    reg     [31:0]                  s1o_count;          // number of transfers to output stream 1

    // here we create the output register for stream 1
    always @ (posedge clk) begin
        if (rst) begin
            s1o_data                <= 'hX;
            s1o_valid               <= 0;
        end else if (loadData) begin
            s1o_valid               <= next_s1o_valid;
            s1o_data                <= next_s1o_data;
            if (VERBOSE && next_s1o_valid) begin
`ifdef ASCII_INPUT_DATA
                if (state == DATA_Q || state == DATA_T) begin
                    $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%s", $realtime, NAME, s1o_count, next_s1o_data);
                end else begin
                    $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%h", $realtime, NAME, s1o_count, next_s1o_data);
                end
`else
                $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%h", $realtime, NAME, s1o_count, next_s1o_data);
`endif
            end            
        end else if (s1o_rdy) begin
            s1o_data                <= 'hX;
            s1o_valid               <= 0;
        end
    end
    
    ///////////
    // DEBUG //
    ///////////
    
    // debug counters / registers
    reg     [31:0]                  status;             // current status of specified signals
    reg     [31:0]                  s1i_count;          // number of transfers from input stream 1
    reg     [31:0]                  s2i_count;          // number of transfers from input stream 2
    wire    [31:0]                  version = 32'h0002; // version 0x0101 = version 1.1

    always @ (posedge clk) begin
        if (rst) begin
            s1o_count               <= 0;
            s1i_count               <= 0;
            s2i_count               <= 0;
        end else begin
            // 1) count the number of transactions accepted from the input stream 1
            if (s1i_valid && s1i_rdy) begin
                //if (VERBOSE) $display("%t : %s : receiving data [%0d] from input stream 1 = 0x%h", $realtime, NAME, s1i_count, s1i_data);
                s1i_count           <= s1i_count + 1;
            end
            // 2) count the number of transactions accepted from the input stream 2
            if (s2i_valid && s2i_rdy) begin
                //if (VERBOSE) $display("%t : %s : receiving data [%0d] from input stream 2 = 0x%h", $realtime, NAME, s2i_count, s2i_data);
                s2i_count           <= s2i_count + 1;
            end
            // 3) count the number of transfers sent to output stream 1
            if (s1o_valid && s1o_rdy) begin
                s1o_count           <= s1o_count + 1;
                //if (VERBOSE) $display("%t : %s : sending data [%0d] to output stream 1 = 0x%h", $realtime, NAME, s1o_count, s1o_data);
            end
        end
        // 4) output some status signals
        status                      <= {loadData,
                                        loadExtra,
                                        doTarget,
                                        loadInfo,
                                        1'b0,
                                        state,
                                        2'b0,
                                        s1i_valid,
                                        s1i_rdy,
                                        s1o_valid,
                                        s1o_rdy,
                                        s2i_valid,
                                        s2i_rdy};
    end

    /////////////
    // PICOBUS //
    /////////////

    // registered version of some counters / status
    (* shreg_extract = "no" *)
    reg     [31:0]                  status_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  status_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s1i_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s1i_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s1o_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s1o_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s2i_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s2i_count_2;
    always @ (posedge PicoClk) begin
        status_1        <= status;
        status_2        <= status_1;
        s1i_count_1     <= s1i_count;
        s1i_count_2     <= s1i_count_1;
        s1o_count_1     <= s1o_count;
        s1o_count_2     <= s1o_count_1;
        s2i_count_1     <= s2i_count;
        s2i_count_2     <= s2i_count_1;
    end
    
    // set control registers via the PicoBus
    // read status information via the PicoBus
    always @ (posedge PicoClk) begin
        if (PicoRst) begin
            PicoDataOut    <= 0;
        end else if (PicoWr) begin
            PicoDataOut    <= 0;
        end else if (PicoRd) begin
            PicoDataOut    <= 0;
            case (PicoAddr)
                (PICOBUS_ADDR+32'h00):  PicoDataOut<= version;
                (PICOBUS_ADDR+32'h10):  PicoDataOut<= s1i_count_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOut<= s1o_count_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOut<= status_2;
                (PICOBUS_ADDR+32'h40):  PicoDataOut<= s2i_count_2;
            endcase
        end else begin
            PicoDataOut    <= 0;
        end
    end

endmodule 
