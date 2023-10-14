`timescale 1ns / 1ps

module fifoBuffertb();

    localparam DATA_LEN = 8;
    localparam PTR_LEN = 2;

    reg clk;     
    reg reset;
    reg fifoRead;            
    reg fifoWrite;
    reg [DATA_LEN-1 : 0] dataToWrite;
    wire fifoEmpty;
    wire fifoFull;
    wire [DATA_LEN-1 : 0] dataToRead;

    reg [DATA_LEN-1 : 0] dataA = 8'hAA;
    reg [DATA_LEN-1 : 0] dataB = 8'h55;
    reg [DATA_LEN-1 : 0] dataC = 8'hff;
    reg [DATA_LEN-1 : 0] dataD = 8'h22;

    fifoBuffer #
    (
        .DATA_LEN(DATA_LEN),
        .PTR_LEN(PTR_LEN)
    )fifoBufferUnit
    ( 
        .i_clk(clk),
        .i_reset(reset),
        .i_fifoRead(fifoRead),
        .i_fifoWrite(fifoWrite),
        .i_dataToWrite(dataToWrite),
        .o_fifoEmpty(fifoEmpty),
        .o_fifoFull(fifoFull),
        .o_dataToRead(dataToRead)
    );

    always begin
        #10 clk = ~clk; 
    end

    initial begin
        clk = 0;
        fifoWrite = 0;
        fifoRead = 0;
        reset = 1;
        #20
        reset = 0;

        dataToWrite = dataA;
        fifoWrite = 1;
        #20;
        fifoWrite = 0;
        dataToWrite = dataB;
        fifoWrite = 1;
        #20;
        fifoWrite = 0;
        dataToWrite = dataC;
        fifoWrite = 1;
        #20;
        fifoWrite = 0;
        dataToWrite = dataD;
        fifoWrite = 1;
        #20;
        fifoWrite = 0;
        #20;
        fifoRead = 1;
        #20;
        fifoRead = 0;
        #20;
        fifoRead = 1;
        #20;
        fifoRead = 0;
        #20;
        fifoRead = 1;
        #20;
        fifoRead = 0;

    end

endmodule
