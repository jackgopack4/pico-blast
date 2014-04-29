/*
* File Name     : SystolicArray.v
*
* Author        : Corey Olson
*
* Description   : This module implements a systolic array.  In this case, we
*                 have an array of Smith-Waterman cells.  This module is all
*                 synchronous to "clk".
*                 
*                 We have multiple inputs and outputs in this module.  We
*                 start by describing those here:
*                 
*                 1) the substitution matrix scores - These are set via the
*                 PicoBus, and are merely inputs to this module.  They are not
*                 registered or anything.  They are simply passed to the
*                 systolic cells.  These should be set via the PicoBus long
*                 before any queries are targets are passed to this system.
*                 Due to the high fanout on these nets, they will probably
*                 fail timing.  However, if we assume these are set on the
*                 PicoBus for a long time, we can TIG those nets.  Note that
*                 only the "match" input should be positive.  The other inputs
*                 should be negative values.
*                 
*                 2) the query - We have an input query, which is the
*                 concatenated 2D array of query bases.  This should be stored
*                 little-endian (first bases of the query are in the LS bits).
*                 We also have an enable bit for each base of the query, which
*                 should only be asserted if the associated base is valid.
*                 This is required because we support MAX_QUERY_LEN length
*                 queries, but we can also support shorter queries.
*                 Therefore, if MAX_QUERY_LEN is 100, but our current query is
*                 only 60 bases, then the remaining 40 bits of the queryInEn
*                 should be set to 0.  Note that the query is zippered into
*                 the systolic cells, so the query should be held stable on
*                 the input (along with the enable bits) from the assertion of
*                 the "targetInStart" signal until the queryInReady signal is
*                 asserted.
*                        
*                 3) the target - This is the target string that is scored
*                 against the query.  This gets shifted into this module
*                 1 based at a time.  We start aligning a target 1 cycle after
*                 the targetInStart signal is asserted.  Note that this signal
*                 is observed even if targetInValid is 0.  The targetInStart
*                 signal should be asserted 1 cycle before the first base of
*                 a target.  The target data should get shifted into this
*                 module starting at the beginning of the target.  e.g. if the
*                 target is "AGGT", then the first base that gets shifted into
*                 this module should be 'A'.  The targetInLast signal should
*                 be asserted with the last valid base of a target.  Note that
*                 we gate this targetInLast signal with the targetInValid
*                 signal.  e.g. if targetInLast is asserted for 1 cycle, but
*                 targetInValid is not, then we assume we are still aligning
*                 that target.  The targetInScore is the alignment score for
*                 this query-target pair before the start of this alignment.
*                 We use that score as an initial H score in the dynamic
*                 programming table.
*                 
*                 4) output scores and positions - This module outputs
*                 a score and a base index for the target (index of the last
*                 target base that aligned to the query).  In the event of
*                 doing local alignment, we also output the local alignment
*                 score (best score found anywhere in the 2D scoring matrix)
*                 and the index of the last query base that aligned to produce
*                 that score.  The output score is held until ScoreReady is
*                 asserted.  We only have buffer space available in this
*                 module for 1 score, so in the event that ScoreReady is
*                 de-asserted, the module instantiating this one should stop
*                 sending targets and queries to this module.
*
* Definitions   : 1) USE_LOCAL_ALIGNMENT - Define this to do local alignment.
*                 This will track the best score found anywhere in the
*                 dynamic programming table.  It also imposes a minimum
*                 alignment score of 0.  Lastly, it initializes the row and
*                 columns of the dynamic programming table according to the
*                 Smith-Waterman algorithm.  If this is not defined, they are
*                 initialized according to the Needleman-Wunsch algorithm.
*
*                 2) USE_AFFINE_GAP - Define this to use an affine-gap scoring
*                 model.  This uses extra resources in the design, as we now
*                 have to store 2 gap scores for each systolic cell.
*
* Assumptions   : 1) the query gets zipper-loaded into the systolic array at
*                 the start of every target
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
module SystolicArray #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 0,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter MAX_QUERY_LEN             = 100,          // maximum query length
    
    parameter SCORE_W                   = 9,            // width of the signed score in this cell
    parameter T_POS_W                   = 9,            // log(max_target_length) = number of bits required to store the index of the target base currently being processed
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN),
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
    parameter MAX_QUERY_W               = BASE_W * MAX_QUERY_LEN,
                                                        // width of the query bus coming into this module
    parameter PICOBUS_ADDR              = 0
)
(
    input 		       clk, 
    input 		       rst,
    
    // Scoring Matrix, which is set via the PicoBus
    // Note: these should be signed 2's complement numbers
    input signed [SCORE_W-1:0] match, // positive score for a match
    input signed [SCORE_W-1:0] mismatch, // negative score for a mismatch
    input signed [SCORE_W-1:0] gapOpen, // negative score for opening a gap
`ifdef USE_AFFINE_GAP
    input signed [SCORE_W-1:0] gapExtend, // negative score for extending a gap
`endif // USE_AFFINE_GAP

    // Note: this query gets zipper-loaded into the systolic array at the
    // start of every target
    input [MAX_QUERY_W-1:0]    queryIn, // actual query data (placed in registers)
    input [MAX_QUERY_LEN-1:0]  queryInEn, // enable bit for each base of the input query
    output [MAX_QUERY_LEN-1:0] queryInReady,
                                                        // input query and enable bits should be held stable
                                                        // from the assertion of the targetInStart signal 
                                                        // until this signal is asserted
    
    // Note: this target base gets shifed through the entire array
    input [BASE_W-1:0] 	       targetIn, // base of target data shifted through array
    input 		       targetInStart, // asserted 1 cycle before the first valid target base
    input 		       targetInLast, // asserted with the last valid base of a target
    input 		       targetInValid, // input target base is valid when this is asserted
    input [SCORE_W-1:0]        targetInScore, // score for the query-target pair alignment preceding this section of the query and target

    // local alignment
`ifdef  USE_LOCAL_ALIGNMENT
    output reg [SCORE_W-1:0]   localScore=0, // local alignment score = best H score found in the array
    output reg [Q_POS_W-1:0]   localScoreI=0, // query index of the local alignment
    output reg [T_POS_W-1:0]   localScoreJ=0, // target index of the local alignment
`endif // USE_LOCAL_ALIGNMENT

    // global alignment
    output reg [SCORE_W-1:0]   Score=0, // global alignment score
    output reg [T_POS_W-1:0]   ScoreJ=0, // target index for the best global alignment
                                                        // Note: this is the index of the last base of 
                                                        // the target that aligned to the query
    output reg 		       ScoreValid=0, // both global and local scores are valid when this is asserted
    input 		       ScoreReady, // output is ready to accept another score when this is asserted

    // traceback
    output [127:0] 	       TracebackData, // global alignment score
    output 		       TracebackValid, // both global and local scores are valid when this is asserted
    input 		       TracebackReady, // output is ready to accept another score when this is asserted
    
    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input 		       PicoClk, 
    input 		       PicoRst,
    input [31:0] 	       PicoAddr,
    input [31:0] 	       PicoDataIn, 
    input 		       PicoRd, 
    input 		       PicoWr,
    output reg [31:0] 	       PicoDataOut
);
    
    ///////////////
    // FUNCTIONS //
    ///////////////
                
    // this is a signed comparison, because both next_h and h_in are declared as signed
    function signed [SCORE_W-1:0] max;
        input signed [SCORE_W-1:0] a;
        input signed [SCORE_W-1:0] b;
        max = (a < b) ? b : a;
    endfunction
    
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

    /////////////////////
    // LOCAL VARIABLES //
    /////////////////////

    // array of bases that are passed between systolic cells
    wire    [BASE_W-1:0]                target      [0:MAX_QUERY_LEN];

    // array of bits that tell each systolic cell that it's about to start
    // processing a new target
    reg     [MAX_QUERY_LEN+1:0]         targetStart=0;

    // tracks when the last base of a target has been completely aligned
    reg     [MAX_QUERY_LEN+1:0]         targetLast=0;

    // 2D array of query bases to pass to the systolic cells
    // Note: these bases get loaded into each systolic cell when it's
    // targetStart bit is asserted
    reg     [BASE_W-1:0]                nextQuery   [0:MAX_QUERY_LEN-1];

    // array of gap scores that get passed between systolic cells
`ifdef  USE_AFFINE_GAP
    wire    [SCORE_W-1:0]               f           [0:MAX_QUERY_LEN];
    wire    [SCORE_W-1:0]               e           [0:MAX_QUERY_LEN];
`endif
    
    // array of similarity scores that get passed between systolic cells
    wire    [SCORE_W-1:0]               h           [0:MAX_QUERY_LEN];
    
    // the local maximum value that gets outputted by each systolic cell
`ifdef  USE_LOCAL_ALIGNMENT
    wire    [SCORE_W-1:0]               h_max       [0:MAX_QUERY_LEN];
    wire    [Q_POS_W-1:0]               h_max_i     [0:MAX_QUERY_LEN];
`endif  // USE_LOCAL_ALIGNMENT
    
    // this gets asserted once all targets (being aligned) have been flushed
    // out
    reg                                 targetsDone=1;

    // this is asserted if we are currently in the middle of a target on the
    // input to the systolic array (i.e. have not accepted all target bases
    // into systolic cell 0)
    reg                                 midTarget=0;

    // if we are currently scoring a target (target starts with the assertion
    // of targetInStart, ends with the assertion of targetInLast), then we
    // only enable the systolic array if the targetBase is valid.  else we
    // must wait for valid target data to come in
    reg                                 enable=0;
    
    // we use this variable to reduce the number of ifdefs that we need in this file
    wire        signed  [SCORE_W-1:0]   gapExtend0;
`ifdef  USE_AFFINE_GAP
    assign gapExtend0 = gapExtend;
`else   // !USE_AFFINE_GAP
    assign gapExtend0 = 0;
`endif  // USE_AFFINE_GAP

    integer                             q;
    
    ///////////
    // QUERY //
    ///////////
    
    // extract the query into a 2D array
    always @ (*) begin
        for (q=0; q<MAX_QUERY_LEN; q=q+1) begin
            nextQuery[q]    = queryIn >> (q*BASE_W);
        end
    end

    // each base of the query gets loaded when the targetStart signal is
    // asserted into the systolic cell
    assign queryInReady = targetStart[MAX_QUERY_LEN-1:0] | {MAX_QUERY_LEN{targetsDone}};

    ////////////
    // TARGET //
    ////////////
    
    reg     [BASE_W-1:0]                targetBaseIn;

    // drive targetStart[0] with the input signal
    // drive targetLast[0] with the input signal
    // Note: we are only shifting data through this systolic array if it is
    // enabled
    always @ (posedge clk) begin
        targetBaseIn    <= targetIn;
        if (enable) begin
            targetStart <= (targetStart<<1) | targetInStart;
            targetLast  <= (targetLast<<1) | targetInLast;
        end
    end
    
    // store if all targets have been completely aligned
    always @ (posedge clk) begin
        if (rst) begin
            targetsDone <= 1;
        end else if (targetStart != 0) begin
            targetsDone <= 0;
        end else if (targetLast[MAX_QUERY_LEN-1]) begin
            targetsDone <= 1;
        end
    end

    // store a register that tells if we are currently in the middle of
    // a target
    always @ (posedge clk) begin
        if (rst) begin
            midTarget   <= 0;
        end else if (targetInStart) begin
            midTarget   <= 1;
        end else if (targetInValid && targetInLast) begin
            midTarget   <= 0;
        end
    end

    // control the enable signal for the systolic cells
    // Note: if we are aligning a target, then we only enable the cells if the
    // target base is valid
    // Note: if enable is de-asserted, then in the systolic cells: 
    // 1) target base does not shift to the output 
    // 2) query base and enable do not get accepted
    // 3) h_up does not get stored (to be used as h_diag)
    // 4) e_out does not get updated
    // 5) f_out does not get updated
    // 6) h_max_out and h_max_i_out do not get updated
    // 7) h_out does not get updated
    always @ (posedge clk) begin
        if (rst) begin
            enable      <= 1;
        end else if (midTarget || targetStart[0]) begin
            enable      <= targetInValid;
        end else begin
            enable      <= 1;
        end
    end

    ///////////
    // ROW 0 //
    ///////////
    
    // TODO: determine what the H and F scores should be into systolic cell 0
    // this is the score that we should use to drive H[0] as we progress
    // through the alignment
    reg         signed  [SCORE_W-1:0]   initialScore=0;
    
    // Note: this is really the F score for row 1 of the dynamic programming
    // matrix (i.e. row corresponding to base 0 of the query)
    reg         signed  [SCORE_W-1:0]   initialF=0;
    
    always @ (posedge clk) begin
        if (targetInStart) begin
            initialScore        <= targetInScore;
            initialF            <= max(targetInScore + gapOpen + gapExtend0 + gapExtend0, 0);
        end else if (enable) begin
`ifdef  USE_LOCAL_ALIGNMENT
            if (targetStart[0]) begin
                initialScore    <= max(initialScore + gapExtend0 + gapOpen, 0);
                initialF        <= max(initialScore + gapExtend0 + gapOpen + gapExtend0, 0);
            end else begin
                initialScore    <= max(initialScore + gapExtend0, 0);
                initialF        <= max(initialScore + gapExtend0 + gapExtend0, 0);
            end
`else  // !USE_LOCAL_ALIGNMENT
            if (targetStart[0]) begin
                initialScore    <= initialScore + gapExtend0 + gapOpen;
            end else begin
                initialScore    <= initialScore + gapExtend0;
            end
            initialF            <= initialScore + gapOpen + gapExtend0 + gapExtend0;
`endif  // USE_LOCAL_ALIGNMENT
        end
    end

    // drive target[0] with the registered target input base
    assign  target  [0] = targetBaseIn;
    
    // drive the similarity score for row 0 based upon whether we are doing
    // global or local alignment
    // Note: this is really the score for row 0 of the 2D dynamic programming
    // matrix, where this score does not correspond to a query base
    assign  h       [0] = initialScore;
    
    // drive the gap score for row 0 if we are doing affine-gap scoring
    // Note: this is really the score for row 1 of the 2D dynamic programming
    // matrix, where this score corresponds to query base 0
`ifdef  USE_AFFINE_GAP
    assign  f       [0] = initialF;
`endif  // USE_AFFINE_GAP

    // drive the local maximum score for row 0 if we are doing local
    // smith-waterman
    // Note: this is really the score for row 0 of the 2D dynamic programming
    // matrix, where this score does not correspond to a query base
`ifdef  USE_LOCAL_ALIGNMENT
    assign  h_max   [0] = 0;
    assign  h_max_i [0] = 0;
`endif  // USE_LOCAL_ALIGNMENT

    //////////////////////////
    // Smith-Waterman Cells //
    //////////////////////////
    
    /*
     * As a general rule for this systolic array, each cell accepts the ith
     * entry in an array, and drives the i+1 entry of the array.  e.g. cell[1]
     * accepts target[1] and drives target[2]
     */
    genvar c;
    generate for (c=0; c<MAX_QUERY_LEN; c=c+1) begin:create_cells
        SmWaCell #(
            .NAME           ({NAME,".cell"}),
            .VERBOSE        (VERBOSE),
            .SCORE_W        (SCORE_W),
            .BASE_W         (BASE_W),
            .Q_POS_W        (Q_POS_W),
            .T_POS_W        (T_POS_W),
            .INDEX          (c)
        ) SmWaCell (
            .clk            (clk),
            .rst            (rst),

            .enable         (enable),

            // Note: these score wires will probably have a very high fanout,
            // so we should TIG them (because we assume they will be set via
            // the PicoBus long before they are used)
            .match          (match),
            .mismatch       (mismatch),
            .gapOpen        (gapOpen),
`ifdef  USE_AFFINE_GAP
            .gapExtend      (gapExtend),
`endif  // USE_AFFINE_GAP

            .queryIn        (nextQuery      [c]),
            .queryEnIn      (queryInEn      [c]),
            .newQueryIn     (targetStart    [c]),

            .targetIn       (target         [c]),
            .newTargetIn    (targetStart    [c]),
            .targetOut      (target         [c+1]),
            .endTargetIn    (targetLast     [c]),

`ifdef  USE_AFFINE_GAP
            .f_in           (f              [c]),
            .f_out          (f              [c+1]),
            .e_out          (e              [c+1]),
`endif  // USE_AFFINE_GAP

`ifdef  USE_LOCAL_ALIGNMENT
            .h_max_in       (h_max          [c]),
            .h_max_i_in     (h_max_i        [c]),
            
            .h_max_out      (h_max          [c+1]),
            .h_max_i_out    (h_max_i        [c+1]),
`endif  // USE_LOCAL_ALIGNMENT
            
            .h_in           (h              [c]),
            .h_out          (h              [c+1]),
            .traceback_out  (TracebackData [2*c+1:2*c])
        );
    end endgenerate

    /////////////
    // SCORING //
    /////////////

    // we need to track the best global alignment score and index out of the
    // bottom systolic cell
    reg     signed      [SCORE_W-1:0]   bestScore=0;
    reg                 [T_POS_W-1:0]   bestScoreJ=0;
    reg                 [T_POS_W-1:0]   targetBase=0;
    wire    signed      [SCORE_W-1:0]   currScore = h[MAX_QUERY_LEN];
    always @ (posedge clk) begin
        if (targetStart[MAX_QUERY_LEN]) begin
            bestScore       <= h        [MAX_QUERY_LEN];
            bestScoreJ      <= 0;
            targetBase      <= 0;
        end else begin
            if (enable) begin
                targetBase  <= targetBase + 1;
            end
            // give priority to earlier alignments
            if ($signed(h[MAX_QUERY_LEN]) > bestScore) begin
                bestScore   <= h        [MAX_QUERY_LEN];
                bestScoreJ  <= targetBase;
            end
        end
    end
    
    // if doing local alignment, we also must track the best alignment score
    // and indices out of the bottom systolic cell
