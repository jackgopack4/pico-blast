/*
* File Name     : SmWaCell.v
*
* Author        : Corey Olson
*
* Description   : This module is a single cell of the Smith-Waterman 2D 
*                 scoring array.  We've reduce this module as much as 
*                 possible, so it only handles the datapath.  It should 
*                 not manage the Control logic at all (only abide by it).
*                 
* Notes         : This is the directionality of the E, F, and H values in the
*                 scoring matrix.
*                 
*                             --------
*                            | Target |
*                             --------
*                        -----     -----
*                        | H |     | F |
*                   -    -----     -----
*                  |Q|        \      |
*                  |u|         \     |
*                  |e|          \    |
*                  |r|           \   |
*                  |y|            \  v
*                   -    -----     -----
*                        | E |---->| ? |
*                        -----     -----
*
*                 This module is a little complicated, because we are trying
*                 to support multiple variants.  First, we want to support
*                 just simple, global Smith-Waterman scoring.  If that is the
*                 case, don't worry about defining anything.  If you'd want to
*                 do local SmithWaterman scoring (true Smith-Waterman), then
*                 you should
*                 `define USE_LOCAL_SMITHWATERMAN
*                 If you want to use an affine-gap model scoring scheme, you
*                 should 
*                 `define USE_AFFINE_GAP
*                 You can use any combination of affine gap scoring and local
*                 scoring.  In other words, these two definitions do NOT
*                 depend upon eachother at all.
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
module SmWaCell #(
    parameter NAME                  = "",                   // name of this module
    parameter VERBOSE               = 0,                    // set to 1 for verbose debugging statements in simulation
    
    parameter   SCORE_W                 = 9,            // width of the signed score in this cell
    parameter   BASE_W                  = 2,            // width of a single query/target base
    parameter   T_POS_W                 = 8,            // log(max_target_length) = number of bits required to store the index of the target base currently being processed
    parameter   Q_POS_W                 = 8,            // log(max_query_length) = number of bits required to store the index of this systolic cell
    parameter   INDEX                   = 1             // the index of this cell in the systolic array
)
(
    input                               clk, 
    input                               rst,

    input                               enable,         // this cell only peforms computations and moves data when this signal is asserted

    // Scoring Matrix, which is set via the PicoBus
    // Note: these should be signed 2's complement numbers
    input       signed  [SCORE_W-1:0]   match,          // positive score for a match
    input       signed  [SCORE_W-1:0]   mismatch,       // negative score for a mismatch
    input       signed  [SCORE_W-1:0]   gapOpen,        // negative score for opening a gap
`ifdef  USE_AFFINE_GAP
    input       signed  [SCORE_W-1:0]   gapExtend,      // negative score for extending a gap
`endif  // USE_AFFINE_GAP

    input               [BASE_W-1:0]    queryIn,        // base of the query
    input                               queryEnIn,      // query base should only be aligned when this is asserted
                                                        // else just pass the input score to the output
    input                               newQueryIn,     // query base and enable should be loaded when this is asserted
    
    input               [BASE_W-1:0]    targetIn,       // target base to be compared against the query base
                                                        // Note: this is the base used in the scoring for this cell
    output  reg         [BASE_W-1:0]    targetOut=0,    // registered target base, which is the input
                                                        //  reference base to the compute unit below
    input                               newTargetIn,    // input flag to start a new alignment

    // this is ONLY used for debug purposes
    input                               endTargetIn,    // input flag to specify the last base of a target

    // score arrays - assume cells are vertically stacked, one cell per query base
`ifdef  USE_AFFINE_GAP
    input       signed  [SCORE_W-1:0]   f_in,           // reference gap score from the cell above this one
                                                        //  in the 2D array
    output  reg signed  [SCORE_W-1:0]   f_out=0,        // computed f score, which is passed to the systolic cell below this one

    output  reg signed  [SCORE_W-1:0]   e_out=0,        // compute e score, which doesn't really need to be outputted, 
                                                        // because it gets reused by this systolic cell in the next clock cycle
`endif  // USE_AFFINE_GAP

`ifdef  USE_LOCAL_ALIGNMENT
    input       signed  [SCORE_W-1:0]   h_max_in,       // local maximum score from the cell above this one
    input       signed  [Q_POS_W-1:0]   h_max_i_in,     // query index of the systolic cell with the max score

    output reg  signed  [SCORE_W-1:0]   h_max_out=0,    // local maximum score after this cell is included
    output reg  signed  [Q_POS_W-1:0]   h_max_i_out=0,  // query index of the systolic cell with the max score
    // Note: we don't need to output this if we simply track the max local
    // score in the last cell of the systolic array.  if we know when the
    // target alignment started, we can track the target base for each local
    // alignment score currently being outputted.  therefore, we don't need
    // a counter for j for each cell, just 1 per systolic array.  we just need
    // to be sure to give precedence to the first alignment (in the target)
    // with the best local score
    //output reg  signed  [T_POS_W-1:0]h_max_j_out=0,  // target index of the systolic cell with the max score
`endif  // USE_LOCAL_ALIGNMENT
    
    input       signed  [SCORE_W-1:0]   h_in,           // H score from the compute unit above
                                                        //  this one, which corresponds with the cell in
                                                        //  the 2D array above the current cell
                                                        //  Note: this is regisetered, and it becomes h_diag
    output  reg signed  [SCORE_W-1:0]   h_out=0         // computed similarity score for this cell
                                                        // Note: this will also be used in the next cycle as h_left
    );

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////
    reg                 [BASE_W-1:0]    query;          // the query base being compared
    reg                                 queryEn;        // enable signal for this query base 
                                                        // Note: should only compute scores in this cell if this signal is asserted, else just pass input scores to output
    
    wire                [BASE_W-1:0]    target = targetIn;
                                                        // the target base being compared

    reg                 [SCORE_W-1:0]   h_diag;         // 1 cycle delayed similarity score from the
                                                        //  compute unit above this one, which corresponds
                                                        //  to the cell in the 2D array diagonal to the
                                                        //  current cell
    
    wire        signed  [SCORE_W-1:0]   h_left = h_out; // similarity score to the left of this one in the alignment matrix
   
    wire        signed  [SCORE_W-1:0]   sub;            // match/substitution score computed based upon the current query/target bases

    reg         signed  [SCORE_W-1:0]   next_h;         // next value for the similarity score
    
`ifdef  USE_AFFINE_GAP
    // e score from the cell to the left of this one in the 2D scoring matrix
    wire        signed  [SCORE_W-1:0]   e_in = e_out;

    // read and reference gap signals
    wire        signed  [SCORE_W-1:0]   extend_e;  
    wire        signed  [SCORE_W-1:0]   new_e;
    wire        signed  [SCORE_W-1:0]   extend_f;
    wire        signed  [SCORE_W-1:0]   new_f;
`endif // USE_AFFINE_GAP
    
    // if we are not using affine-gap scoring, then the next_e and next_f
    // should be computed based upon the h_in and h_left
    reg         signed  [SCORE_W-1:0]   next_e;
    reg         signed  [SCORE_W-1:0]   next_f;

    ///////////////
    // FUNCTIONS //
    ///////////////
                
    // this is a signed comparison, because both next_h and h_in are declared as signed
    function signed [SCORE_W-1:0] max;
        input signed [SCORE_W-1:0] a;
        input signed [SCORE_W-1:0] b;
        max = (a < b) ? b : a;
    endfunction
    
    // returns which one of the inputs was the maximum
    // 0 = a is the maximum
    // 1 = b is the maximu
    // in the event of a tie, 0 is returned
    function signed maxOrigin;
        input signed [SCORE_W-1:0] a;
        input signed [SCORE_W-1:0] b;
        maxOrigin = (a < b) ? 1'b1 : 1'b0;
    endfunction

    ///////////
    // LOGIC //
    ///////////
    
    /*
     * FOR BWA
     * in every clock cycle, we accept as an input
     * 1) h[i-1,j]
     * 2) f[i,j]
     * 3) e[i,j]
     * 4) h_max[i-1,j]
     * in every clock cycle, we output
     * 1) h[i,j]
     * 2) f[i+1,j]
     * 3) e[i,j+1]
     * 4) h_max[i,j]
     */

    // register the incoming:
    // 1) target base
    // 2) query base and enable (if newQueryIn is asserted)
    // 3) h_up, which is used as h_diag in the next clock cycle
    always @ (posedge clk) begin
        if (enable) begin
            targetOut           <= targetIn;
            if (newQueryIn) begin
                query           <= queryIn;
                queryEn         <= queryEnIn;
            end
            h_diag              <= h_in;
        end
    end

    ////////////////////
    // COMPUTE H[i,j] //
    ////////////////////

    // compute the next similarity value first, given that we already know the
    // E(i,j) and F(i,j) values, which are inputs on this clock cycle
    assign sub                  = (query === target) ? match : mismatch;
    
    // compute the next similarity score
    always @ (*) begin
        if (!queryEn) begin
            next_h              = h_in;
        end else begin
