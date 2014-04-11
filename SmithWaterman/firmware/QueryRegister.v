/*
* File Name     : QueryRegister.v
*
* Author        : Corey Olson
*
* Description   : This register is meant to accept Query data from a stream in
*                 sequential fashion (STREAM_W bits at a time), then output
*                 the query bases to the systolic array in parallel.
*                 
*                 The input stream (s1i) comes from an asynchronous FIFO,
*                 called the query FIFO.  We assume that the first transfer of
*                 data from that FIFO contains the information about the query
*                 (e.g. the length).  Subsequent transfers of data contain
*                 the actual query data.  The query data should be stored in
*                 that FIFO in little-endian order (first bases of the query
*                 should be stored in the LS bits of the input data).
*
* Assumptions   : 1) the query enable bits will be asserted by the systolic
*                 cells sequentially, starting with the first bases of the
*                 query.  therefore, if the queryReady bit for cell i+1 is
*                 asserted, we know that cell i is also ready.
*                 2) the number of bases that we load from the input stream
*                 each transfer is a power of 2
*
* Copyright     : 2013, Pico Computing, Inc.
*/
module QueryRegister #(
    parameter NAME                      = "",           // name of this module
    parameter VERBOSE                   = 0,            // set to 1 for verbose debugging statements in simulation

    parameter BASE_W                    = 2,            // width of a single query/target base
    parameter STREAM_W                  = 128,          // width of the input stream of data
    
    parameter MAX_QUERY_LEN             = 100,          // maximum number of bases in a single query
    parameter MAX_QUERY_W               = BASE_W * MAX_QUERY_LEN,
                                                        // width of the query bus coming into this module

    parameter PICOBUS_ADDR              = 0,            // base address for reading/writing PicoBus registers
    
    parameter Q_POS_W                   = clogb2(MAX_QUERY_LEN)
                                                        // log(max_query_length) = number of bits required to store the index of this systolic cell
)
(
    input                               clk,            // Note: this is probably != PicoClk
    input                               rst,
    
    input                               s1i_valid,      // input data is valid when asserted
    input       [STREAM_W-1:0]          s1i_data,       // input target and info data
    output reg                          s1i_rdy,        // we accept data from the input stream when this is asserted

    output      [MAX_QUERY_W-1:0]       queryOut,       // output query data
    output      [MAX_QUERY_LEN-1:0]     queryOutEn,     // enable signals for the output query data
    input       [MAX_QUERY_LEN-1:0]     queryOutReady,  // systolic array is accepting the query and enable when this is asserted

    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input                               PicoClk, 
    input                               PicoRst,
    input   [31:0]                      PicoAddr,
    input   [31:0]                      PicoDataIn, 
    input                               PicoRd, 
    input                               PicoWr,
    output reg  [31:0]                  PicoDataOut
);

    // number of bases that we can load w/ each transfer from the stream
    localparam BASES_PER_TX             = STREAM_W / BASE_W;

    // = log(BASES_PER_TX)
    localparam LOG_BASES_PER_TX         = clogb2(BASES_PER_TX);
    
    // we round the MAX_QUERY_W up to a multiple of the STREAM_W
    localparam MAX_QUERY_W_ROUNDED      = STREAM_W * ((MAX_QUERY_W + STREAM_W - 1) / STREAM_W);

    // this is the maximum number of loads that we should do from the input
    // stream for query data
    // if the query is != MAX_QUERY_LEN, then we may have to do some "dummy"
    // loads, so that we can set the final enable bits for the query to 0
    localparam MAX_NUM_LOADS            = ((MAX_QUERY_LEN + BASES_PER_TX - 1) / BASES_PER_TX);

    // we round the MAX_QUERY_LEN up to a multiple of the BASES_PER_TX
    localparam MAX_QUERY_LEN_ROUNDED    = BASES_PER_TX * MAX_NUM_LOADS;

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
    
    /*
     * Query Data Info Format
     * bits                 Description
     * ------------------------------------------------------
     * Q_POS_W-1:0          query length
     */
    
    // extracts the length field from the query data info
    function [Q_POS_W-1:0] GetLength;
        input   [STREAM_W-1:0]  data;
        begin
            GetLength = data[Q_POS_W-1:0];
        end
    endfunction

    // this loads new query data into the query data register, based upon
    // which set of STREAM_W bits we are loading (n defines that)
    // n = 0-based index that specifies how many transfers of STREAM_W/BASE_W
    // bases have already been loaded into the query register for this query
    function [MAX_QUERY_W_ROUNDED-1:0] LoadQuery;
        input   [MAX_QUERY_W_ROUNDED-1:0]   prevQuery;
        input   [STREAM_W-1:0]              newData;
        input   integer                     n;

        reg     [STREAM_W-1:0]              prevData;
        integer                             bit;
        begin
            LoadQuery = 0;
            // copy the previous query data into the new buffer
            for (bit=0; bit<n*STREAM_W && bit<MAX_QUERY_W_ROUNDED; bit=bit+1) begin
                LoadQuery[bit] = prevQuery[bit];
            end
            // load the new query data into the new buffer
            for (bit=0; bit<STREAM_W; bit=bit+1) begin
                LoadQuery[bit+(n*STREAM_W)] = newData[bit];
            end
        end
    endfunction

    // this sets the enable bits for the new query data being loaded into the
    // query register
    // n = 0-based index that specifies how many transfers of STREAM_W/BASE_W
    // bases have already been loaded into the query register for this query
    // Note: this ONLY modifies the enable bits that are in the range
    // [(n+1)*BASES_PER_TX-1:n*BASES_PER_TX]
    function [MAX_QUERY_LEN_ROUNDED-1:0] SetEnable;
        input   [MAX_QUERY_LEN_ROUNDED-1:0] enable;
        input   [Q_POS_W-1:0]               len;
        input   integer                     n;

        integer                             bit;
        begin
            SetEnable = enable;
            for (bit=0; bit<BASES_PER_TX; bit=bit+1) begin
                // enable bit should only be set for those bases that are <=
                // the length of the query
                if (bit+(n*BASES_PER_TX) >= len) begin
                    SetEnable[bit+(n*BASES_PER_TX)] = 1'b0;
                end else begin
                    SetEnable[bit+(n*BASES_PER_TX)] = 1'b1;
                end
            end
        end
    endfunction

    // this returns 1 if the last base of the current transfer has a ready bit
    // that is asserted.  if that systolic cell is not ready, then we return 0
    function GetReady;
        input   [MAX_QUERY_LEN-1:0] ready;
        input   integer             n;
        begin
            if (BASES_PER_TX*(n+1)-1 >= MAX_QUERY_LEN) begin
                GetReady = ready[MAX_QUERY_LEN-1];
            end else begin
                GetReady = ready[BASES_PER_TX*(n+1)-1];
            end
        end
    endfunction

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////
    
    // this is the query register that we maintain with valid query data.  we
    // only output the LS MAX_QUERY_W bits of this register
    reg [MAX_QUERY_W_ROUNDED-1:0]   query;
    reg [MAX_QUERY_LEN_ROUNDED-1:0] queryEn;

    // our state register
    reg [2:0]                       state=0;
    reg [2:0]                       nextState=0;

    // this is an index that stores how many times we have loaded query data
    // from the input stream
    // Note: this will count from 0 up to numLoads for each query
    reg [Q_POS_W-1:0]               loadIndex=0;
    reg [Q_POS_W-1:0]               loadIndexPlus1=1;

    // this stores the number of times that we will have to load data from the
    // input stream in order to grab all the bases for this query
    reg [Q_POS_W-1:0]               numLoads=0;

    // these are control signals that we assert to load the info about the
    // target sequence (e.g. length, previous score, etc.)
    reg                             loadInfo=0;
    reg                             loadInfo_1=0;

    // this controls when we load data from the input stream into the RefBases
    // register
    reg                             loadData;

    // this flag says that we are loading up some data that we don't care
    // about, so ignore if the input data is actually valid or not
    reg                             dummyLoad;

    // this is the length of the query in bases
    reg [Q_POS_W-1:0]               length;
    
    /////////
    // FSM //
    /////////

    // states
    localparam  INFO        = 0,    // accept the info from the input stream
                READY       = 1,    // wait for the last query base for the next transfer to be ready, which signifies that the previous query's bases were already accepted into the systolic array
                LOAD        = 2,    // load new data into the query register
                HOLD        = 3,    // hold the current query data in the query register until we are certain the bases have been accepted into the systolic array
                DUMMY_READY = 4,    // functions the same as READY, except we aren't going to be loading real data in the next cycle
                DUMMY_LOAD  = 5;    // load some dummy data into the query register in order to set the remaining enable bits to 0
    
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
        dummyLoad   = 0;
        s1i_rdy     = 0;
        
        case (state)
            // accept the info from the input stream
            INFO: begin
                loadInfo                = 1;
                s1i_rdy                 = 1;
                if (s1i_valid) begin
                    nextState           = READY;
                end
            end
            // wait for the last query base for the next transfer to be ready, 
            // which signifies that the previous query's bases were already 
            // accepted into the systolic array
            // -Note: we really just have to wait for that base's ready signal
            // to be asserted
            READY: begin
                if (GetReady(queryOutReady, loadIndex)) begin
                    nextState           = LOAD;
                end
            end
            // load new data into the query register
            LOAD: begin
                loadData                = 1;
                s1i_rdy                 = 1;
                if (s1i_valid) begin
                    // we know that the query length > 0, so we must have >=
                    // 1 load
                    // if we are done loading query data from the input
                    // stream, then we move on to the hold state, where we
                    // verify that the query data was accepted
                    if (loadIndexPlus1 == numLoads) begin
                        if (loadIndexPlus1 == MAX_NUM_LOADS) begin
                            nextState   = HOLD;
                        end else begin
                            nextState   = DUMMY_READY;
                        end
                    end
                    // else we have more query data to load from the input
                    else begin
                        nextState       = READY;
                    end
                end
            end
            // this functions the exact same as the READY state, except we are
            // not going to be loading anything in the state after this one,
            // just setting some enable bits to 0
            DUMMY_READY: begin
                if (GetReady(queryOutReady, loadIndex)) begin
                    nextState           = DUMMY_LOAD;
                end
            end
            // load dummy data into the query register in order to set the
            // enable bits for the final bases of query to 0
            // Note: since we do not set s1i_rdy, we won't actually tell the
            // input stream that we are taking data (as expected, since that
            // next data is for a new query)
            DUMMY_LOAD: begin
                loadData                = 1;
                dummyLoad               = 1;
                if (loadIndexPlus1 == MAX_NUM_LOADS) begin
                    nextState           = HOLD;
                end else begin
                    nextState           = DUMMY_READY;
                end
            end
            // hold the current query data in the query register until 
            // we are certain the bases have been accepted into the 
            // systolic array
            HOLD: begin
                if (!GetReady(queryOutReady, 0)) begin
                    nextState           = INFO;
                end
            end
        endcase
    end

    ////////////////
    // QUERY INFO //
    ////////////////

    // store the length of this query
    // also, delay the loadInfo signal
    always @ (posedge clk) begin
        if (rst) begin
            length                  <= 0;
        end else if (loadInfo) begin
            length                  <= GetLength(s1i_data);
        end
        loadInfo_1                  <= loadInfo;
    end

    // this stores the number of loads that we need to do from the input
    // stream in order to grab all the data for this query
    always @ (posedge clk) begin
        if (rst) begin
            numLoads                <= 0;
        end else if (loadInfo_1) begin
            numLoads                <= (length + BASES_PER_TX - 1) >> LOG_BASES_PER_TX;
        end
    end

    ////////////////////
    // QUERY REGISTER //
    ////////////////////
    
    // our output query data is really just the LS MAX_QUERY_W bits of the
    // query register
    assign queryOut                 = query     [MAX_QUERY_W-1:0];
    assign queryOutEn               = queryEn   [MAX_QUERY_LEN-1:0];

    // the query data register that we manage
    // -also controls the query enable signals
    // -also stores a counter that says how many times we have loaded query
    // data from the input stream
    always @ (posedge clk) begin
        if (rst) begin
            query                   <= 'hX;
            queryEn                 <= 0;
            loadIndex               <= 0;
            loadIndexPlus1          <= 1;
        end else if (loadData) begin
            query                   <= LoadQuery(query, s1i_data, loadIndex);
            queryEn                 <= SetEnable(queryEn, length, loadIndex);
            // we only increment our counters if we actually loaded valid data
            if (s1i_valid || dummyLoad) begin
                loadIndex           <= loadIndex + 1;
                loadIndexPlus1      <= loadIndexPlus1 + 1;
            end
        end else if (loadInfo) begin
            loadIndex               <= 0;
            loadIndexPlus1          <= 1;
        end
    end
    
    ///////////
    // DEBUG //
    ///////////
    
    // debug counters / registers
    reg     [31:0]                  status;             // current status of specified signals
    reg     [31:0]                  count_queries;      // total number of queries
    reg     [31:0]                  count_loads;        // total number of loads
    reg     [31:0]                  avg_loads;          // average number of loads per query
    wire    [31:0]                  version = 32'h0001; // version 0x0101 = version 1.1
    reg                             load_query_1;
    always @ (posedge clk) begin
        if (rst) begin
            status              <= 'hX;
            count_queries       <= 0;
            count_loads         <= 0;
            avg_loads           <= 0;
        end else begin
            // 1) count the number of queries that we load
            if (s1i_valid && s1i_rdy && loadInfo) begin
                count_queries   <= count_queries + 1;
                if (VERBOSE) $display("%t : %s : starting new query [%0d]", $realtime, NAME, count_queries);
            end
            // 2) count the number of loads per query
            if (s1i_valid && s1i_rdy && loadData) begin
                count_loads     <= count_loads + 1;
                if (VERBOSE) $display("%t : %s : loading data from input stream [%0d]", $realtime, NAME, count_loads);
            end
            // 4) make some status signals available
            status              <= {s1i_valid,
                                    s1i_rdy,
                                    1'b0,
                                    state,
                                    1'b0,
                                    loadInfo,
                                    loadData,
                                    dummyLoad,
                                    {(16-Q_POS_W){1'b0}},
                                    numLoads};
            // 3) compute the average query length
            avg_loads           <= count_loads / count_queries;
            load_query_1        <= s1i_valid & s1i_rdy & loadInfo;
            if (load_query_1 && VERBOSE) $display("%t : %s : average loads per query = %0d", $realtime, NAME, avg_loads);
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
    reg     [31:0]                  count_queries_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_queries_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_loads_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  count_loads_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryOutReady_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  queryOutReady_2;
    (* shreg_extract = "no" *)
    reg     [31:0]                  loadIndex_1;
    (* shreg_extract = "no" *)
    reg     [31:0]                  loadIndex_2;
    always @ (posedge PicoClk) begin
        status_1        <= status;
        status_2        <= status_1;
        count_queries_1 <= count_queries;
        count_queries_2 <= count_queries_1;
        count_loads_1   <= count_loads;
        count_loads_2   <= count_loads_1;
        queryOutReady_1 <= queryOutReady;
        queryOutReady_2 <= queryOutReady_1;
        loadIndex_1     <= loadIndex;
        loadIndex_2     <= loadIndex_1;
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
                (PICOBUS_ADDR+32'h10):  PicoDataOut<= count_queries_2;
                (PICOBUS_ADDR+32'h20):  PicoDataOut<= count_loads_2;
                (PICOBUS_ADDR+32'h30):  PicoDataOut<= status_2;
                (PICOBUS_ADDR+32'h40):  PicoDataOut<= queryOutReady_2;
                (PICOBUS_ADDR+32'h50):  PicoDataOut<= loadIndex_2;
            endcase
        end else begin
            PicoDataOut    <= 0;
        end
    end


endmodule
