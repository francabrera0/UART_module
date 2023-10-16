`timescale 1ns / 1ns

module topLevelTb();

localparam DATA_LEN = 8;
localparam SB_TICK = 16;
localparam COUNTER_MOD = 326;
localparam COUNTER_BITS = 9;
localparam PTR_LEN = 4;
localparam OP_LEN = 6;  

reg clk;
reg reset;

wire pcRx;
wire pcTx;

reg readPcUart;
reg writePcUart;
reg [DATA_LEN-1:0] pcDataToWrite;
wire [DATA_LEN-1:0] pcDataToRead;

topLevel#
(
    .DATA_LEN(DATA_LEN),
    .SB_TICK(SB_TICK),
    .COUNTER_MOD(COUNTER_MOD),
    .COUNTER_BITS(COUNTER_BITS),
    .PTR_LEN(PTR_LEN),
    .OP_LEN(OP_LEN)     
) topLevelUnit
( 
    .i_clk(clk),
    .i_reset(reset),
    .i_uartRx(pcTx),
    .o_uartTx(pcRx)
);

uart#
(
    .DATA_LEN(DATA_LEN),
    .SB_TICK(SB_TICK),
    .COUNTER_MOD(COUNTER_MOD),
    .COUNTER_BITS(COUNTER_BITS),
    .PTR_LEN(PTR_LEN)        
) uartPcUnit
(
    .i_clk(clk),
    .i_reset(reset),
    .i_readUart(readPcUart),
    .i_writeUart(writePcUart),
    .i_uartRx(pcRx),
    .i_dataToWrite(pcDataToWrite),
    .o_txFull(),
    .o_rxEmpty(),
    .o_uartTx(pcTx),
    .o_dataToRead(pcDataToRead)
);

always begin
    #5 clk = ~clk; 
end

initial begin
    reset = 1'b1;
    clk = 1'b0;
    readPcUart = 1'b0;
    writePcUart = 1'b0;
    pcDataToWrite = 8'b0;

    #10 reset = 1'b0;

    pcDataToWrite = 8'h20;
    writePcUart = 1'b1;
    #10;
    pcDataToWrite = 8'h05;
    #10;
    pcDataToWrite = 8'h0a;
    #10;
    pcDataToWrite = 8'hd0;
    #10;
    pcDataToWrite = 8'h20;
    #10;
    pcDataToWrite = 8'h06;
    #10;
    pcDataToWrite = 8'h0a;
    #10;
    pcDataToWrite = 8'hd3;
    #10;
    writePcUart = 1'b0;
    
    #3100000;
    readPcUart = 1'b1;
    #10;
    readPcUart = 1'b0;
    
    #3100000;
    readPcUart = 1'b1;
    #10;
    readPcUart = 1'b0;
    #1000000;
    readPcUart = 1'b1;
    #10;
    readPcUart = 1'b0;


end

endmodule