`ifdef  USE_AFFINE_GAP
            // if we are using Affine-gap scoring, then e_in = E[i,j] and f_in
            // = F[i,j]
            next_h              = max(h_diag+sub, max(e_in, f_in));
`else   // !USE_AFFINE_GAP
            // else we rely upon the newly computed F[i,j] and E[i,j] gap open
            // scores
            next_h              = max(h_diag+sub, max(next_e, next_f));
`endif  // USE_AFFINE_GAP
        end
    end

    //////////////////
    // COMPUTE GAPS //
    //////////////////

`ifdef  USE_AFFINE_GAP
    // compute cost of opening new gaps or extending gaps
    assign new_e                = next_h    + gapExtend + gapOpen;
    assign new_f                = next_h    + gapExtend + gapOpen;
    assign extend_e             = e_in      + gapExtend;
    assign extend_f             = f_in      + gapExtend;
`endif  // USE_AFFINE_GAP
    
    // compute the next e and f gap scores
    always @ (*) begin
`ifdef  USE_AFFINE_GAP
        // if we are using affine-gap scoring, then we are computing E[i,j+1]
        // and F[i+1,j] here
        next_e                  = max(extend_e, new_e);
        next_f                  = max(extend_f, new_f); 
`else   // !USE_AFFINE_GAP
        // if we are not using affine-gap scoring, then we are computing
        // E[i,j] and F[i,j] here
        next_e                  = h_left    + gapOpen;
        next_f                  = h_in      + gapOpen;
`endif  // USE_AFFINE_GAP

