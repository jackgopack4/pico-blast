/*
* File Name     : SmWa.v
*
* Author        : Corey Olson
*
* Description   : This is meant to encompass a single Smith-Waterman alignment
*                 module.  Note that in order to have multiple Smith-Waterman
*                 computation units in a design, we simply instantiate
*                 multiple of these SmWa modules.
*
*                 This module handles any required clock crossing.  We do this
*                 by wrapping FIFOs around the entire module.  The inputs have
*                 FIFOs that cross into this clock boundary, and the outputs
*                 have FIFOs that cross back into the original clock boundary.
*
*                 After crossing into the new clock domain, we pass the target
*                 data to the RefShiftRegister.  This is a shift register that
*                 passes target data to the Systolic array 1 base at a time.
*                 Similarly, we hand the query data off to a query register.
*                 The query register first loads the query information (e.g.
*                 length), then loads the query data into it's register.  This
*                 query data is loaded STREAM_W bases at a time.  By default,
*                 STREAM_W is assumed to be 128.  
*
*                 The query data is loaded into each systolic cell once that
*                 cell sees the targetStart signal.  At that time, the
*                 systolic cell also samples the queryBaseEnable signal from
*                 the query register.
*
*                 Once all the target data has shifted through the
*                 SystolicArray, then we output a score to the ScoreFifo.  We
*                 have enough buffering in the SystolicArray for 1 score, so
*                 we don't start a new target sequence unless the output score
*                 is accepted by the score FIFO.
*
*                 The ScoreFifo then crosses back into the standard clock
*                 domain.  At this point, we can put some higher-level logic,
*                 if so desired, or we can send the results back to the
*                 software on a stream.
* 
*                 The traceback data crosses clock domains in this module 
*                 through its own FIFO.  The outputs of the tracebackFifo are passed
*                 up the modules directly to the traceback output stream(s).
*
* Assumptions   : 1) we always align 1 query to 1 target sequence
*                 2) we know that the query and target are actually received
*                 on the same stream in a higher module, so if we get ANY
*                 target data, then we have receiving ALL query data.
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
module SmWa #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter MAX_QUERY_LEN             = 100,          // maximum query length

    
    parameter SCORE_W                   = 9,            // width of the signed score in this cell
    parameter T_POS_W                   = 9,            // log(max_target_length) = number of bits required to store the index of the target base currently being processed
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN),
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
    
    parameter SCORE_STREAM_W            = 128,          // width of the score stream
    parameter STREAM_W                  = 128,          // width of a stream
                                                        // Note: we need to load things like the query 
                                                        // via a fixed-width stream
    parameter PICOBUS_ADDR              = 0
)
(
    /////////////////////////
    // Stream Clock Domain //
    /////////////////////////
    // Note: inputs and outputs are all synchronous to this clock
    input 			clk, 
    input 			rst,
    
    // This stream is used to carry the target data into the FPGA
    input 			target_valid,
    output 			target_ready,
    input [STREAM_W-1:0] 	target_data,
    
    // This stream is used to carry the query data into the FPGA
    input 			query_valid,
    output 			query_ready,
    input [STREAM_W-1:0] 	query_data,
    
    // This stream is used to carry score results out of the FPGA back to hte
    // the software
    output 			score_valid,
    input 			score_ready,
    output [SCORE_STREAM_W-1:0] score_data,
    
    // This stream is used to carry score results out of the FPGA back to hte
    // the software
    output 			traceback_valid,
    input 			traceback_ready,
    output [`TRACEBACK_WIDTH-1:0]  traceback_data,
    
    // Scoring Matrix, which is set via the PicoBus
    // Note: these should be signed 2's complement numbers
    input signed [SCORE_W-1:0] 	match, // positive score for a match
    input signed [SCORE_W-1:0] 	mismatch, // negative score for a mismatch
    input signed [SCORE_W-1:0] 	gapOpen, // negative score for opening a gap
`ifdef USE_AFFINE_GAP
    input signed [SCORE_W-1:0] 	gapExtend, // negative score for extending a gap
`endif // USE_AFFINE_GAP

    ///////////////////////
    // SmWa Clock Domain //
    ///////////////////////
    // Note: the guts of our system operate in this clock domain
    input 			clkSmWa,
    input 			rstSmWa,
    
    /////////////
    // PICOBUS //
    /////////////
    
    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input 			PicoClk, 
    input 			PicoRst,
    input [31:0] 		PicoAddr,
    input [31:0] 		PicoDataIn, 
    input 			PicoRd, 
    input 			PicoWr,
    output [31:0] 		PicoDataOut
);
    
    localparam MAX_QUERY_W              = BASE_W * MAX_QUERY_LEN;
    
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
    
    // data out of the target FIFO
    wire    [STREAM_W-1:0]              target_smwa_data;
    wire                                target_smwa_valid;
    wire                                target_smwa_ready;

    // data out of the query FIFO
    wire    [STREAM_W-1:0]              query_smwa_data;
    wire                                query_smwa_valid;
    wire                                query_smwa_ready;

    // data from the target register to the systolic array
    wire    [BASE_W-1:0]                target_base;
    wire                                target_base_valid;
    wire                                target_base_ready = 1'b1;
    wire                                target_base_last;
    wire                                target_start;
    wire    [SCORE_W-1:0]               target_score;
    
    // data from the query register to the systolic array
    wire    [MAX_QUERY_W-1:0]           query;
    wire    [MAX_QUERY_LEN-1:0]         queryEn;
    wire    [MAX_QUERY_LEN-1:0]         queryReady;

    // data from the systolic array to the score FIFO
`ifdef USE_LOCAL_ALIGNMENT
    wire    [SCORE_W-1:0]               localScore;
    wire    [Q_POS_W-1:0]               localScoreI;
    wire    [T_POS_W-1:0]               localScoreJ;
`endif  // USE_LOCAL_ALIGNMENT
    wire    [SCORE_W-1:0]               globalScore;
    wire    [T_POS_W-1:0]               globalScoreJ;
    wire                                scoreValid;
    wire                                scoreReady;

    // data from the systolic array to the traceback FIFO
    wire    [`TRACEBACK_WIDTH-1:0]		tracebackData;
    wire 				tracebackValid;
    wire                                tracebackReady;

    // actual PicoBus data is this OR'd with PicoBus output data from sub-modules
    reg     [31:0]                      PicoDataOutLocal;   // local PicoBus data
    wire    [31:0]                      PicoDataOutSub0;    // PicoDataOut from ref shift register
    wire    [31:0]                      PicoDataOutSub1;    // PicoDataOut from systolic array
    wire    [31:0]                      PicoDataOutSub2;    // PicoDataOut from query register
    wire    [31:0]                      version = 32'h0001; // version 0x0101 = version 1.1
    
    /////////////////
    // TARGET FIFO //
    /////////////////
    // this FIFO is used to cross the target data from the stream clock domain
    // into the SmWa clock domain
    // -this FIFO holds some header information for the target (e.g. length)
    // followed by the actual target data
    // -the output of this FIFO should be passed to the reference shifter
    // -format of data in this fifo
    // TX #     Data[127:0]
    // -----------------------
    // 0        <header info for target sequence 1>
    // 1        <target sequence bases 63:0>
    // ...
    // N-1      <target sequence bases ...>
    // N        <header info for target sequence 2>
    assign target_ready = ~targetFifoFull;
    assign target_smwa_valid = ~targetFifoEmpty;
    asyncFifoBRAM #(
        .WIDTH                          (STREAM_W)
    ) targetFifo (
        .wr_clk                         (clk),
        .wr_rst                         (rst),
        .din                            (target_data),
        .wr_en                          (target_valid),
        .full                           (targetFifoFull),
        
        .rd_clk                         (clkSmWa),
        .rd_rst                         (rstSmWa),
        .rd_en                          (target_smwa_ready),
        .dout                           (target_smwa_data),
        .empty                          (targetFifoEmpty)
    );
    
    ////////////////
    // QUERY FIFO //
    ////////////////
    // this FIFO is used to cross the query data from the stream clock domain
    // into the SmWa clock domain
    // -this FIFO holds some header information for the query (e.g. length)
    // followed by the actual query data
    // -the output of this FIFO should be passed to the reference shifter
    // -format of data in this fifo
    // TX #     Data[127:0]
    // -----------------------
    // 0        <header info for query sequence 1>
    // 1        <query sequence bases 63:0>
    // ...
    // N-1      <query sequence bases ...>
    // N        <header info for query sequence 2>
    assign query_ready = ~queryFifoFull;
    assign query_smwa_valid = ~queryFifoEmpty;
    asyncFifoBRAM #(
        .WIDTH                          (STREAM_W)
    ) queryFifo (
        .wr_clk                         (clk),
        .wr_rst                         (rst),
        .din                            (query_data),
        .wr_en                          (query_valid),
        .full                           (queryFifoFull),
        
        .rd_clk                         (clkSmWa),
        .rd_rst                         (rstSmWa),
        .rd_en                          (query_smwa_ready),
        .dout                           (query_smwa_data),
        .empty                          (queryFifoEmpty)
    );
    
    ////////////////////
    // QUERY REGISTER //
    ////////////////////
    QueryRegister  #(
        .NAME                           ({NAME,".queryRegister"}),
        .VERBOSE                        (VERBOSE),

        .BASE_W                         (BASE_W),
        .STREAM_W                       (STREAM_W),
        
        .MAX_QUERY_LEN                  (MAX_QUERY_LEN),
        .MAX_QUERY_W                    (MAX_QUERY_W),
        .Q_POS_W                        (Q_POS_W),

        .PICOBUS_ADDR                   (PICOBUS_ADDR+32'h2000)
    ) queryRegister (
        .clk                            (clkSmWa),
        .rst                            (rstSmWa),

        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (PicoDataOutSub2),

        // from the query FIFO
        .s1i_valid                      (query_smwa_valid),
        .s1i_data                       (query_smwa_data),
        .s1i_rdy                        (query_smwa_ready),
        
        // to the systolic array
        .queryOut                       (query),
        .queryOutEn                     (queryEn),
        .queryOutReady                  (queryReady)
    );


    /////////////////////
    // TARGET REGISTER //
    /////////////////////
    RefShiftRegister  #(
        .NAME                           ({NAME,".targetRegister"}),
        .VERBOSE                        (VERBOSE),

        .BASE_W                         (BASE_W),
        .STREAM_W                       (STREAM_W),

        .ENDIANNESS                     ("LS"),
        
        .SCORE_W                        (SCORE_W),
        .T_POS_W                        (T_POS_W),

        .PICOBUS_ADDR                   (PICOBUS_ADDR+32'h1000)
    ) targetRegister (
        .clk                            (clkSmWa),
        .rst                            (rstSmWa),

        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (PicoDataOutSub0),

        // from the target FIFO
        .s1i_valid                      (target_smwa_valid),
        .s1i_data                       (target_smwa_data),
        .s1i_rdy                        (target_smwa_ready),

        // to the systolic array
        .s1o_data                       (target_base),
        .s1o_valid                      (target_base_valid),
        .s1o_rdy                        (target_base_ready),
        .s1o_last                       (target_base_last),
        .s1o_start                      (target_start),
        .s1o_score                      (target_score)
    );


    ////////////////////
    // Systolic Array //
    ////////////////////
    SystolicArray  #(
        .NAME                           ({NAME,".SystolicArray"}),
        .VERBOSE                        (0),

        .BASE_W                         (BASE_W),
        .MAX_QUERY_LEN                  (MAX_QUERY_LEN),
    
        .SCORE_W                        (SCORE_W),
        .T_POS_W                        (T_POS_W),
        .Q_POS_W                        (Q_POS_W),
        
        .MAX_QUERY_W                    (MAX_QUERY_W),

        .PICOBUS_ADDR                   (PICOBUS_ADDR+32'h3000)
    ) SystolicArray (
        .clk                            (clkSmWa),
        .rst                            (rstSmWa),

        // affine-gap score inputs
        .match                          (match),
        .mismatch                       (mismatch),
        .gapOpen                        (gapOpen),
`ifdef  USE_AFFINE_GAP
        .gapExtend                      (gapExtend),
`endif  // USE_AFFINE_GAP

        // from the query register
        .queryIn                        (query),
        .queryInEn                      (queryEn),
        .queryInReady                   (queryReady),
    
        // from the target shift register
        .targetIn                       (target_base),
        .targetInLast                   (target_base_last),
        .targetInValid                  (target_base_valid),
        .targetInStart                  (target_start),
        .targetInScore                  (target_score),

        // to the score FIFO
`ifdef  USE_LOCAL_ALIGNMENT
        .localScore                     (localScore),
        .localScoreI                    (localScoreI),
        .localScoreJ                    (localScoreJ),
`endif  // USE_LOCAL_ALIGNMENT

        .Score                          (globalScore),
        .ScoreJ                         (globalScoreJ),
        
        .ScoreValid                     (scoreValid),
        .ScoreReady                     (scoreReady),

        .TracebackData                  (tracebackData),
        .TracebackValid                 (tracebackValid),
        .TracebackReady                 (tracebackReady),
        
        // PicoBus - for debug only
        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (PicoDataOutSub1)
    );
    
    ////////////////
    // SCORE FIFO //
    ////////////////
    assign scoreReady = ~scoreFifoFull;
    assign score_valid = ~scoreFifoEmpty;
    asyncFifoBRAM #(
        .WIDTH      (SCORE_STREAM_W)
    ) scoreFifo (
        .wr_clk     (clkSmWa),
        .wr_rst     (rstSmWa),
        // TODO: ensure that this is < STREAM_W, or else we have to go to
        // multiple transfers to load up this FIFO
`ifdef  USE_LOCAL_ALIGNMENT
        .din        ({SCORE_STREAM_W{1'b0}}|{localScoreI,localScoreJ,localScore,globalScoreJ,globalScore}),
`else   // !USE_LOCAL_ALIGNMENT
        .din        ({SCORE_STREAM_W{1'b0}}|{globalScoreJ,globalScore}),
`endif  // USE_LOCAL_ALIGNMENT
        .wr_en      (scoreValid),
        .full       (scoreFifoFull),
        
        .rd_clk     (clk),
        .rd_rst     (rst),
        .rd_en      (score_ready),
        .dout       (score_data),
        .empty      (scoreFifoEmpty)
    );

    ////////////////////
    // TRACEBACK FIFO //
    ////////////////////
    assign tracebackReady = ~tracebackFifoFull;
    assign traceback_valid = ~tracebackFifoEmpty;
    asyncFifoBRAM #(
        .WIDTH      (`TRACEBACK_WIDTH)
    ) tracebackFifo (
        .wr_clk     (clkSmWa),
        .wr_rst     (rstSmWa),
	.din        (tracebackData),	     
        .wr_en      (tracebackValid),
        .full       (tracebackFifoFull),
        
        .rd_clk     (clk),
        .rd_rst     (rst),
        .rd_en      (traceback_ready),
        .dout       (traceback_data),
        .empty      (tracebackFifoEmpty)
    );

    ///////////
    // DEBUG //
    ///////////
    
    reg     [31:0]                      count_query_loads;
    reg     [31:0]                      count_target_loads;
    reg     [31:0]                      count_target_bases;
    reg     [31:0]                      count_target_start;
    reg     [31:0]                      count_target_last;
    reg     [31:0]                      count_scores;
    reg     [31:0]                      status;
    always @ (posedge clkSmWa) begin
        if (rstSmWa) begin
            count_query_loads       <= 0;
            count_target_loads      <= 0;
            count_target_bases      <= 0;
            count_target_start      <= 0;
            count_target_last       <= 0;
            count_scores            <= 0;
        end else begin
            // 1) count number of transfers from input stream fifo to query register
            if (query_smwa_valid && query_smwa_ready) begin
                if (VERBOSE) $display("%t : %s : load [%0d] into query register", $realtime, NAME, count_query_loads);
                count_query_loads   <= count_query_loads + 1;
            end
            // 2) count number of transfers from input stream fifo to target shift
            // register
            if (target_smwa_valid && target_smwa_ready) begin
                if (VERBOSE) $display("%t : %s : load [%0d] into target register", $realtime, NAME, count_target_loads);
                count_target_loads  <= count_target_loads + 1;
            end
            // 3) count the number of valid bases out of the target shift register
            if (target_base_valid && target_base_ready) begin
                if (VERBOSE) $display("%t : %s : base [%0d] out of target shift register", $realtime, NAME, count_target_bases);
                count_target_bases  <= count_target_bases + 1;
            end
            // 4) count the number of target_start signals from the target shift
            // register
            if (target_start) begin
                if (VERBOSE) $display("%t : %s : starting target [%0d]", $realtime, NAME, count_target_start);
                count_target_start  <= count_target_start + 1;
            end
            // 5) count the number of target_base_last signals from the shift register
            if (target_base_valid && target_base_last && target_base_ready) begin
                if (VERBOSE) $display("%t : %s : ending target [%0d]", $realtime, NAME, count_target_last);
                count_target_last   <= count_target_last + 1;
            end
            // 6) count the number of scoreValid signals out of the systolic array
            if (scoreValid && scoreReady) begin
                if (VERBOSE) $display("%t : %s : getting score [%0d] from systolic array", $realtime, NAME, count_scores);
                count_scores        <= count_scores + 1;
            end
        end
        // 7) see the valid/ready handshake signals:
        status                      <= {
        //  a) from the input stream to the query register
                                        2'h0,
                                        query_smwa_valid,
                                        query_smwa_ready,
        //  b) from the input stream to the target shift register
                                        2'h0,
                                        target_smwa_valid,
                                        target_smwa_ready,
        //  c) from the target shift register to the systolic array
                                        target_base_valid,
                                        target_base_ready,
                                        target_base_last,
                                        target_start,
        //  d) from the query register to the systolic array
                                        2'h0,
                                        queryEn[0],
                                        queryReady[0],
        //  e) from the systolic array to the score fifo
                                        2'h0,
                                        scoreValid,
                                        scoreReady};
    end

    // synchronize to the PicoClk w/ pipeline registers
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_query_loads_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_query_loads_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_loads_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_loads_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_bases_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_bases_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_start_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_start_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_last_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_target_last_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_scores_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      count_scores_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                      status_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                      status_2;
    always @ (posedge PicoClk) begin
        count_query_loads_1         <= count_query_loads;
        count_query_loads_2         <= count_query_loads_1;
        count_target_loads_1        <= count_target_loads;
        count_target_loads_2        <= count_target_loads_1;
        count_target_bases_1        <= count_target_bases;
        count_target_bases_2        <= count_target_bases_1;
        count_target_start_1        <= count_target_start;
        count_target_start_2        <= count_target_start_1;
        count_target_last_1         <= count_target_last;
        count_target_last_2         <= count_target_last_1;
        count_scores_1              <= count_scores;
        count_scores_2              <= count_scores_1;
        status_1                    <= status;
        status_2                    <= status_1;
    end

    /////////////
    // PICOBUS //
    /////////////
    
    integer                             p;

    // set control registers via the PicoBus
    // read status information via the PicoBus
    always @ (posedge PicoClk) begin
        if (PicoRst) begin
            PicoDataOutLocal    <= 0;
        end else if (PicoRd) begin
            PicoDataOutLocal    <= 0;
            case (PicoAddr)
                (PICOBUS_ADDR+32'h00):  PicoDataOutLocal<= version;
                (PICOBUS_ADDR+32'h10):  PicoDataOutLocal<= count_query_loads_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOutLocal<= count_target_loads_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOutLocal<= status_2;
                (PICOBUS_ADDR+32'h40):  PicoDataOutLocal<= count_target_bases_2;
                (PICOBUS_ADDR+32'h50):  PicoDataOutLocal<= count_target_start_2;
                (PICOBUS_ADDR+32'h60):  PicoDataOutLocal<= count_target_last_2;
                (PICOBUS_ADDR+32'h70):  PicoDataOutLocal<= count_scores_2;
            endcase
        end else begin
            PicoDataOutLocal    <= 0;
        end
    end

    assign PicoDataOut = PicoDataOutLocal | PicoDataOutSub0 | PicoDataOutSub1 | PicoDataOutSub2;

endmodule