`ifdef  USE_LOCAL_ALIGNMENT
    reg                 [SCORE_W-1:0]   bestLocalScore=0;
    reg                 [Q_POS_W-1:0]   bestLocalScoreI=0;
    reg                 [T_POS_W-1:0]   bestLocalScoreJ=0;
    always @ (posedge clk) begin
        if (targetStart[MAX_QUERY_LEN]) begin
            bestLocalScore  <= h_max    [MAX_QUERY_LEN];
            bestLocalScoreI <= h_max_i  [MAX_QUERY_LEN];
            bestLocalScoreJ <= 0;
        end 
        // give priority to earlier alignments
        else if (h_max[MAX_QUERY_LEN] > bestLocalScore) begin
            bestLocalScore  <= h_max    [MAX_QUERY_LEN];
            bestLocalScoreI <= h_max_i  [MAX_QUERY_LEN];
            bestLocalScoreJ <= targetBase;
        end
    end
`endif  // USE_LOCAL_ALIGNMENT
    
    // buffer the output scores
    // Note: final alignment scores and indices are valid 1 cycle
    // after targetLast[MAX_QUERY_LEN] is asserted
    always @ (posedge clk) begin
        if (rst) begin
            Score           <= 0;
            ScoreJ          <= 0;
`ifdef  USE_LOCAL_ALIGNMENT
            localScore      <= 0;
            localScoreI     <= 0;
            localScoreJ     <= 0;
`endif  // USE_LOCAL_ALIGNMENT
        end else if (targetLast[MAX_QUERY_LEN+1]) begin
            Score           <= bestScore;
            ScoreJ          <= bestScoreJ;