`ifdef  USE_LOCAL_ALIGNMENT
        // if we are doing local alignment, either with the affine-gap scoring
        // or not, then we need to clip low at 0
        next_e                  = max(0, next_e);
        next_f                  = max(0, next_f); 
`endif  // USE_LOCAL_ALIGNMENT
    end

    ///////////////////
    // systolic cell //
    ///////////////////
    
    // note: if we are not doing local alignment or affine gap model, this
    // should reduce to a single register per cell
    always @ (posedge clk) begin
        
        // this is only used if we are using the affine gap model
`ifdef  USE_AFFINE_GAP
        //////////////////////
        // compute E[i,j+1] //
        //////////////////////
        if (newTargetIn) begin
            // a new target means we are going to see base 0 of the target in
            // the next clock cycle. therefore, we should compute E[i,0], so
            // it can be used as E[i,j] when computing H[i,j] in the next
            // clock cycle
            // TODO: figure out how we should initialize stuff for E
            e_out               <= 0;
        end else if (enable) begin
            e_out               <= next_e;
        end
        
        //////////////////////
        // compute F[i+1,j] //
        //////////////////////
        if (newTargetIn) begin
            // a new target means we are going to see base 0 of the target in
            // the next clock cycle. therefore, we should compute F[i,0], so
            // it can be used as F[i,j] when computing H[i,j] in the next
            // clock cycle
            // TODO: figure out how we should initialize stuff for F
            f_out               <= 0;
        end else if (enable) begin
            f_out               <= next_f;
        end
`endif  // USE_AFFINE_GAP

        /////////////////////////
        // TRACK LOCAL MAXIMUM //
        /////////////////////////
