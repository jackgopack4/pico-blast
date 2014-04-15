/*
* File Name     : PicoSmithWatermanDefines.v
*
* Author        : Corey Olson
*
* Description   : This include file is just meant to read the PicoDefines.v
*                 file and set some defines based upon that. 
*
* Copyright     : 2013, Pico Computing, Inc.
*/

// pull in the defintions from our PicoDefines.v file
`include "PicoDefines.v"

// handle the SW_UNITS_X definition here
// Note: if SW_UNITS_3 is defined, then we should also define SW_UNITS_1 and
// SW_UNITS_2 as well
// TODO: automatically set the streams widths in PicoDefines.v
`ifdef  SW_UNITS_10
    `define SW_UNITS_9
    `define SW_UNITS_8
    `define SW_UNITS_7
    `define SW_UNITS_6
    `define SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    10
`elsif  SW_UNITS_9
    `define SW_UNITS_8
    `define SW_UNITS_7
    `define SW_UNITS_6
    `define SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    9
`elsif  SW_UNITS_8
    `define SW_UNITS_7
    `define SW_UNITS_6
    `define SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    8
`elsif  SW_UNITS_7
    `define SW_UNITS_6
    `define SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    7
`elsif  SW_UNITS_6
    `define SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    6
`elsif  SW_UNITS_5
    `define SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    5
`elsif  SW_UNITS_4
    `define SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    4
`elsif  SW_UNITS_3
    `define SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    3
`elsif  SW_UNITS_2
    `define SW_UNITS_1
    `define NUM_SW_UNITS    2
`else 
    `define SW_UNITS_1
    `define NUM_SW_UNITS    1
`endif  // SW_UNITS_10

// if ASCII_INPUT_DATA is defined, then the stream width must be exactly
// 8 bits per base, so we override that define here
`ifdef ASCII_INPUT_DATA
    `define STREAM_BASE_WIDTH   8
`endif
