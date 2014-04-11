/*
* File Name     : StreamDemux.v
*
* Author        : Corey Olson
*
* Description   : This module is designed to take a single input stream and
*                 split the data into 2 output streams.  This assumes that the
*                 data on the input stream is stored sequentially.  The data
*                 for output stream 1 appears first on the input stream,
*                 followed by the data for output stream 2.
*
*                 Here is the format of data that we expect to see on the
*                 input stream:
*                 TX #      Data[127:0]
*                 -----------------------
*                 0         <header info for stream 1 sequence 1>
*                 1         <stream 1 sequence 1 bases 63:0>
*                 ...
*                 N-1       <stream 1 sequence 1 bases ...>
*                 N         <header info for stream 2 sequence 1>
*                 N+1       <stream 2 sequence 1 bases 63:0>
*                 ...
*                 M-1       <stream 2 sequence 1 bases ...>
*                 M         <header info for stream 1 sequence 2>
*                 M+1       <stream 1 sequence 2 bases 63:0>
*
* Copyright     : 2013, Pico Computing, Inc.
*/
module StreamDemux #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter MAX_STREAM1_LEN           = 100,          // maximum sequence length on stream 1 length

    
    parameter STREAM2_POS_W             = 9,            // log(max_stream2_length)
    parameter STREAM1_POS_W             = clogb2(MAX_STREAM1_LEN),
                                                        // log(max_stream1_length)
    
    parameter STREAM_W                  = 128,          // width of a stream
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
    output reg                          s1o_valid,
    input                               s1o_rdy,
    output      [STREAM_W-1:0]          s1o_data,
    
    // These are the signals for stream #2 OUT of the firmware.
    output reg                          s2o_valid,
    input                               s2o_rdy,
    output      [STREAM_W-1:0]          s2o_data,

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
    localparam BASES_PER_TX             = STREAM_W / BASE_W;
    
    // = log(BASES_PER_TX)
    localparam LOG_BASES_PER_TX         = clogb2(BASES_PER_TX);
    
    // the max between the STREAM1_POS_W and the STREAM2_POS_W
    // Note: this is used to demultiplex the 2 streams of data
    localparam MAX_POS_W                = max(STREAM1_POS_W,STREAM2_POS_W);

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
    
    // this is a signed comparison, because both next_h and h_in are declared as signed
    function integer max;
        input integer a;
        input integer b;
        max = (a < b) ? b : a;
    endfunction
    
    // extracts the length field from the header info on the input stream
    function [MAX_POS_W-1:0] GetLength;
        input   [STREAM_W-1:0]  data;
        input                   stream2;
        begin
            // both stream2 and stream1 length are in the LS bits, but they may
            // have different widths
            // first, check if we are getting the stream2 length field
            if (stream2) begin
                GetLength = data[STREAM2_POS_W-1:0];
            end
            // else we are getting the stream1 length
            else begin
                GetLength = data[STREAM1_POS_W-1:0];
            end
        end
    endfunction

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////

    // our state register
    reg     [2:0]                   state=0;
    reg     [2:0]                   nextState=0;
    
    // these are control signals that we assert to load the info about the
    // sequence (e.g. length, etc.)
    reg                             loadInfo=0;

    // this is the length of the stream1/stream2 sequence in bases
    wire    [MAX_POS_W-1:0]         nextLength;
    reg     [MAX_POS_W-1:0]         txRemaining;

    // this is asserted if we are processing stream 2, else we are processing
    // stream 1
    reg                             doStream2=0;

    // we buffer 1 transfer worth of stream data before driving it to the
    // output streams
    reg     [STREAM_W-1:0]          stream_data;

    /////////
    // FSM //
    /////////

    // states
    localparam  INFO_1  = 0,    // load the info for the stream 1 data
                DATA_1  = 1,    // load the data for stream 1
                INFO_2  = 2,    // load the info for the stream 2 data
                DATA_2  = 3;    // load the data for stream 2

    // FSM
    always @ (posedge clk) begin
        if (rst) begin
            state   <= INFO_1;
        end else begin
            state   <= nextState;
        end
    end

    // next state logic
    always @ (*) begin

        nextState   = state;
        doStream2   = 0;
        loadInfo    = 0;
        s1i_rdy     = 0;
        
        case (state)
            // load the info for the next stream1 sequence from the input stream data
            // we load this info into our txRemaining register
            INFO_1: begin
                loadInfo            = 1;
                doStream2           = 0;
                if (s1i_valid) begin
                    nextState       = DATA_1;
                end
            end
            // in this state, we send all data to the output stream 1. this
            // includes the header information
            // to send information to the output stream, we first load it into
            // our output buffer.  we then assert the s1o_valid signal.  Note
            // that s2o_valid will not be asserted while s1o_valid is
            // asserted, because they share an output buffer
            DATA_1: begin
                // we can accept input stream data if our output data
                // register can accept new data (i.e. it either does not hold
                // any valid data, or that data is about to be passed onto the
                // output stream)
                s1i_rdy             = s1o_valid ? s1o_rdy : 
                                      s2o_valid ? s2o_rdy : 
                                      1'b1;

                // we are dont sending data when we are sending a transaction,
                // and it is the last one
                if ((s1i_valid && s1i_rdy) && (txRemaining == 1)) begin
                    nextState       = INFO_2;
                end
            end
            // load the info for the next stream2 sequence from the input stream data
            // this info is loaded into the txRemaining register
            INFO_2: begin
                loadInfo            = 1;
                doStream2           = 1;
                if (s1i_valid) begin
                    nextState       = DATA_2;
                end
            end
            // in this state, we send all data to the output stream 1. this
            // includes the header information
            // to send information to the output stream, we first load it into
            // our output buffer.  we then assert the s2o_valid signal.  Note
            // that s2o_valid will not be asserted while s1o_valid is
            // asserted, because they share an output buffer
            DATA_2: begin
                doStream2           = 1;
                // we can accept input stream data if our output data
                // register can accept new data (i.e. it either does not hold
                // any valid data, or that data is about to be passed onto the
                // output stream)
                s1i_rdy             = s1o_valid ? s1o_rdy : 
                                      s2o_valid ? s2o_rdy : 
                                      1'b1;

                // we are dont sending data when we are sending a transaction,
                // and it is the last one
                if ((s1i_valid && s1i_rdy) && (txRemaining == 1)) begin
                    nextState       = INFO_1;
                end
            end
            // should never enter this state
            default: nextState      = INFO_1;
        endcase
    end

    /////////////////
    // STREAM INFO //
    /////////////////

    // compute what our next length would be
    // this is mainly used to compute the number of transfers required to get
    // all the data for a query/target sequence from the input stream
    assign nextLength = GetLength(s1i_data, doStream2);

    // track the number of transactions that we have remaining until we should
    // switch to outputting data on the other stream
    always @ (posedge clk) begin
        if (loadInfo) begin
            txRemaining             <= 1 + ((nextLength + BASES_PER_TX - 1) >> LOG_BASES_PER_TX);
        end else if (s1i_valid && s1i_rdy) begin
            txRemaining             <= txRemaining - 1;
        end
    end
    
    /////////////////
    // STREAM DATA //
    /////////////////

    // this is just a set of debug counters
    // we count the total number of transfers from the input stream, to the
    // s1 output stream, and to the s1 output stream
    reg [31:0]                      s1i_count=0;

    // we buffer a single STREAM_W piece of data
    // this data is then passed to either stream 1 or stream 2 output
    always @ (posedge clk) begin
        if (rst) begin
            s1i_count               <= 0;
        end else if (s1i_valid && s1i_rdy) begin
            stream_data             <= s1i_data;
            s1i_count               <= s1i_count + 1;
        end
    end

    // now we just assign the output data to both output streams
    assign s1o_data = stream_data;
    assign s2o_data = stream_data;

    // now we control which output stream valid signal that we actualy are
    // driving
    always @ (posedge clk) begin
        if (rst) begin
            s1o_valid               <= 0;
            s2o_valid               <= 0;
        end else if (s1i_valid && s1i_rdy && !doStream2) begin
            s1o_valid               <= 1;
            s2o_valid               <= 0;
            if (VERBOSE) $display("%t : %s : loading data [%0d] into output buffer for stream 1 = 0x%h", $realtime, NAME, s1i_count, s1i_data);
        end else if (s1i_valid && s1i_rdy && doStream2) begin
            s1o_valid               <= 0;
            s2o_valid               <= 1;
            if (VERBOSE) $display("%t : %s : loading data [%0d] into output buffer for stream 2 = 0x%h", $realtime, NAME, s1i_count, s1i_data);
        end else if ((s1o_valid && s1o_rdy) || 
                     (s2o_valid && s2o_rdy)) begin
            s1o_valid               <= 0;
            s2o_valid               <= 0;
        end
    end

    ///////////
    // DEBUG //
    ///////////
    
    // debug counters / registers
    reg     [31:0]                  status;             // current status of specified signals
    reg     [31:0]                  s1o_count;          // number of transfers to output stream 1
    reg     [31:0]                  s2o_count;          // number of transfers to output stream 2
    wire    [31:0]                  version = 32'h0001; // version 0x0101 = version 1.1

    // 1) count the number of transactions accepted from the input stream
    // - this is done in a preceding section (s1i_count)
    always @ (posedge clk) begin
        if (rst) begin
            s1o_count               <= 0;
            s2o_count               <= 0;
        end else begin
            // 2) count the number of transfers sent to output stream 1
            if (s1o_valid && s1o_rdy) begin
                s1o_count           <= s1o_count + 1;
                if (VERBOSE) $display("%t : %s : sending data data [%0d] to output stream 1 = 0x%h", $realtime, NAME, s1o_count, s1o_data);
            end
            // 3) count the number of transfers sent to output stream 2
            if (s2o_valid && s2o_rdy) begin
                s2o_count           <= s2o_count + 1;
                if (VERBOSE) $display("%t : %s : sending data data [%0d] to output stream 2 = 0x%h", $realtime, NAME, s2o_count, s2o_data);
            end
        end
        // 4) output some status signals
        status                      <= {2'b0,
                                        loadInfo,
                                        doStream2,
                                        1'b0,
                                        state,
                                        2'b0,
                                        s1i_valid,
                                        s1i_rdy,
                                        s1o_valid,
                                        s1o_rdy,
                                        s2o_valid,
                                        s2o_rdy,
                                        {(16-MAX_POS_W){1'b0}},
                                        txRemaining};
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