`ifdef  USE_LOCAL_ALIGNMENT
            localScore      <= bestLocalScore;
            localScoreI     <= bestLocalScoreI;
            localScoreJ     <= bestLocalScoreJ;
`endif  // USE_LOCAL_ALIGNMENT
        end
    end

    // Note: final alignment scores and indices are valid 1 cycle
    // after targetLast[MAX_QUERY_LEN] is asserted
    // Note: assume the output score buffer will be flushed out before the new
    // score hits the buffer
    always @ (posedge clk) begin
        if (rst) begin
            ScoreValid  <= 0;
        end else if (targetLast[MAX_QUERY_LEN+1]) begin
            ScoreValid  <= 1;
        end else if (ScoreReady) begin
            ScoreValid  <= 0;
        end
    end

   // Traceback data will begin to be valid once cells begin receiving new data.
   // Validity after that point depends on the cells being enabled and continues
   // until a valid score is produced.
   reg traceback_region;
   always @(posedge clk) begin
      if (rst) begin
	 traceback_region <= 0;
      end else if (targetStart[0]) begin
	 traceback_region <= 1;
      end else if (ScoreValid) begin
	 traceback_region <= 0;
      end
   end
   assign TracebackValid = traceback_region? enable: 0;
   
    ///////////
    // DEBUG //
    ///////////
    
    wire    [31:0]                  version = 32'h0001; // version 0x0101 = version 1.1

    reg     [31:0]                  targetInChecksum;
    reg     [31:0]                  targetInStart_count;
    reg     [31:0]                  targetInLast_count;
    reg     [31:0]                  targetInValid_count;
    reg     [31:0]                  ScoreValid_count;
    reg     [31:0]                  status;
   
    always @ (posedge clk) begin
        if (rst) begin
            targetInChecksum        <= 0;
            targetInStart_count     <= 0;
            targetInLast_count      <= 0;
            targetInValid_count     <= 0;
            ScoreValid_count        <= 0;
        end else begin
            if (targetInValid) begin
                if (VERBOSE) $display("%t : %s : target data checksum = 0x%h", $realtime, NAME, targetInChecksum);
                targetInChecksum    <= targetInChecksum + targetIn;
            end
            if (targetInStart) begin
                if (VERBOSE) $display("%t : %s : starting target [%0d]", $realtime, NAME, targetInStart_count);
                targetInStart_count <= targetInStart_count + 1;
            end
            if (targetInValid && targetInLast) begin
                if (VERBOSE) $display("%t : %s : last target [%0d] base", $realtime, NAME, targetInLast_count);
                targetInLast_count  <= targetInLast_count + 1;
            end
            if (targetInValid) begin
                if (VERBOSE) $display("%t : %s : target base [%0d]", $realtime, NAME, targetInValid_count);
                targetInValid_count <= targetInValid_count + 1;
            end
            if (ScoreValid && ScoreReady) begin
                if (VERBOSE) $display("%t : %s : score for target [%0d] = %d", $realtime, NAME, ScoreValid_count, Score);
                ScoreValid_count    <= ScoreValid_count + 1;
            end
        end
        status                      <= {2'b0,
                                        targetIn,
                                        1'b0,
                                        targetInStart,
                                        targetInLast,
                                        targetInValid,
                                        2'b0,
                                        ScoreValid,
                                        ScoreReady,
                                        2'b0,
                                        targetsDone,
                                        enable};
    end

    // pipeline registers
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInChecksum_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInChecksum_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInStart_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInStart_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInLast_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInLast_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInValid_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  targetInValid_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  ScoreValid_count_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  ScoreValid_count_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  status_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  status_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryInEn_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryInEn_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryInReady_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryInReady_2;
    always @ (posedge PicoClk) begin
        targetInChecksum_1          <= targetInChecksum;
        targetInChecksum_2          <= targetInChecksum_1;
        targetInStart_count_1       <= targetInStart_count;
        targetInStart_count_2       <= targetInStart_count_1;
        targetInLast_count_1        <= targetInLast_count;
        targetInLast_count_2        <= targetInLast_count_1;
        targetInValid_count_1       <= targetInValid_count;
        targetInValid_count_2       <= targetInValid_count_1;
        ScoreValid_count_1          <= ScoreValid_count;
        ScoreValid_count_2          <= ScoreValid_count_1;
        status_1                    <= status;
        status_2                    <= status_1;
        queryInEn_1                 <= queryInEn;
        queryInEn_2                 <= queryInEn_1;
        queryInReady_1              <= queryInReady;
        queryInReady_2              <= queryInReady_1;
    end

    /////////////
    // PICOBUS //
    /////////////

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
                (PICOBUS_ADDR+32'h10):  PicoDataOut<= targetInChecksum_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOut<= targetInStart_count_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOut<= status_2;
                (PICOBUS_ADDR+32'h40):  PicoDataOut<= targetInLast_count_2;
                (PICOBUS_ADDR+32'h50):  PicoDataOut<= targetInValid_count_2;
                (PICOBUS_ADDR+32'h60):  PicoDataOut<= ScoreValid_count_2;
                (PICOBUS_ADDR+32'h70):  PicoDataOut<= queryInEn_2;
                (PICOBUS_ADDR+32'h80):  PicoDataOut<= queryInReady_2;
            endcase
        end else begin
            PicoDataOut    <= 0;
        end
    end
    
endmodule
