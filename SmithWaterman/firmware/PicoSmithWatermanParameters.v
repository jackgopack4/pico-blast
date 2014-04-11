/*
* File Name     : PicoSmithWatermanParameters.v
*
* Author        : Corey Olson
*
* Description   : This file sets some parameters that are in turn used by the
*                 PicoSmithWaterman module.
*                   
*                 Assume we have included both PicoDefines.v and
*                 PicoSmithWatermanDefines.v before including this file.
*
* Copyright     : 2013, Pico Computing, Inc.
*/

// pull in the defintions from our PicoDefines.v file
`include "PicoDefines.v"

// some defines that are specific to the SmithWaterman stuff
`include "PicoSmithWatermanDefines.v"

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

// maximum length of a single query
// this is used to set the Q_POS_W
`ifdef MAX_QUERY_LENGTH
localparam MAX_QUERY_LENGTH     = `MAX_QUERY_LENGTH;
`else
localparam MAX_QUERY_LENGTH     = 100;
`endif
localparam Q_POS_W              = clogb2(MAX_QUERY_LENGTH);

// maximum length of a single target
// this is used to set the T_POS_W
`ifdef MAX_TARGET_LENGTH
localparam MAX_TARGET_LENGTH    = `MAX_TARGET_LENGTH;
`else
localparam MAX_TARGET_LENGTH    = 100;
`endif
localparam T_POS_W              = clogb2(MAX_TARGET_LENGTH);

// at this point, we assume that we have defined the number of SmithWaterman
// engines, so we just use that definition
localparam NUM_SW_UNITS         = `NUM_SW_UNITS;

// smith-waterman clock frequency (in MHz)
// for now, we only support 125 MHz clock frequency
// this is only here, because it may change in the future
// TODO: support a variable SW_CLK_FREQ
`ifdef SW_CLK_FREQ
localparam SW_CLK_FREQ          = 125;
`else
localparam SW_CLK_FREQ          = 125;
`endif

// these are the number of bits for the H, E, and F scores in the systolic
// array. we can probably compute this based upon the MAX_QUERY_LEN and some
// bounds on the affine-gap scoring, but for now, we just let users set it
// here
// TODO: compute the SCORE_W automatically
`ifdef SCORE_W
localparam SCORE_W              = `SCORE_W;
`else
localparam SCORE_W              = 10;
`endif

// for now, we just assume that all Smith-Waterman engines have the same
// stream width, independent of what it says in PicoDefines.v.  this is
// probably a safe assumption for now, as what we really want to do is to be
// able to remove a lot of those defines in PicoDefines.v, thereby forcing the
// streams to have the same width
`ifdef STREAM1_IN_WIDTH
localparam STREAM_W             = `STREAM1_IN_WIDTH;
`else
`MUST_DEFINE_STREAM1_WIDTH
`endif
    
// width of a single nucleotide base on a stream.  this could allow us to send
// ASCII data on the input stream, then convert it to a 2-bit per base
// representation.  for now, let's just stick w/ 2-bits per base.
// TODO: if I want to send ASCII data on the input stream, do some conversion
`ifdef STREAM_BASE_WIDTH
localparam STREAM_BASE_W        = `STREAM_BASE_WIDTH;
`else
localparam STREAM_BASE_W        = 2;
`endif

// this is the number of bases that we get per transfer on the input stream
localparam STREAM_BASES_PER_TX  = STREAM_W / STREAM_BASE_W;

// internal encoding size for a single nucleotide base
localparam INT_BASE_W           = 2;
localparam INT_STREAM_W         = STREAM_W / STREAM_BASE_W * INT_BASE_W;

// this is the number of bases that we get per transfer on the internal stream
// Note: this is analogous to STREAM_BASES_PER_TX
localparam INT_BASES_PER_TX     = INT_STREAM_W / INT_BASE_W;

// this is the increment amount for the base address for 1 SmWaWrapper to the
// next
localparam PICOBUS_ADDR_INCR    = 32'h10000;

// number of cycles that we delay reset with respect to the stream reset
localparam RST_PIPE_STAGES      = 16;