`ifdef  USE_LOCAL_ALIGNMENT
        // this is only used if we are doing local alignment
        // here we compute the best local alignment for H[0,0] to H[i,j]
        if (newTargetIn) begin
            h_max_out           <= h_in;
            h_max_i_out         <= 0;
        end else if (enable) begin
            // these are the possible next values for h_max_out (in descending
            // order of priority, i.e. 1 has highest priority)
            // 1) max score from systolic cell above this one
            // 2) max score currently stored in this systolic cell
            // 3) newly computed H[i,j] output score
            h_max_out           <= max(h_max_in, max(h_max_out, next_h));
            // 1) max score from systolic cell above this one
            if (!maxOrigin(h_max_in,h_max_out) && !maxOrigin(h_max_in,next_h)) begin
                h_max_i_out     <= h_max_i_in;
            end
            // 2) max score currently stored in this systolic cell
            else if (!maxOrigin(h_max_out,next_h)) begin
                h_max_i_out     <= h_max_i_out;
            end
            // 3) newly computed H[i,j] output score
            else begin
                h_max_i_out     <= INDEX;
            end
        end
`endif  // USE_LOCAL_ALIGNMENT

        ////////////////////
        // COMPUTE H[i,j] //
        ////////////////////
        // this one is ALWAYS used
        if (newTargetIn) begin
            // a new target means we are going to see base 0 of the target in
            // the next clock cycle. therefore, we should compute H[i,-1], so
            // it can be used as h_left in the next cycle
`ifdef USE_AFFINE_GAP
    `ifdef  USE_LOCAL_ALIGNMENT
            // INDEX=0 corresponds to base[0] of the query
            if (INDEX == 0) begin
                h_out           <= max(h_in+gapOpen+gapExtend, 0);
            end else begin
                h_out           <= max(h_in+gapExtend, 0);
            end
    `else   // !USE_LOCAL_ALIGNMENT
            if (INDEX == 0) begin
                h_out           <= h_in+gapOpen+gapExtend;
            end else begin
                h_out           <= h_in+gapExtend;
            end
    `endif  // USE_LOCAL_ALIGNMENT
`else   // !USE_AFFINE_GAP
    `ifdef  USE_LOCAL_ALIGNMENT
            h_out               <= max(h_in+gapOpen, 0);
    `else   // !USE_LOCAL_ALIGNMENT
            h_out               <= h_in+gapOpen;
    `endif  // USE_LOCAL_ALIGNMENT
`endif  // USE_AFFINE_GAP
        end else if (enable) begin
            h_out               <= next_h;
        end
    end

    ///////////
    // DEBUG //
    ///////////
    reg                 [31:0]          numEnabledCycles=0;
    reg                 [31:0]          targetLength;
    reg                 [31:0]          numTargets=0;
    reg                 [31:0]          sumTargetLength=0;
    wire                [31:0]          avgTargetLength = sumTargetLength / numTargets;
    reg                                 endTargetIn_1=0;
    always @ (posedge clk) begin
        
        // collect some statistics
        if (newTargetIn) begin
            numTargets          <= numTargets + 1;
            targetLength        <= 0;
        end else if (endTargetIn) begin
            targetLength        <= 0;
            sumTargetLength     <= sumTargetLength + (targetLength + 1);
        end else if (enable) begin
            targetLength        <= targetLength + 1;
        end
        if (enable) begin
            numEnabledCycles    <= numEnabledCycles + 1;
        end

        if (VERBOSE) begin
            endTargetIn_1       <= endTargetIn;
            if (endTargetIn_1) begin
                $display("%t : %s : cell[%0d] : prev target length = %d, average target length = %d", $realtime, NAME, INDEX, targetLength, avgTargetLength);
            end
            if (enable) begin
                $display("%t : %s : cell[%0d,j] : h_out = %d", 
                    $realtime, NAME, 
                    INDEX, 
                    h_out);
`ifdef  USE_AFFINE_GAP
                $display("%t : %s : cell[%0d,j] : e_out = %d, f_out = %d", 
                    $realtime, NAME, 
                    INDEX, 
                    e_out,
                    f_out);
`endif  // USE_AFFINE_GAP
`ifdef  USE_LOCAL_ALIGNMENT
                $display("%t : %s : cell[%0d,j] : h_max_out = %d @ [%0d,j]", 
                    $realtime, NAME, 
                    INDEX, 
                    h_max_out,
                    h_max_i_out);
`endif  // USE_LOCAL_ALIGNMENT
            end
        end
    end

endmodule
