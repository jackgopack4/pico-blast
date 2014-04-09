/*
* File Name     : PicoSmithWaterman.v
*
* Creation Date : Mon 25 Feb 2013 11:07:53 AM CDT
*
* Author        : Corey Olson
*
* Last Modified : Wed 03 Apr 2013 09:10:32 AM CDT
*
* Description   : This is the top-level module for instantiating 1 or more
*                 Smith-Waterman or Needleman-Wunsch compute engines in a Pico
*                 Computing M-Series module.
*
*                 This logic relies completely upon the streaming
*                 communication model.  It does not access the FPGA's off-chip
*                 memory.  In other words, both the query and target must be
*                 sent to this module via one of the input streams.
*                 
*                 To instantiate multiple Smith-Waterman compute engines in
*                 this system, simply 
*                 `define   SW_UNITS_X 
*                 in your PicoDefines.v file, where X is the number of compute 
*                 engines that you want.  The range of X is [1:10].  Note that
*                 you must also define the width of each stream.  For example,
*                 assuming you want 2 Smith-Waterman engines, you must have
*                 the following 5 total lines in your PicoDefines.v file:
*                 `define   SW_UNITS_5
*                 `define   STREAM1_IN_WIDTH    128
*                 `define   STREAM1_OUT_WIDTH   128
*                 `define   STREAM2_IN_WIDTH    128
*                 `define   STREAM2_OUT_WIDTH   128
*
*                 Note that the longer you make the query, the fewer 
*                 Smith-Waterman engines you will be able to fit into a single 
*                 device.  The resources required are fairly independent of 
*                 the MAX_TARGET_LENGTH.
*                 
*                 You can control the maximum query and target length by
*                 defining adding the 2 following lines to your PicoDefines.v
*                 file:
*                 `define MAX_QUERY_LEN     Q
*                 `define MAX_TARGET_LEN    T
*                 where Q is the maximum query length that you want, and T is
*                 the maximum target length that you want to support.  If
*                 these are not defined, the default values are set later in
*                 this file (PicoSmithWaterman.v).
*
*                 -Format of data on input stream:
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
*                 M         127:64              *_qle
*                           63:0                reserved
*                 M+1       127:64              *_gtle
*                           63:0                *_tle
*                 M+2       127:64              *_max_off
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
*                 M         127:64              *_qle
*                           63:0                reserved
*                 M+1       127:64              *_gtle
*                           63:0                *_tle
*                 M+2       127:64              *_max_off
*                           63:0                *_gscore
*
* Assumptions   : 1) we align exactly 1 target per 1 query
*                 2) both the query and the target are sent on the same
*                    stream, in that order
*                 3) the affine-gap scoring model must be set via the PicoBus
*                    before aligning any queries/targets
*                 4) different Smith-Waterman engines instantiated in this
*                    module can use different affine-gap scoring schemes, as
*                    they are set independely via the PicoBus (i.e. 1 scoring
*                    scheme per SmWaWrapper module)
*                 5) for now, each target-query alignment pair produce exactly
*                    1 result in the output stream
*                 6) we must instantiate at least 1 SmWaWrapper module
*
* Copyright     : 2013, Pico Computing, Inc.
*/
`include "PicoDefines.v"
`include "PicoSmithWatermanDefines.v"
module PicoSmithWaterman #(
    parameter NAME                      = "PicoSmithWaterman",           
                                                        // name of this module
    parameter VERBOSE                   = 1,            // set to 1 for verbose debugging statements in simulation
    parameter PICOBUS_ADDR              = 0             // base address for reading/writing this module via the PicoBus
)
(
    // The clk and rst signals are shared between all the streams in this module
    input                               clk,
    input                               rst,

    ///////////////////
    // SmWaWrapper 1 //
    ///////////////////
    input                               s1i_valid,
    output                              s1i_rdy,
    input   [`STREAM1_IN_WIDTH-1:0]     s1i_data,
    
    output                              s1o_valid,
    input                               s1o_rdy,
    output  [`STREAM1_OUT_WIDTH-1:0]    s1o_data,

    ///////////////////
    // SmWaWrapper 2 //
    ///////////////////
`ifdef  SW_UNITS_2
    input                               s2i_valid,
    output                              s2i_rdy,
    input   [`STREAM2_IN_WIDTH-1:0]     s2i_data,
    
    output                              s2o_valid,
    input                               s2o_rdy,
    output  [`STREAM2_OUT_WIDTH-1:0]    s2o_data,
`endif  // SW_UNITS_2

    ///////////////////
    // SmWaWrapper 3 //
    ///////////////////
`ifdef  SW_UNITS_3
    input                               s3i_valid,
    output                              s3i_rdy,
    input   [`STREAM3_IN_WIDTH-1:0]     s3i_data,
    
    output                              s3o_valid,
    input                               s3o_rdy,
    output  [`STREAM3_OUT_WIDTH-1:0]    s3o_data,
`endif  // SW_UNITS_3

    ///////////////////
    // SmWaWrapper 4 //
    ///////////////////
`ifdef  SW_UNITS_4
    input                               s4i_valid,
    output                              s4i_rdy,
    input   [`STREAM4_IN_WIDTH-1:0]     s4i_data,
    
    output                              s4o_valid,
    input                               s4o_rdy,
    output  [`STREAM4_OUT_WIDTH-1:0]    s4o_data,
`endif  // SW_UNITS_4

    ///////////////////
    // SmWaWrapper 5 //
    ///////////////////
`ifdef  SW_UNITS_5
    input                               s5i_valid,
    output                              s5i_rdy,
    input   [`STREAM5_IN_WIDTH-1:0]     s5i_data,
    
    output                              s5o_valid,
    input                               s5o_rdy,
    output  [`STREAM5_OUT_WIDTH-1:0]    s5o_data,
`endif  // SW_UNITS_5

    ///////////////////
    // SmWaWrapper 6 //
    ///////////////////
`ifdef  SW_UNITS_6
    input                               s6i_valid,
    output                              s6i_rdy,
    input   [`STREAM6_IN_WIDTH-1:0]     s6i_data,
    
    output                              s6o_valid,
    input                               s6o_rdy,
    output  [`STREAM6_OUT_WIDTH-1:0]    s6o_data,
`endif  // SW_UNITS_6

    ///////////////////
    // SmWaWrapper 7 //
    ///////////////////
`ifdef  SW_UNITS_7
    input                               s7i_valid,
    output                              s7i_rdy,
    input   [`STREAM7_IN_WIDTH-1:0]     s7i_data,
    
    output                              s7o_valid,
    input                               s7o_rdy,
    output  [`STREAM7_OUT_WIDTH-1:0]    s7o_data,
`endif  // SW_UNITS_7

    ///////////////////
    // SmWaWrapper 8 //
    ///////////////////
`ifdef  SW_UNITS_8
    input                               s8i_valid,
    output                              s8i_rdy,
    input   [`STREAM8_IN_WIDTH-1:0]     s8i_data,
    
    output                              s8o_valid,
    input                               s8o_rdy,
    output  [`STREAM8_OUT_WIDTH-1:0]    s8o_data,
`endif  // SW_UNITS_8

    ///////////////////
    // SmWaWrapper 9 //
    ///////////////////
`ifdef  SW_UNITS_9
    input                               s9i_valid,
    output                              s9i_rdy,
    input   [`STREAM9_IN_WIDTH-1:0]     s9i_data,
    
    output                              s9o_valid,
    input                               s9o_rdy,
    output  [`STREAM9_OUT_WIDTH-1:0]    s9o_data,
`endif  // SW_UNITS_9

    ///////////////////
    // SmWaWrapper 10 //
    ///////////////////
`ifdef  SW_UNITS_10
    input                               s10i_valid,
    output                              s10i_rdy,
    input   [`STREAM10_IN_WIDTH-1:0]    s10i_data,
    
    output                              s10o_valid,
    input                               s10o_rdy,
    output  [`STREAM10_OUT_WIDTH-1:0]   s10o_data,
`endif  // SW_UNITS_10

    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input                               PicoClk, 
    input                               PicoRst,
    input  [31:0]                       PicoAddr,
    input  [31:0]                       PicoDataIn, 
    input                               PicoRd, 
    input                               PicoWr,
    output reg  [31:0]                  PicoDataOut
);
    ////////////////
    // PARAMETERS //
    ////////////////
    
    // all the parameters that get used in this system are set in this file
    `include "PicoSmithWatermanParameters.v"

    //////////////////////
    // INTERNAL SIGNALS //
    //////////////////////
    
    // we register the reset for a few cycles to avoid DRC erros in simulation
    reg     [RST_PIPE_STAGES-1:0]       rst_q=0;

    // this is the slower clock that we use to run the Smith-Waterman engines
    wire                                clkSmWa;

    // this is the reset that is synchronous to the slower clock
    reg     [RST_PIPE_STAGES-1:0]       rstSmWa=0;

    // Input signals
    // The number of input signals will be twice the number of SmWa units,
    // because there will be seprate signals for query sequence and database sequence.
    wire                                si_valid        [0:NUM_SW_UNITS-1];
    wire                                si_rdy          [0:NUM_SW_UNITS-1];
    wire    [STREAM_W-1:0]              si_data         [0:NUM_SW_UNITS-1];
    
    // this is the stream data that is destined for the SmWaWrapper
    wire                                si_valid_SmWa   [0:NUM_SW_UNITS-1];
    wire                                si_rdy_SmWa     [0:NUM_SW_UNITS-1];
    wire    [INT_STREAM_W-1:0]          si_data_SmWa    [0:NUM_SW_UNITS-1];

    // this is the stream data that is destined for the FIFO
    wire                                si_valid_FIFO   [0:NUM_SW_UNITS-1];
    wire                                si_rdy_FIFO     [0:NUM_SW_UNITS-1];
    wire    [STREAM_W-1:0]              si_data_FIFO    [0:NUM_SW_UNITS-1];
    wire                                si_full_FIFO    [0:NUM_SW_UNITS-1];

    // this is the stream data that comes out of the sideband fifo
    wire                                so_valid_FIFO   [0:NUM_SW_UNITS-1];
    wire                                so_rdy_FIFO     [0:NUM_SW_UNITS-1];
    wire    [STREAM_W-1:0]              so_data_FIFO    [0:NUM_SW_UNITS-1];
    wire                                so_empty_FIFO   [0:NUM_SW_UNITS-1];

    // this is the data that comes out of the SmWaWrapper module
    wire                                so_valid_SmWa   [0:NUM_SW_UNITS-1];
    wire                                so_rdy_SmWa     [0:NUM_SW_UNITS-1];
    wire    [STREAM_W-1:0]              so_data_SmWa    [0:NUM_SW_UNITS-1];
    
    // Output signals
    wire                                so_valid        [0:NUM_SW_UNITS-1];
    wire                                so_rdy          [0:NUM_SW_UNITS-1];
    wire    [STREAM_W-1:0]              so_data         [0:NUM_SW_UNITS-1];
    
    // actual PicoBus data is this OR'd with PicoBus output data from sub-modules
    reg     [31:0]                      PicoDataOutLocal;   // local PicoBus data
    wire    [31:0]                      PicoDataOutSub0 [0:NUM_SW_UNITS-1];    
                                                            // PicoDataOut from SmWaWrapper modules
    wire    [31:0]                      PicoDataOutSub1 [0:NUM_SW_UNITS-1];
                                                            // PicoDataOut from SplitStream modules
    wire    [31:0]                      PicoDataOutSub2 [0:NUM_SW_UNITS-1];
                                                            // PicoDataOut from MergeStream modules
    wire    [31:0]                      version = 32'h0001; // version 0x0101 = version 1.1

    ///////////
    // ARRAY //
    ///////////

    // Store the input and output signals in the array. These array
    // elements can be easiy accessed in the generate for loop.
    `ifdef  SW_UNITS_1
        assign si_valid [0] = s1i_valid;
        assign si_data  [0] = s1i_data;
        assign s1i_rdy      = si_rdy    [0];

        assign s1o_valid    = so_valid  [0];
        assign s1o_data     = so_data   [0];
        assign so_rdy   [0] = s1o_rdy;
    `endif  // SW_UNITS_1
    `ifdef  SW_UNITS_2
        assign si_valid [1] = s2i_valid;
        assign si_data  [1] = s2i_data;
        assign s2i_rdy      = si_rdy    [1];

        assign s2o_valid    = so_valid  [1];
        assign s2o_data     = so_data   [1];
        assign so_rdy   [1] = s2o_rdy;
    `endif  // SW_UNITS_2
    `ifdef  SW_UNITS_3
        assign si_valid [2] = s3i_valid;
        assign si_data  [2] = s3i_data;
        assign s3i_rdy      = si_rdy    [2];

        assign s3o_valid    = so_valid  [2];
        assign s3o_data     = so_data   [2];
        assign so_rdy   [2] = s3o_rdy;
    `endif  // SW_UNITS_3
    `ifdef  SW_UNITS_4
        assign si_valid [3] = s4i_valid;
        assign si_data  [3] = s4i_data;
        assign s4i_rdy      = si_rdy    [3];

        assign s4o_valid    = so_valid  [3];
        assign s4o_data     = so_data   [3];
        assign so_rdy   [3] = s4o_rdy;
    `endif  // SW_UNITS_4
    `ifdef  SW_UNITS_5
        assign si_valid [4] = s5i_valid;
        assign si_data  [4] = s5i_data;
        assign s5i_rdy      = si_rdy    [4];

        assign s5o_valid    = so_valid  [4];
        assign s5o_data     = so_data   [4];
        assign so_rdy   [4] = s5o_rdy;
    `endif  // SW_UNITS_5
    `ifdef  SW_UNITS_6
        assign si_valid [5] = s6i_valid;
        assign si_data  [5] = s6i_data;
        assign s6i_rdy      = si_rdy    [5];

        assign s6o_valid    = so_valid  [5];
        assign s6o_data     = so_data   [5];
        assign so_rdy   [5] = s6o_rdy;
    `endif  // SW_UNITS_6
    `ifdef  SW_UNITS_7
        assign si_valid [6] = s7i_valid;
        assign si_data  [6] = s7i_data;
        assign s7i_rdy      = si_rdy    [6];

        assign s7o_valid    = so_valid  [6];
        assign s7o_data     = so_data   [6];
        assign so_rdy   [6] = s7o_rdy;
    `endif  // SW_UNITS_7
    `ifdef  SW_UNITS_8
        assign si_valid [7] = s8i_valid;
        assign si_data  [7] = s8i_data;
        assign s8i_rdy      = si_rdy    [7];

        assign s8o_valid    = so_valid  [7];
        assign s8o_data     = so_data   [7];
        assign so_rdy   [7] = s8o_rdy;
    `endif  // SW_UNITS_8
    `ifdef  SW_UNITS_9
        assign si_valid [8] = s9i_valid;
        assign si_data  [8] = s9i_data;
        assign s9i_rdy      = si_rdy    [8];

        assign s9o_valid    = so_valid  [8];
        assign s9o_data     = so_data   [8];
        assign so_rdy   [8] = s9o_rdy;
    `endif  // SW_UNITS_9
    `ifdef  SW_UNITS_10
        assign si_valid [9] = s10i_valid;
        assign si_data  [9] = s10i_data;
        assign s10i_rdy     = si_rdy    [9];

        assign s10o_valid   = so_valid  [9];
        assign s10o_data    = so_data   [9];
        assign so_rdy   [9] = s10o_rdy;
    `endif  // SW_UNITS_10

    /////////////////////////
    // GENERATE SLOW CLOCK //
    /////////////////////////

    // Clocking primitive
    //------------------------------------
    // Instantiation of the MMCM primitive
    MMCME2_ADV #(
        .BANDWIDTH                      ("OPTIMIZED"),
        .CLKOUT4_CASCADE                ("FALSE"),
        .COMPENSATION                   ("ZHOLD"),
        .STARTUP_WAIT                   ("FALSE"),
        .DIVCLK_DIVIDE                  (1),
        .CLKFBOUT_MULT_F                (4.000),
        .CLKFBOUT_PHASE                 (0.000),
        .CLKFBOUT_USE_FINE_PS           ("FALSE"),
        .CLKOUT0_DIVIDE_F               (8.000),
        .CLKOUT0_PHASE                  (0.000),
        .CLKOUT0_DUTY_CYCLE             (0.500),
        .CLKOUT0_USE_FINE_PS            ("FALSE"),
        .CLKIN1_PERIOD                  (4.000),
        .REF_JITTER1                    (0.010)
    ) mmcm_adv_inst (
        // Output clocks
        .CLKFBOUT                       (clkfbout),
        .CLKOUT0                        (clkout0),
         // Input clock control
        .CLKFBIN                        (clkfbout_buf),
        .CLKIN1                         (clk),
        .CLKIN2                         (1'b0),
         // Tied to always select the primary input clock
        .CLKINSEL                       (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR                          (7'h0),
        .DCLK                           (1'b0),
        .DEN                            (1'b0),
        .DI                             (16'h0),
        .DWE                            (1'b0),
        // Ports for dynamic phase shift
        .PSCLK                          (1'b0),
        .PSEN                           (1'b0),
        .PSINCDEC                       (1'b0),
        // Other control and status signals
        .LOCKED                         (LOCKED),
        .PWRDWN                         (1'b0),
        .RST                            (rst)
    );

    // Output buffering
    //-----------------------------------
    BUFG clkf_buf (
        .O                              (clkfbout_buf),
        .I                              (clkfbout)
    );

    BUFG clkout1_buf (
        .O                              (clkSmWa),
        .I                              (clkout0)
    );

    // generate a synchronous reset based upon the locked signal coming from
    // the MMCM that generates the clkSmWa
    always @ (posedge clkSmWa) begin
        rstSmWa <= (rstSmWa << 1) | (rst || (LOCKED !== 1));
    end

    // delay the reset that gets driven to the SmithWaterman modules
    // this avoids some DRC errors w/ the FIFOs that we use to cross clock
    // domains
    always @ (posedge clk) begin
        rst_q   <= (rst_q << 1) | (rst || (LOCKED !== 1));
    end

    ///////////
    // LOGIC //
    ///////////

    genvar unit;
    generate for (unit=0; unit<NUM_SW_UNITS; unit=unit+1) begin: create_sw_units

        // module to extract only the required info that needs to get
        // sent to the SmWaWrapper, rest goes into FIFO
        // Note: this also converts the stream data to the internal stream
        // width
        SplitStream #(
            .NAME                       ({NAME,".SplitStream"}),
            .VERBOSE                    (VERBOSE),

            .STREAM_BASE_W              (STREAM_BASE_W),
            .INT_BASE_W                 (INT_BASE_W),

            .MAX_QUERY_LEN              (MAX_QUERY_LENGTH),
            .Q_POS_W                    (Q_POS_W),
            
            .MAX_TARGET_LEN             (MAX_TARGET_LENGTH),
            .T_POS_W                    (T_POS_W),
            
            .STREAM_W                   (STREAM_W),
            .INT_STREAM_W               (INT_STREAM_W),

            .NUM_EXTRA_TX               (3),

            .PICOBUS_ADDR               (PICOBUS_ADDR+((unit+1)*PICOBUS_ADDR_INCR))
        ) SplitStream (
            .clk                        (clk),
            .rst                        (rst),

            // data from the input stream
            .s1i_valid                  (si_valid       [unit]),
            .s1i_rdy                    (si_rdy         [unit]),
            .s1i_data                   (si_data        [unit]),

            // data to the SmWaWrapper modules
            .s1o_valid                  (si_valid_SmWa  [unit]),
            .s1o_rdy                    (si_rdy_SmWa    [unit]),
            .s1o_data                   (si_data_SmWa   [unit]),
            
            // data to the sideband
            .s2o_valid                  (si_valid_FIFO  [unit]),
            .s2o_rdy                    (si_rdy_FIFO    [unit]),
            .s2o_data                   (si_data_FIFO   [unit]),
            
            // PicoBus signals
            .PicoClk                    (PicoClk),
            .PicoRst                    (PicoRst),
            .PicoAddr                   (PicoAddr),
            .PicoDataIn                 (PicoDataIn),
            .PicoRd                     (PicoRd),
            .PicoWr                     (PicoWr),
            .PicoDataOut                (PicoDataOutSub1[unit])
        );

        // FIFO to hold data that does not get sent to the SmWaWrapper
        // Note: we want this FIFO to be able to hold the data for at least
        // 4 calls to this alignment function
        assign  si_rdy_FIFO     [unit]  = ~si_full_FIFO [unit];
        assign  so_valid_FIFO   [unit]  = ~so_empty_FIFO[unit];
        PicoSyncFifo #(
            .NAME                       ({NAME,".sidebandFifo"}),
            .WIDTH                      (STREAM_W),
            .DEPTH                      (1 << clogb2((1 + (MAX_QUERY_LENGTH/(STREAM_BASES_PER_TX) + 1) + 
                                          1 + (MAX_TARGET_LENGTH/(STREAM_BASES_PER_TX) + 1) +
                                          3) * 4))
        ) sideband_fifo (
            .clk                        (clk),
            .rst                        (rst),

            .wr_en                      (si_valid_FIFO  [unit]),
            .din                        (si_data_FIFO   [unit]),
            .full                       (si_full_FIFO   [unit]),

            .dout                       (so_data_FIFO   [unit]),
            .empty                      (so_empty_FIFO  [unit]),
            .rd_en                      (so_rdy_FIFO    [unit])
        );

        // create the smith-waterman modules
        SmWaWrapper #(
            .NAME                       ({NAME,".SmWaWrapper"}),
            .VERBOSE                    (VERBOSE),

            .BASE_W                     (INT_BASE_W),
            .MAX_TARGET_LEN             (MAX_TARGET_LENGTH),
            .MAX_QUERY_LEN              (MAX_QUERY_LENGTH),
            
            .SCORE_W                    (SCORE_W),

            .T_POS_W                    (T_POS_W),
            .Q_POS_W                    (Q_POS_W),
            
            .STREAM_W                   (STREAM_W),

            .PICOBUS_ADDR               (PICOBUS_ADDR+((unit+1)*PICOBUS_ADDR_INCR)+32'h200)
        ) SmWaWrapper (
            // main stream clock
            .clk                        (clk),
            .rst                        (rst_q          [RST_PIPE_STAGES-1]),

            // slower systolic array clock
            .clkSmWa                    (clkSmWa),
            .rstSmWa                    (rstSmWa        [RST_PIPE_STAGES-1]),
            
            // input query/target stream
            .s1i_valid                  (si_valid_SmWa  [unit]),
            .s1i_rdy                    (si_rdy_SmWa    [unit]),
            .s1i_data                   (si_data_SmWa   [unit]),
            
            // output score stream
            .s1o_valid                  (so_valid_SmWa  [unit]),
            .s1o_rdy                    (so_rdy_SmWa    [unit]),
            .s1o_data                   (so_data_SmWa   [unit]),
    
            // PicoBus signals
            .PicoClk                    (PicoClk),
            .PicoRst                    (PicoRst),
            .PicoAddr                   (PicoAddr),
            .PicoDataIn                 (PicoDataIn),
            .PicoRd                     (PicoRd),
            .PicoWr                     (PicoWr),
            .PicoDataOut                (PicoDataOutSub0[unit])
        );

        // module to merge the results from the SmWaWrapper w/ the data stored
        // in the FIFO
        MergeStream #(
            .NAME                       ({NAME,".MergeStream"}),
            .VERBOSE                    (VERBOSE),

            .STREAM_BASE_W              (STREAM_BASE_W),

            .MAX_QUERY_LEN              (MAX_QUERY_LENGTH),
            .Q_POS_W                    (Q_POS_W),
            
            .MAX_TARGET_LEN             (MAX_TARGET_LENGTH),
            .T_POS_W                    (T_POS_W),
            
            .STREAM_W                   (STREAM_W),
            
            .SCORE_W                    (SCORE_W),

            // the NUM_EXTRA_TX transfers are simply copied from the
            // sideband fifo to the output stream
            // last 3 transfers require this module to insert some data from
            // the SmWaWrapper
            .NUM_EXTRA_TX               (0),

            .PICOBUS_ADDR               (PICOBUS_ADDR+((unit+1)*PICOBUS_ADDR_INCR)+32'h100)
        ) MergeStream (
            .clk                        (clk),
            .rst                        (rst),
            
            // data from the SmWaWrapper modules
            .s1i_valid                  (so_valid_SmWa  [unit]),
            .s1i_rdy                    (so_rdy_SmWa    [unit]),
            .s1i_data                   (so_data_SmWa   [unit]),

            // data from the sideband fifo
            .s2i_valid                  (so_valid_FIFO  [unit]),
            .s2i_rdy                    (so_rdy_FIFO    [unit]),
            .s2i_data                   (so_data_FIFO   [unit]),
            
            // data to the output stream
            .s1o_valid                  (so_valid       [unit]),
            .s1o_rdy                    (so_rdy         [unit]),
            .s1o_data                   (so_data        [unit]),

            // PicoBus signals
            .PicoClk                    (PicoClk),
            .PicoRst                    (PicoRst),
            .PicoAddr                   (PicoAddr),
            .PicoDataIn                 (PicoDataIn),
            .PicoRd                     (PicoRd),
            .PicoWr                     (PicoWr),
            .PicoDataOut                (PicoDataOutSub2[unit])
        );

    end endgenerate

    /////////////
    // PICOBUS //
    /////////////
    
    integer                             i;
    reg [31:0]                          PicoAddr_1;

    // set control registers via the PicoBus
    // read status information via the PicoBus
    always @ (posedge PicoClk) begin
        if (PicoRst) begin
            PicoDataOutLocal    <= 0;
        end else if (PicoWr) begin
            PicoDataOutLocal    <= 0;
            //case(PicoAddr)
                //(PICOBUS_ADDR+32'h10):  primary[0][31:0]<= PicoDataIn;
            //endcase
        end else if (PicoRd) begin
            PicoDataOutLocal    <= 0;
            case (PicoAddr)
                (PICOBUS_ADDR+32'h00):  PicoDataOutLocal<= version;
                (PICOBUS_ADDR+32'h10):  PicoDataOutLocal<= PICOBUS_ADDR_INCR;
                //(PICOBUS_ADDR+32'h30):  PicoDataOutLocal<= status;
                (PICOBUS_ADDR+32'h40):  PicoDataOutLocal<= MAX_QUERY_LENGTH;
                (PICOBUS_ADDR+32'h50):  PicoDataOutLocal<= Q_POS_W;
                (PICOBUS_ADDR+32'h60):  PicoDataOutLocal<= MAX_TARGET_LENGTH;
                (PICOBUS_ADDR+32'h70):  PicoDataOutLocal<= T_POS_W;
                (PICOBUS_ADDR+32'h80):  PicoDataOutLocal<= NUM_SW_UNITS;
                (PICOBUS_ADDR+32'h90):  PicoDataOutLocal<= SW_CLK_FREQ;
                (PICOBUS_ADDR+32'hA0):  PicoDataOutLocal<= SCORE_W;
                (PICOBUS_ADDR+32'hB0):  PicoDataOutLocal<= STREAM_W;
                (PICOBUS_ADDR+32'hC0):  PicoDataOutLocal<= INT_STREAM_W;
                (PICOBUS_ADDR+32'hD0):  PicoDataOutLocal<= STREAM_BASE_W;
                (PICOBUS_ADDR+32'hE0):  PicoDataOutLocal<= INT_BASE_W;
            endcase
        end else begin
            PicoDataOutLocal    <= 0;
        end
        PicoAddr_1              <= PicoAddr;
    end

    // assign the output PicoDataOut
    always @ (*) begin
        PicoDataOut     = PicoDataOutLocal;
        for (i=0; i<NUM_SW_UNITS; i=i+1) begin
            PicoDataOut = PicoDataOut | PicoDataOutSub0 [i] | PicoDataOutSub1 [i] | PicoDataOutSub2 [i];
        end
    end

    initial begin
        $monitor("PicoAddr = 0x%h, PicoDataOut = 0x%h", PicoAddr_1, PicoDataOut);
    end

endmodule
