/*
* File Name     : SplitStream.v
*
* Author        : Corey Olson
*
* Description   : This module splits an input stream of data into 2 output
*                 streams.  This is pretty special-case though, because we
*                 know that we are receiving a query (with a brief header) and
*                 a target sequence (also with header) that will be aligned.
*                 We also expect some extra data to follow the query and
*                 target.  Note these pieces of data must go to both output
*                 streams:
*                 1) query header
*                 2) query data
*                 3) target header
*                 4) target data*
*                 but these pieces of data ONLY go to output stream 2:
*                 1) 6 extra 128-bit transfers
*
*                 Note that this also converts the data width of stream
*                 1 input from STREAM_W to INT_STREAM_W for output stream
*                 1 only.  This is because query/target bases are assumed to
*                 be STREAM_BASE_W on the input stream, but we need them to be
*                 INT_BASE_W on the stream 1 output stream.  For the
*                 query/target header information, we truncate the input
*                 stream to fit in stream 1 output stream.  Therefore, the
*                 header information MUST NOT OCCUPY > INT_STREAM_W bits of
*                 the input stream.
*
*                 Here is the format for the data that goes to both output
*                 streams:
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
*
*                 Here is the format for the data that goes to ONLY output
*                 stream 2:
*                 TX #      bits                Description
*                 --------------------------------------------
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
module SplitStream #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation

    parameter STREAM_BASE_W             = 0,            // width of a single query/target base on the input stream
    parameter INT_BASE_W                = 0,            // width of a single query/target base on the output stream 1

    parameter MAX_QUERY_LEN             = 0,            // maximum number of bases in a single query
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN),
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
    parameter MAX_TARGET_LEN            = 0,            // maximum sequence length on stream 1 length
    parameter T_POS_W                   = clogb2(MAX_TARGET_LEN),
                                                        // log(max_target_length) = number of bits required to store the number of bases in the target
    
    parameter STREAM_W                  = 128,          // width of a stream
    parameter INT_STREAM_W              = 128,          // width of output stream 1 (Note: output stream 2 width = STREAM_W)
    
    parameter NUM_EXTRA_TX              = 0,            // number of extra transfers that get sent to stream 2 out (and not to stream 1)

    parameter PICOBUS_ADDR              = 0
)
(
    // The clk and rst signals are shared between all the streams in this module,
    //   which are: stream #1 in, and stream #1 out.
    input                               clk,
    input                               rst,
    
    // These are the signals for stream #1 INto the firmware.
    input                               s1i_valid,
    output reg                          s1i_rdy,
    input       [STREAM_W-1:0]          s1i_data,
    
    // These are the signals for stream #1 OUT of the firmware.
    // this is the data that will eventually be sent to the SmWaWrapper
    output reg                          s1o_valid,
    input                               s1o_rdy,
    output reg  [INT_STREAM_W-1:0]      s1o_data,
    
    // These are the signals for stream #2 OUT of the firmware.
    // This is the data that will be sent to the ksw_extend_fifo.
    // Note that this is a different width versus output stream 1
    output reg                          s2o_valid,
    input                               s2o_rdy,
    output reg  [STREAM_W-1:0]          s2o_data,

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
    
    // this simply truncates the input data (which is STREAM_BASE_W bits) down
    // to INT_BASE_W bits.  i.e. we actually have binary data on the input
    // stream, it's just not tightly packed.  we mainly have this here in case
    // we move to sending ASCII data at some point
    function    [INT_BASE_W-1:0]    CharToBase;
        input   [STREAM_BASE_W-1:0] char;
        begin
            CharToBase = char;
        end
    endfunction
    
    // this converts ASCII data to a N-bit-per-base encoding
    function    [INT_BASE_W-1:0]    AsciiCharToBase;
        input   [STREAM_BASE_W-1:0] char;
        begin
            case(char)
                "a":        AsciiCharToBase = 0;
                "A":        AsciiCharToBase = 0;
                "c":        AsciiCharToBase = 1;
                "C":        AsciiCharToBase = 1;
                "g":        AsciiCharToBase = 2;
                "G":        AsciiCharToBase = 2;
                "t":        AsciiCharToBase = 3;
                "T":        AsciiCharToBase = 3;
                // Note: if we use a 2-bit-per-base encoding, then this will
                // look like an 'A'
                "n":        AsciiCharToBase = 4;
                "N":        AsciiCharToBase = 4;
                default:    AsciiCharToBase = 0;
            endcase
        end
    endfunction
    
    // converts from a STREAM_BASE_W per bit encoding to a INT_BASE_W encoding
    function    [INT_STREAM_W-1:0]  ConvertBaseWidth;
        input   [STREAM_W-1:0]      stream_data;

        reg     [STREAM_BASE_W-1:0] base;
        reg     [STREAM_W-1:0]      stream_data_local;
        integer                     b;
        begin
            ConvertBaseWidth = 0;
            stream_data_local = stream_data;
            
            // extract the next base from the stream data
            // -if STREAM_W/STREAM_BASE_W is not an integer, we assume we have
            // some wasted space in the stream data at the MS bits
            for (b=0; b<BASES_PER_TX; b=b+1) begin
`ifdef ASCII_INPUT_DATA
                base = AsciiCharToBase(stream_data_local);
`else
                base = CharToBase(stream_data_local);
`endif
                ConvertBaseWidth = ConvertBaseWidth | (base << (b*INT_BASE_W));
                stream_data_local = stream_data_local >> STREAM_BASE_W;
            end
        end
    endfunction

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////

    // our state register
    reg     [7:0]                   state=0;
    reg     [7:0]                   nextState=0;
    
    // these are control signals that we assert to load the info about the
    // sequence (e.g. length, etc.)
    reg                             loadInfo=0;

    // when this flag is asserted, we want to load the number of extra data
    // transfers into the txRemaining register
    reg                             loadExtra=0;

    // this signals are used to load the output registers (s1o_data and
    // s2o_data)
    reg                             loadData1=0;
    reg                             loadData2=0;

    // we use this flag to tell if we need to convert the input stream data
    // (from s1i_data) from STREAM_BASE_W bits per base to INT_BASE_W bits per base
    // for output stream 1
    // Note that the query and target data should be converted, but the header
    // info should not (that should be truncated)
    reg                             convert1;

    // this is the length of the query/target sequence in bases
    wire    [MAX_POS_W-1:0]         nextLength;
    reg     [MAX_POS_W-1:0]         txRemaining;

    // this is asserted if we are processing the target, else we are processing
    // the query
    reg                             doTarget=0;

    /////////
    // FSM //
    /////////

    // states
    localparam  INFO_Q      = 8'b00000001,  // load the info for the query
                HEADER_Q    = 8'b00000010,  // send the header for the query
                DATA_Q      = 8'b00000100,  // send the data for the query
                INFO_T      = 8'b00001000,  // load the info for the target
                HEADER_T    = 8'b00010000,  // send the header for the target
                DATA_T      = 8'b00100000,  // load the data for the target
                LOAD_EXTRA  = 8'b01000000,  // load the number fo extra TX into txRemaining
                EXTRA       = 8'b10000000;  // send the extra transfers to s2o

    // FSM
    always @ (posedge clk) begin
        if (rst) begin
            state   <= INFO_Q;
        end else begin
            state   <= nextState;
        end
    end

    // next state logic
    always @ (*) begin

        nextState   = state;
        doTarget    = 0;
        loadInfo    = 0;
        loadExtra   = 0;
        convert1    = 0;
        loadData1   = 0;
        loadData2   = 0;
        s1i_rdy     = 0;
        
        case (state)
            // load the info for the next query sequence from the input stream data
            // we load this info into our txRemaining register
            INFO_Q: begin
                loadInfo            = 1;
                if (s1i_valid) begin
                    nextState       = HEADER_Q;
                end
            end
            // in this state, we send the query header to both output streams
            // note that the header is truncated to INT_STREAM_W bits on
            // output stream 1
            // Note: in this state, we know we just came from INFO_Q, where we
            // already checked for valid input data. therefore, we know that
            // s1i_valid is asserted
            HEADER_Q: begin
                // we can accept input stream data if our output data
                // registers can both accept new data
                case({s1o_valid,s2o_valid})
                    2'b00: s1i_rdy  = 1;
                    2'b10: s1i_rdy  = s1o_rdy;
                    2'b01: s1i_rdy  = s2o_rdy;
                    2'b11: s1i_rdy  = s1o_rdy && s2o_rdy;
                endcase

                // we are only sending a single transfer (the header) to both
                // output streams
                if (s1i_rdy) begin
                    loadData1       = 1;
                    loadData2       = 1;
                    nextState       = DATA_Q;
                end
            end
            // in this state, we send all data to both output streams.
            // however, the data that we send to output stream 1 is converted
            // from STREAM_BASE_W bits per base to INT_BASE_W bits per base
            DATA_Q: begin
                
                // this says that we want to convert the data on output
                // stream 1 to the INT_BASE_W bits per base encoding
                convert1            = 1;

                // we can accept input stream data if our output data
                // registers can both accept new data
                case({s1o_valid,s2o_valid})
                    2'b00: s1i_rdy  = 1;
                    2'b10: s1i_rdy  = s1o_rdy;
                    2'b01: s1i_rdy  = s2o_rdy;
                    2'b11: s1i_rdy  = s1o_rdy && s2o_rdy;
                endcase

                // we are dont sending data when we are sending a transaction,
                // and it is the last one
                if (s1i_valid && s1i_rdy) begin
                    loadData1       = 1;
                    loadData2       = 1;
                    if (txRemaining == 1) begin
                        nextState   = INFO_T;
                    end
                end
            end
            // load the info for the next target sequence from the input stream data
            // we load this info into our txRemaining register
            INFO_T: begin
                doTarget            = 1;
                loadInfo            = 1;
                if (s1i_valid) begin
                    nextState       = HEADER_T;
                end
            end
            // in this state, we send the target header to both output streams
            // note that the header is truncated to INT_STREAM_W bits on
            // output stream 1
            // Note: in this state, we know we just came from INFO_T, where we
            // already checked for valid input data. therefore, we know that
            // s1i_valid is asserted
            HEADER_T: begin
                doTarget            = 1;
                // we can accept input stream data if our output data
                // registers can both accept new data
                case({s1o_valid,s2o_valid})
                    2'b00: s1i_rdy  = 1;
                    2'b10: s1i_rdy  = s1o_rdy;
                    2'b01: s1i_rdy  = s2o_rdy;
                    2'b11: s1i_rdy  = s1o_rdy && s2o_rdy;
                endcase

                // we are only sending a single transfer (the header) to both
                // output streams
                if (s1i_rdy) begin
                    loadData1       = 1;
                    loadData2       = 1;
                    nextState       = DATA_T;
                end
            end
            // in this state, we send all data to both output streams.
            // however, the data that we send to output stream 1 is converted
            // from STREAM_BASE_W bits per base to INT_BASE_W bits per base
            DATA_T: begin
                doTarget            = 1;

                // this says that we want to convert the data on output
                // stream 1 to the INT_BASE_W bits per base encoding
                convert1            = 1;

                // we can accept input stream data if our output data
                // registers can both accept new data
                case({s1o_valid,s2o_valid})
                    2'b00: s1i_rdy  = 1;
                    2'b10: s1i_rdy  = s1o_rdy;
                    2'b01: s1i_rdy  = s2o_rdy;
                    2'b11: s1i_rdy  = s1o_rdy && s2o_rdy;
                endcase

                // we are dont sending data when we are sending a transaction,
                // and it is the last one
                if (s1i_valid && s1i_rdy) begin
                    loadData1       = 1;
                    loadData2       = 1;
                    if (txRemaining == 1) begin
                        nextState   = LOAD_EXTRA;
                    end
                end
            end
            // in this state, we load a number into our txRemaining register
            // this represents the number of extra TX that we need to send to
            // output stream 2, but not to output stream 1
            LOAD_EXTRA:  begin
                loadExtra           = 1;
                if (NUM_EXTRA_TX > 0) begin
                    nextState       = EXTRA;
                end else begin
                    nextState       = INFO_Q;
                end
            end
            // this this state, we have NUM_EXTRA_TX transfers that we
            // need to send to the output stream 2, but not to output stream 1
            EXTRA: begin
                loadData2           = 1;

                // now we only have to load output stream 2's data register,
                // so s1i_rdy should only depend upon if we can load new data
                // into that register
                s1i_rdy             = ~s2o_valid | s2o_rdy;

                if (s1i_valid && s1i_rdy) begin
                    loadData2       = 1;
                    if (txRemaining == 1) begin
                        nextState   = INFO_Q;
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
    assign nextLength = GetLength(s1i_data, doTarget);

    // track the number of transactions that we have remaining until we should
    // switch to outputting data on the other stream
    always @ (posedge clk) begin
        if (loadExtra) begin
            txRemaining             <= NUM_EXTRA_TX;
        end else if (loadInfo) begin
            txRemaining             <= 1 + ((nextLength + BASES_PER_TX - 1) >> LOG_BASES_PER_TX);
        end else if (s1i_valid && s1i_rdy) begin
            txRemaining             <= txRemaining - 1;
        end
    end
    
    /////////////////
    // STREAM DATA //
    /////////////////
    
    // this is just a debug counter that is later reported via the PicoBus
    // we declare it here, becase we want to print its value whenever we
    // accept a new piece of data to be sent to ouput stream 1
    reg     [31:0]                  s1o_count;          // number of transfers to output stream 1
    reg     [31:0]                  s2o_count;          // number of transfers to output stream 2

    // here we create the output register for stream 1
    always @ (posedge clk) begin
        if (rst) begin
            s1o_data                <= 'hX;
            s1o_valid               <= 0;
        end else if (loadData1) begin
            s1o_valid               <= s1i_valid;
            // if we are converting data from STREAM_BASE_W to INT_BASE_W,
            // then we use our ConvertBaseWidth() function
            if (convert1) begin
                s1o_data            <= ConvertBaseWidth(s1i_data);
            end
            // else we just truncate the data
            // Note: this assumes the header information ONLY occupies the LS
            // INT_STREAM_W bits on the input stream
            else begin
                s1o_data            <= s1i_data [INT_STREAM_W-1:0];
            end
            if (VERBOSE) begin
`ifdef ASCII_INPUT_DATA
                if (convert1) begin
                    $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%s", $realtime, NAME, s1o_count, s1i_data);
                end else begin
                    $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%h", $realtime, NAME, s1o_count, s1i_data);
                end
`else
                $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%h", $realtime, NAME, s1o_count, s1i_data);
`endif
            end
        end else if (s1o_rdy) begin
            s1o_data                <= 'hX;
            s1o_valid               <= 0;
        end
    end
    
    // here we create the output register for stream 2
    always @ (posedge clk) begin
        if (rst) begin
            s2o_data                <= 'hX;
            s2o_valid               <= 0;
        end else if (loadData2) begin
            s2o_valid               <= s1i_valid;
            // stream 2's data does NOT get converted in size
            s2o_data                <= s1i_data;
            //if (VERBOSE) $display("%t : %s : loading data [%0d] into output buffer for stream 2 = 0x%h", $realtime, NAME, s2o_count, s1i_data);
        end else if (s2o_rdy) begin
            s2o_data                <= 'hX;
            s2o_valid               <= 0;
        end
    end

    ///////////
    // DEBUG //
    ///////////
    
    // debug counters / registers
    reg     [31:0]                  status;             // current status of specified signals
    reg     [31:0]                  s1i_count;          // number of transfers from input stream 1
    wire    [31:0]                  version = 32'h0002; // version 0x0101 = version 1.1

    always @ (posedge clk) begin
        if (rst) begin
            s1o_count               <= 0;
            s2o_count               <= 0;
            s1i_count               <= 0;
        end else begin
            // 1) count the number of transactions accepted from the input stream
            if (s1i_valid && s1i_rdy) begin
                //if (VERBOSE) $display("%t : %s : receiving data [%0d] from input stream 1 = 0x%h", $realtime, NAME, s1i_count, s1i_data);
                s1i_count           <= s1i_count + 1;
            end
            // 2) count the number of transfers sent to output stream 1
            if (s1o_valid && s1o_rdy) begin
                s1o_count           <= s1o_count + 1;
                //if (VERBOSE) $display("%t : %s : sending data [%0d] to output stream 1 = 0x%h", $realtime, NAME, s1o_count, s1o_data);
            end
            // 3) count the number of transfers sent to output stream 2
            if (s2o_valid && s2o_rdy) begin
                s2o_count           <= s2o_count + 1;
                //if (VERBOSE) $display("%t : %s : sending data [%0d] to output stream 2 = 0x%h", $realtime, NAME, s2o_count, s2o_data);
            end
        end
        // 4) output some status signals
        status                      <= {2'b0,
                                        loadData1,
                                        loadData2,
                                        loadExtra,
                                        loadInfo,
                                        doTarget,
                                        convert1,
                                        state,
                                        2'b0,
                                        s1i_valid,
                                        s1i_rdy,
                                        s1o_valid,
                                        s1o_rdy,
                                        s2o_valid,
                                        s2o_rdy};
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
    reg     [31:0]                  s2o_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  s2o_count_2;
    always @ (posedge PicoClk) begin
        status_1        <= status;
        status_2        <= status_1;
        s1i_count_1     <= s1i_count;
        s1i_count_2     <= s1i_count_1;
        s1o_count_1     <= s1o_count;
        s1o_count_2     <= s1o_count_1;
        s2o_count_1     <= s2o_count;
        s2o_count_2     <= s2o_count_1;
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
                (PICOBUS_ADDR+32'h40):  PicoDataOut<= s2o_count_2;
            endcase
        end else begin
            PicoDataOut    <= 0;
        end
    end

endmodule 
