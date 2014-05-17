/*
* File Name     : SmWaWrapper.v
*
* Author        : Corey Olson
*
* Description   : This is the top-level module for instantiating a single
*                 Smith-Waterman or Needleman-Wunsch engine in a Pico
*                 Computing M-series module.  This module relies heavily upon
*                 the streaming system that Pico provides, and it does not use
*                 the off-chip memory at all.  In other words, both the query
*                 and target are sent to this module via the stream.  In this
*                 module, we assume that both the query and target are sent on
*                 the same stream (stream 1).  We also assume that the query
*                 is sent before the stream.  Lastly, the query and target
*                 must not exceed their maximum specified lengths
*                 (MAX_QUERY_LEN and MAX_TARGET_LEN respectively).
*
*                 This wrapper module does 2 main things:
*                 1) it de-multiplexes data from the input stream onto the
*                 query and target streams
*                 2) sets the scoring matrix via the PicoBus
*
*                 Here is the format of data that we expect to see on the
*                 input stream:
*                 TX #      Data[127:0]
*                 -----------------------
*                 0         <header info for query sequence 1>
*                 1         <query sequence 1 bases 63:0>
*                 ...
*                 N-1       <query sequence 1 bases ...>
*                 N         <header info for target sequence 1>
*                 N+1       <target sequence 1 bases 63:0>
*                 ...
*                 M-1       <target sequence 1 bases ...>
*                 M         <header info for query sequence 2>
*                 M+1       <query sequence 2 bases 63:0>
*                 
* TODO          : 3) better comments
*
* Assumptions   : 
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
module SmWaWrapper #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter MAX_TARGET_LEN            = 1000,         // maximum target length
    parameter MAX_QUERY_LEN             = 100,          // maximum query length

    
    parameter SCORE_W                   = 9,            // width of the signed score in this cell
    parameter T_POS_W                   = clogb2(MAX_TARGET_LEN),            
                                                        // log(max_target_length) = number of bits required to store the index of the target base currently being processed
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN),
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
    
    parameter SCORE_STREAM_W            = 128,          // width of the score stream
    parameter STREAM_W                  = 128,          // width of a stream
                                                        // Note: we need to load things like the query 
                                                        // via a fixed-width stream
    parameter SCORE_ADDR                = 32'h100,      // PicoBus address for writing the score matrix parameters
    parameter PICOBUS_ADDR              = 0
)
(
    // this is the slower clock that is used to drive the Smith-Waterman
    // systolic arrays
    input 			clkSmWa,
    input 			rstSmWa,

    // The clk and rst signals are shared between all the streams in this module,
    //   which are: stream #1 in, and stream #1 out.
    input 			clk,
    input 			rst,
    
    // These are the signals for stream #1 INto the firmware.
    input 			s1i_valid,
    output 			s1i_rdy,
    input [STREAM_W-1:0] 	s1i_data,
    
    // These are the signals for stream #1 OUT of the firmware.
    output 			s1o_valid,
    input 			s1o_rdy,
    output [SCORE_STREAM_W-1:0] s1o_data,

     // These are the signals for the traceback stream(s) OUT of the firmware.
    output 			traceback_valid,
    input 			traceback_rdy,
    output [`TRACEBACK_WIDTH-1:0] 		traceback_data,

    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input 			PicoClk, 
    input 			PicoRst,
    input [31:0] 		PicoAddr,
    input [31:0] 		PicoDataIn, 
    input 			PicoRd, 
    input 			PicoWr,
    output [31:0] 		PicoDataOut
);

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
    
    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////
    
    // these are signals used to talk to the target stream
    wire                                target_valid;
    wire                                target_ready;
    wire    [STREAM_W-1:0]              target_data;

    // these are signals used to talk to the query stream
    wire                                query_valid;
    wire                                query_ready;
    wire    [STREAM_W-1:0]              query_data;

    
    // actual PicoBus data is this OR'd with PicoBus output data from sub-modules
    reg     [31:0]                      PicoDataOutLocal;   // local PicoBus data
    wire    [31:0]                      PicoDataOutSub0;    // PicoDataOut from SmWa module
    wire    [31:0]                      PicoDataOutSub1;    // PicoDataOut from stream demux module
    wire    [31:0]                      version = 32'h0001; // version 0x0101 = version 1.1
    
    // Scoring Matrix, which is set via the PicoBus
    // Note: these should be signed 2's complement numbers
    reg         signed  [SCORE_W-1:0]   match;          // positive score for a match
    reg         signed  [SCORE_W-1:0]   mismatch;       // negative score for a mismatch
    reg         signed  [SCORE_W-1:0]   gapOpen;        // negative score for opening a gap
`ifdef  USE_AFFINE_GAP
    reg         signed  [SCORE_W-1:0]   gapExtend;      // negative score for extending a gap
`endif  // USE_AFFINE_GAP

    /////////////////////////////
    // DEMULTIPLEX STREAM DATA //
    /////////////////////////////

    StreamDemux #(
        .NAME                           ({NAME,".StreamDemux"}),
        .VERBOSE                        (VERBOSE),

        .BASE_W                         (BASE_W),
        .MAX_STREAM1_LEN                (MAX_QUERY_LEN),
        .MAX_STREAM2_LEN                (MAX_TARGET_LEN),
        
        .STREAM2_POS_W                  (T_POS_W),
        .STREAM1_POS_W                  (Q_POS_W),
        
        .STREAM_W                       (STREAM_W),

        .PICOBUS_ADDR                   (PICOBUS_ADDR+32'h1000)
    ) StreamDemux (
        
        .clk                            (clk),
        .rst                            (rst),

        // this is the input data from the input stream
        .s1i_valid                      (s1i_valid),
        .s1i_rdy                        (s1i_rdy),
        .s1i_data                       (s1i_data),
        
        // this is the data for the target stream
        .s2o_valid                      (target_valid),
        .s2o_rdy                        (target_ready),
        .s2o_data                       (target_data),

        // this is the data for the query stream
        .s1o_valid                      (query_valid),
        .s1o_rdy                        (query_ready),
        .s1o_data                       (query_data),
        
        // PicoBus signals
        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (PicoDataOutSub1)
    );
    
    ///////////////////////////////////////////
    // INSTANTIATE THE SMITH-WATERMAN MODULE //
    ///////////////////////////////////////////
    SmWa #(
        .NAME                           ({NAME,".SmWa"}),
        .VERBOSE                        (VERBOSE),

        .BASE_W                         (BASE_W),
        .MAX_QUERY_LEN                  (MAX_QUERY_LEN),
        
        .SCORE_W                        (SCORE_W),
        .T_POS_W                        (T_POS_W),
        .Q_POS_W                        (Q_POS_W),
        
        .SCORE_STREAM_W                 (SCORE_STREAM_W),
        .STREAM_W                       (STREAM_W),

        .PICOBUS_ADDR                   (PICOBUS_ADDR+32'h2000)
    ) SmWa (
        
        // all I/O w/ this module is synchronous to this clock and reset
        .clk                            (clk),
        .rst                            (rst),

        // target input stream
        .target_valid                   (target_valid),
        .target_ready                   (target_ready),
        .target_data                    (target_data),

        // query input stream
        .query_valid                    (query_valid),
        .query_ready                    (query_ready),
        .query_data                     (query_data),

        // score output stream
        .score_valid                    (s1o_valid),
        .score_ready                    (s1o_rdy),
        .score_data                     (s1o_data),

        // traceback output stream
        .traceback_valid                    (traceback_valid),
        .traceback_ready                    (traceback_rdy),
        .traceback_data                     (traceback_data),

        // affine-gap score inputs
        .match                          (match),
        .mismatch                       (mismatch),
        .gapOpen                        (gapOpen),
`ifdef  USE_AFFINE_GAP
        .gapExtend                      (gapExtend),
`endif  // USE_AFFINE_GAP

        // slower clock for the systolic array
        .clkSmWa                        (clkSmWa),
        .rstSmWa                        (rstSmWa),
        
        // PicoBus signals
        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (PicoDataOutSub0)
    );

    ///////////
    // DEBUG //
    ///////////

    reg     [31:0]                      s1i_count;
    reg     [31:0]                      target_count;
    reg     [31:0]                      query_count;
    reg     [31:0]                      s1o_count;
    reg     [31:0]                      status;

    always @ (posedge clk) begin
        if (rst) begin
            s1i_count           <= 0;
            target_count        <= 0;
            query_count         <= 0;
            s1o_count           <= 0;
        end else begin
            // 1) count the number of transfers from the input stream
            if (s1i_valid && s1i_rdy) begin
                if (VERBOSE) $display("%t : %s : input stream tx [%0d]", $realtime, NAME, s1i_count);
                s1i_count       <= s1i_count + 1;
            end
            // 2) count the number of transfers to the target stream
            if (target_valid && target_ready) begin
                if (VERBOSE) $display("%t : %s : target stream tx [%0d]", $realtime, NAME, target_count);
                target_count    <= target_count + 1;
            end
            // 3) count the number of transfers to the query stream
            if (query_valid && query_ready) begin
                if (VERBOSE) $display("%t : %s : query stream tx [%0d]", $realtime, NAME, query_count);
                query_count     <= query_count + 1;
            end
            // 4) count the number of transfers to the output stream
            if (s1o_valid && s1o_rdy) begin
                if (VERBOSE) $display("%t : %s : output stream tx [%0d]", $realtime, NAME, s1o_count);
                s1o_count       <= s1o_count + 1;
            end
        end
        status                  <= {2'b0,
                                    s1i_valid,
                                    s1i_rdy,
                                    2'b0,
                                    target_valid,
                                    target_ready,
                                    2'b0,
                                    query_valid,
                                    query_ready,
                                    2'b0,
                                    s1o_valid,
                                    s1o_rdy};
    end
    
    // pipeline registers
    (* shreg_extract = "no" *)
    reg     [31:0]                      s1i_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      s1i_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      target_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      target_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      query_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      query_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      s1o_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      s1o_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      status_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      status_2;
    always @ (posedge PicoClk) begin
        s1i_count_1             <= s1i_count;
        s1i_count_2             <= s1i_count_1;
        target_count_1          <= target_count;
        target_count_2          <= target_count_1;
        query_count_1           <= query_count;
        query_count_2           <= query_count_1;
        s1o_count_1             <= s1o_count;
        s1o_count_2             <= s1o_count_1;
        status_1                <= status;
        status_2                <= status_1;
    end

    /////////////
    // PICOBUS //
    /////////////
    
    // set control registers via the PicoBus
    // read status information via the PicoBus
    always @ (posedge PicoClk) begin
        if (PicoRst) begin
            PicoDataOutLocal    <= 0;
        end else if (PicoWr) begin
            PicoDataOutLocal    <= 0;
            case(PicoAddr)
                (SCORE_ADDR+32'h00):    match           <= PicoDataIn;
                (SCORE_ADDR+32'h10):    mismatch        <= PicoDataIn;
                (SCORE_ADDR+32'h20):    gapOpen         <= PicoDataIn;
`ifdef  USE_AFFINE_GAP
                (SCORE_ADDR+32'h30):    gapExtend       <= PicoDataIn;
`endif  // USE_AFFINE_GAP
            endcase
        end else if (PicoRd) begin
            PicoDataOutLocal    <= 0;
            case (PicoAddr)
                (PICOBUS_ADDR+32'h00):  PicoDataOutLocal<= version;
                (PICOBUS_ADDR+32'h10):  PicoDataOutLocal<= s1i_count_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOutLocal<= s1o_count_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOutLocal<= status_2;
                (SCORE_ADDR+32'h00):    PicoDataOutLocal<= match;
                (SCORE_ADDR+32'h10):    PicoDataOutLocal<= mismatch;
                (SCORE_ADDR+32'h20):    PicoDataOutLocal<= gapOpen;
`ifdef  USE_AFFINE_GAP
                (SCORE_ADDR+32'h30):    PicoDataOutLocal<= gapExtend;
`endif  // USE_AFFINE_GAP
                (PICOBUS_ADDR+32'h80):  PicoDataOutLocal<= target_count_2;
                (PICOBUS_ADDR+32'h90):  PicoDataOutLocal<= query_count_2;
            endcase
        end else begin
            PicoDataOutLocal    <= 0;
        end
    end
    
    assign PicoDataOut = PicoDataOutLocal | PicoDataOutSub0 | PicoDataOutSub1;

endmodule
