/*
* File Name     : RefShiftRegister.v
*
* Author        : Corey Olson
* 
* Description   : The primary function of this module is to implement
*                 a parallel-load, serial data out, shift register.  This is
*                 use to shift target data to a systolic array, 1 base at
*                 a time.
*                 
*                 This module assumes that all data (info and actual target
*                 data) come in on a single stream.  For each target, we first
*                 load in the length of the target.  We then iteratively load
*                 in new target data, then shift it out.  The endianness with
*                 which we shift is set by the ENDIANNESS parameter.
*                 
*                 Before we start a target sequence, we first send the
*                 s1o_start signal, for 1 cycle.  The systolic array will then
*                 reset it's scoring cells, and it will load in the new bases
*                 of the query.  Note that s1o_valid does not need to be
*                 asserted in the cycle that s1o_start is asserted.
*                 
*                 After the s1o_start signal is asserted, the systolic array
*                 will align the target data (that we send on s1o_data) until
*                 we send a base where the s1o_valid and s1o_last signals are
*                 asserted in the same cycle.  That condition signifies the
*                 last base of a target sequence.
*
*                 After sending the last base of a target sequence, this
*                 module should try to load a new target (starting w/ the
*                 info).
*
* Assumptions   : 1) T_POS_W <= 16
*                 2) SCORE_W <= (128-16)
*
* Copyright 2011 Pico Computing, Inc.
*/
`include "PicoDefines.v"
module RefShiftRegister #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 0,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter STREAM_W                  = 128,          // width of the input stream of data
    
    parameter ENDIANNESS                = "LS",         // this defines how we shift data out of the shift register
                                                        // "LS" = shift the LS bits out first
                                                        // "MS" = shift the MS bits out first
    
    parameter SCORE_W                   = 9,            // width of the score in the systolic array

    parameter T_POS_W                   = 9,            // log(max_target_length) = number of bits required to store the index of the target base currently being processed
    parameter PICOBUS_ADDR              = 0
    )
    (
    
    input                               clk,            // Note: this is probably != PicoClk
    input                               rst,
    
    input                               s1i_valid,      // input data is valid when asserted
    input   [STREAM_W-1:0]              s1i_data,       // input target and info data
    output reg                          s1i_rdy,        // we accept data from the input stream when this is asserted

    output  [BASE_W-1:0]                s1o_data,       // single base to the systolic array
    output reg                          s1o_valid,      // single base to the systolic array is valid
    input                               s1o_rdy,        // output of the systolic array is ready to accept a new score
    output reg                          s1o_last,       // if s1o_valid is also asserted, then this is the last base for a target
    output reg                          s1o_start,      // we are starting a new target on the next cycle when this is asserted
    output reg signed   [SCORE_W-1:0]   s1o_score,      // score of the preceding query-target alignment (valid when s1o_start is asserted)

    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input                               PicoClk, 
    input                               PicoRst,
    input   [31:0]                      PicoAddr,
    input   [31:0]                      PicoDataIn, 
    input                               PicoRd, 
    input                               PicoWr,
    output reg  [31:0]                  PicoDataOut
    );

    //////////////////////
    // LOCAL PARAMETERS //
    //////////////////////

    // width of the input reference data bus and the reference data shift
    // register
    localparam BASES_PER_TX = STREAM_W / BASE_W;
    
    ///////////////
    // FUNCTIONS //
    ///////////////

    // determines the next base that should be outputted from the data
    // shift register, based upon the ENDIANNESS parameter
    function [BASE_W-1:0] GetNextBase;
        input   [STREAM_W-1:0]  data;
        begin
            // output the LS bits of the shifter as the next base
            if (ENDIANNESS == "LS") begin
                GetNextBase = data[BASE_W-1:0];
            end 
            // output the LS bits of the shifter as the next base
            // ENDIANNESS == "MS"
            else begin
                GetNextBase = data[STREAM_W-1:STREAM_W-BASE_W];
            end
        end
    endfunction

    // shifts the data shift register in the "right" direction
    // depends upon the ENDIANNESS parameter
    // "LS" = shift to the right
    // "MS" = shift to the left
    function [STREAM_W-1:0] ShiftBases;
        input   [STREAM_W-1:0]    data;
        begin
            if (ENDIANNESS == "LS") begin
                ShiftBases = data >> BASE_W;
            end
            // ENDIANNESS = "MS"
            else begin
                ShiftBases = data << BASE_W;
            end
        end
    endfunction

    /*
     * Target Data Info Format
     * bits                 Description
     * ------------------------------------------------------
     * T_POS_W-1:0          target length
     * 16+SCORE_W-1:16      prior target-query alignment score
     */
    
    // extracts the length field from the target data info
    function [T_POS_W-1:0] GetLength;
        input   [STREAM_W-1:0]  data;
        begin
            GetLength = data[T_POS_W-1:0];
        end
    endfunction

    // extracts the score field from the target data info
    function signed [SCORE_W-1:0] GetScore;
        input   [STREAM_W-1:0]  data;
        begin
            GetScore = data[SCORE_W+16-1:16];
        end
    endfunction

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////
    
    // our state register
    reg [2:0]                       state=0;
    reg [2:0]                       nextState=0;
    
    // this is the target data shift register that we maintain
    reg [STREAM_W-1:0]              RefBases;
    reg                             loadRefBases;

    // these are control signals that we assert to load the info about the
    // target sequence (e.g. length, previous score, etc.)
    reg                             loadInfo;
    reg                             loadInfo_1;

    // this controls when we load data from the input stream into the RefBases
    // register
    reg                             loadData;

    // this command tells us when to shift the bases in the target data
    // shifter
    // this should be asserted every time we are outputting a valid base to
    // the systolic array
    reg                             shiftData;

    // this is the length of the target in bases
    reg [T_POS_W-1:0]               length;

    // this is a dynamic count of the number of bases that we have left to
    // send
    // Note: we are done sending all bases when this = 0
    reg [T_POS_W-1:0]               basesLeft;

    // this register is used to know when we must load more target bases from
    // the input data stream
    // -we are shifting the last base out of the shift register when this = 1
    reg [T_POS_W-1:0]               basesInShifter;

    // this is the score of the prior target-query alignment
    reg signed  [SCORE_W-1:0]       score;
	
    /////////
    // FSM //
    /////////

    // states
    localparam  INFO    = 0,    // accept the info from the input stream
                START   = 1,    // assert the start signal in this state
                LOAD    = 2,    // load new data into the shift register
                SHIFT   = 3,    // shift the data out to the systolic array until we either need to load more or until we are about to shift out the last base
                LAST    = 4;    // send the last base and assert the last out signal

    always @ (posedge clk) begin
        if (rst) begin
            state   <= INFO;
        end else begin
            state   <= nextState;
        end
    end

    // next state logic
    always @ (*) begin

        nextState   = state;
        loadInfo    = 0;
        loadData    = 0;
        shiftData   = 0;
        s1i_rdy     = 0;
        s1o_valid   = 0;
        s1o_start   = 0;
        s1o_last    = 0;
        
        case (state)
            // load the info for the next target from the input target data
            // stream
            INFO: begin
                loadInfo            = 1;
                s1i_rdy             = 1;
                if (s1i_valid) begin
                    nextState       = START;
                end
            end
            // send the start signal to the systolic array
            // -delay here until we can start a new alignment
            START: begin
                if (s1o_rdy) begin
                    s1o_start       = 1;
                    nextState       = LOAD;
                end
            end
            // load some data from the input stream
            // -once we have loaded the data, move on to the shift state, where
            // we should start shifting it out
            LOAD: begin
                loadData            = 1;
                s1i_rdy             = 1;
                if (s1i_valid) begin
                    // if we are about to shift out the last base for this
                    // target, then we want to go to the LAST state
                    if (basesLeft == 1) begin
                        nextState   = LAST;
                    end
                    // if we are not about to send the last base, let's just
                    // go do some normal shifting
                    else begin
                        nextState   = SHIFT;
                    end
                end
            end
            // in this state, we know we have valid data in our shifter
            // -we have previously checked that this next base will not be the
            // last that we are shifting out
            // -we should check that the next base we are going to shift out
            // in the next cycle will not be the last one
            // -we should check to see if we need to load some more valid data
            SHIFT: begin
                s1o_valid           = 1;
                shiftData           = 1;
                // if the next base that we are going to shift out is the
                // last one for this target, then go to the LAST state
                // Note: if we got to this point, then the number of valid
                // bases in the shifter must be >= 1, because otherwise we
                // would have gone from the LOAD state to the LAST state
                if (basesLeft == 2) begin
                    nextState       = LAST;
                end
                // else if this was the last base in this shift register,
                // then we'd better go fetch some more target data from2
                // the input data stream
                else if (basesInShifter == 1) begin
                    nextState       = LOAD;
                end
            end
            // in this state, we know that we have 1 more base to shift out
            // therefore, we should assert the s1o_last signal, shift the base
            // out, then go back to the INFO state
            LAST: begin
                s1o_last            = 1;
                s1o_valid           = 1;
                nextState           = INFO;
            end
            // should never get to this state
            default: nextState      = INFO;
        endcase
    end

    /////////////////
    // TARGET INFO //
    /////////////////

    // store the length of this target
    // also, delay the loadInfo signal
    always @ (posedge clk) begin
        if (rst) begin
            length              <= 0;
        end else if (loadInfo) begin
            length              <= GetLength(s1i_data);
        end
        loadInfo_1              <= loadInfo;
    end

    // this stores the total number of bases that we have left to send
    always @ (posedge clk) begin
        if (rst) begin
            basesLeft           <= 0;
        end 
        // load the number of bases that we have to send for this target
        else if (loadInfo_1) begin
            basesLeft           <= length;
        end
        // decrement our count every time we send a base
        else if (shiftData) begin
            basesLeft           <= basesLeft - 1;
        end
    end
    
    // grab the previous score from the info
    always @ (posedge clk) begin
        if (rst) begin
            s1o_score           <= 0;
        end else if (loadInfo) begin
            s1o_score           <= GetScore(s1i_data);
        end
    end

    /////////////
    // SHIFTER //
    /////////////
    
    // this is the base that we output
    assign s1o_data = GetNextBase(RefBases);
    
    // target data shifter
    // -the output of this module will either be the LS bits or MS bits of this
    // shifter
    always @(posedge clk) begin
        if(rst) begin
            RefBases            <= 'hX;
        end else if (loadData) begin
            RefBases            <= s1i_data;
        end else if (shiftData) begin
            RefBases            <= ShiftBases(RefBases);
        end
    end

    // maintain a count of the number of valid bases in the shifter
    always @ (posedge clk) begin
        if (rst) begin
            basesInShifter      <= 0;
        end 
        // if we are loading new data into the shift register, then we need to
        // reset the count of how many valid bases we have in that shift
        // register (RefBases)
        else if (loadData) begin
            // if there are more bases left to send than can fit into the
            // reference shifter, then just say that all bases in the
            // reference shifter are valid
            if (basesLeft >= BASES_PER_TX) begin
                basesInShifter  <= BASES_PER_TX;
            end
            // else if there are fewer bases left to send than will fit into
            // the shifter, record how many of the bases in the shifter are
            // actually valid
            else begin
                basesInShifter  <= basesLeft;
            end
        end
        // else if we are shifting out a base, then we should decrement the
        // count of the number of valid bases in the shifter
        else if (shiftData) begin
            basesInShifter      <= basesInShifter - 1;
        end
    end

    ///////////
    // DEBUG //
    ///////////
    
    // debug counters / registers
    reg     [31:0]                  status;             // current status of specified signals
    reg     [31:0]                  count_targets;      // total number of targets that we align
    reg     [31:0]                  count_bases;        // total number of valid bases that we output
    reg     [31:0]                  count_loads;        // total number of loads from the input (not including the info)
    reg     [31:0]                  count_start;        // counts the total number of start bits sent
    reg     [31:0]                  count_last;         // counts the total number of last bits sent
    wire    [31:0]                  version = 32'h0001; // version 0x0101 = version 1.1
    always @ (posedge clk) begin
        if (rst) begin
            status              <= 'hX;
            count_targets       <= 0;
            count_bases         <= 0;
            count_loads         <= 0;
            count_start         <= 0;
            count_last          <= 0;
        end else begin
            // 1) count the number of targets that we load
            if (s1i_valid && s1i_rdy && loadInfo) begin
                count_targets   <= count_targets + 1;
                if (VERBOSE) $display("%t : %s : starting new target [%0d]", $realtime, NAME, count_targets);
            end
            // 2) count the number of loads of data from the input stream
            if (s1i_valid && s1i_rdy && loadData) begin
                count_loads     <= count_loads + 1;
                if (VERBOSE) $display("%t : %s : loading data from input stream [%0d]", $realtime, NAME, count_loads);
            end
            // 3) count the number of valid bases that we output
            if (s1o_valid) begin
                count_bases     <= count_bases + 1;
                if (VERBOSE) $display("%t : %s : sending base [%0d] to systolic array = %0d", $realtime, NAME, count_bases, s1o_data);
            end
            // 4) make some status signals available
            status              <= {1'h0,
                                    state,
                                    1'h0,
                                    loadInfo,
                                    loadData,
                                    shiftData,
                                    2'h0,
                                    s1i_valid,
                                    s1i_rdy,
                                    s1o_valid,
                                    s1o_rdy,
                                    s1o_start,
                                    s1o_last};
            // 5) count the start bits sent
            if (s1o_start) begin
                count_start     <= count_start + 1;
                if (VERBOSE) $display("%t : %s : sending start bit [%0d] to systolic array", $realtime, NAME, count_start);
            end
            // 6) count the last bits sent
            if (s1o_valid && s1o_last) begin
                count_last      <= count_last + 1;
                if (VERBOSE) $display("%t : %s : sending last bit [%0d] to systolic array", $realtime, NAME, count_last);
            end
        end
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
    reg     [31:0]                  count_targets_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_targets_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_loads_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_loads_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_bases_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_bases_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  length_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  length_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  basesLeft_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  basesLeft_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  basesInShifter_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  basesInShifter_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_start_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_start_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_last_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_last_2;
    always @ (posedge PicoClk) begin
        status_1        <= status;
        status_2        <= status_1;
        count_targets_1 <= count_targets;
        count_targets_2 <= count_targets_1;
        count_loads_1   <= count_loads;
        count_loads_2   <= count_loads_1;
        count_bases_1   <= count_bases;
        count_bases_2   <= count_bases_1;
        length_1        <= length;
        length_2        <= length_1;
        basesLeft_1     <= basesLeft;
        basesLeft_2     <= basesLeft_1;
        basesInShifter_1<= basesInShifter;
        basesInShifter_2<= basesInShifter_1;
        count_start_1   <= count_start;
        count_start_2   <= count_start_1;
        count_last_1    <= count_last;
        count_last_2    <= count_last_1;
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
                (PICOBUS_ADDR+32'h10):  PicoDataOut<= count_targets_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOut<= count_loads_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOut<= status_2;
                (PICOBUS_ADDR+32'h40):  PicoDataOut<= count_bases_2;
                (PICOBUS_ADDR+32'h50):  PicoDataOut<= length_2;
                (PICOBUS_ADDR+32'h60):  PicoDataOut<= basesLeft_2;
                (PICOBUS_ADDR+32'h70):  PicoDataOut<= basesInShifter_2;
                (PICOBUS_ADDR+32'h80):  PicoDataOut<= count_start_2;
                (PICOBUS_ADDR+32'h90):  PicoDataOut<= count_last_2;
            endcase
        end else begin
            PicoDataOut    <= 0;
        end
    end
endmodule 
