// PicoBus128_HelloWorld.v
// Copyright 2011 Pico Computing Inc.
module comparator(A, B, Parity, Greater, Less, rst);
    input [4:0] A, B;
    input rst;
    output Parity, Greater, Less;
    reg Parity, Greater, Less;
    // enable asynchronous reset. Probably not necessary.
    always @(negedge rst or A or B) begin
        if(!rst) begin
            Parity = 0;
            Greater = 0;
            Less = 0;
        end else begin
            if(A == B)
                Parity  = 1;
            else if(A > B)
                Greater = 1;
            else Less   = 1;
        end
   end
endmodule 


module PicoBus128_HelloWorld(
    // These are the standard PicoBus signals that we'll use to communicate with the rest of the system.
    input               PicoClk,
    input               PicoRst,
    input  [31:0]       PicoAddr,
    input  [127:0]      PicoDataIn, 
    input               PicoRd, 
    input               PicoWr,
    output reg [127:0]   PicoDataOut
);

    // We will use the following Address table for the PicoAddress
    // TheReg0 @ PicoAddr == 32'h00
    // TheReg1 @ PicoAddr == 32'h10
    // TheReg2 @ PicoAddr == 32'h20
    // TheReg3 @ PicoAddr == 32'h30

    reg [127:0] TheReg0;     // This is a simple flip of the bits
    reg [127:0] TheReg1;     // This is an XOR with the value currently in it
    reg [127:0] TheReg2;     // This is adder starting at 0, and incrementing by each write
    
    reg [127:0] TheReg3;     // This is a counter which increments by 1 on each write 
                             // to the above registers, ignoring input data

    // User declarations of buses
    wire [4:0] query, resultToCompare;
    wire rst;
    wire equal, greater, less;
    comparator C1(query, resultToCompare, rst, greater, less);
    
    
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            // we'll start off with known reset values when the system asserts PicoRst at startup.
            TheReg0 <= 128'h0;
            TheReg1 <= {32'hdecafbad, 32'h12345678, 32'h87654321, 32'hdeadbeef};
            TheReg2 <= 128'h0;
            TheReg3 <= 128'h0;
        end else begin
            // Here we process writes to the FPGA.
            // The PicoBus will assert PicoWr on the same cycle that PicoAddr is valid and the data in on PicoDataIn.
            if ( PicoWr && PicoAddr[31:0] == 32'h00 )
                // simply invert the bits of the input data, and store it.
                TheReg0 <= ~PicoDataIn;
            if ( PicoWr && PicoAddr[31:0] == 32'h10 )
                // XOR the input data with our previous value.
                TheReg1 <= TheReg1 ^ PicoDataIn;
            if ( PicoWr && PicoAddr[31:0] == 32'h20 )
                // add the value written to our current value.
                TheReg2 <= TheReg2 + PicoDataIn;
            if ( PicoWr && ( PicoAddr[31:0] == 32'h00 || PicoAddr[31:0] == 32'h10 || PicoAddr[31:0] == 32'h20 || PicoAddr[31:0] == 32'h30) )
                // increment the value of TheReg3 by 1 each time a write is done to any of the registers we have.
                // note that this statement is processed in parallel with the statements that handle writes to each
                // of the specific registers.
                TheReg3 <= TheReg3 + 1;
        end

	// Adding user code modules here for ScanSubject
        
        // Here we answer read requests on the PicoBus.
        // We place the requested data on PicoDataOut on the next cycle after PicoRd and PicoAddr are valid.
        if (PicoRd && (PicoAddr[31:0] == 32'h00) )
            PicoDataOut <= TheReg0;
        else if (PicoRd && (PicoAddr[31:0] == 32'h10) )
            PicoDataOut <= TheReg1;
        else if (PicoRd && (PicoAddr[31:0] == 32'h20) )
            PicoDataOut <= TheReg2;
        else if (PicoRd && (PicoAddr[31:0] == 32'h30) )
            PicoDataOut <= TheReg3;
        else
            // since the PicoBus is shared, we need to drive our output to 0 when we're not being read from.
            PicoDataOut <= 128'h0;
    end
endmodule