`timescale 1ns / 1ns

module aluUartInterfaceTb();

localparam DATA_LEN = 8;
localparam OP_LEN = 6;
localparam PTR_LEN = 2;

reg clk;
reg reset;
reg [DATA_LEN-1:0] aluResult;

wire fifoRxRead;
wire fifoTxWrite;
wire [DATA_LEN-1:0] dataToWrite;
wire [OP_LEN-1:0] opSelector;
wire [DATA_LEN-1:0] operandA;
wire [DATA_LEN-1:0] operandB;

reg fifoRxWrite; //used to store data in fifo
reg [DATA_LEN-1:0] fifoRxDataToWrite;

wire fifoRxEmpty;
wire [DATA_LEN-1:0] fifoRxDataToRead;

reg fifoTxRead; //Used to see result

wire fifoTxFull;
wire [DATA_LEN-1:0] fifoTxDataToRead;



aluUartInterface#
(
    .DATA_LEN(DATA_LEN),
    .OP_LEN(OP_LEN)     
) interfaceUnit
(
    .i_clk(clk),
    .i_reset(reset),
    .i_aluResult(aluResult),
    .i_dataToRead(fifoRxDataToRead),
    .i_fifoRxEmpty(fifoRxEmpty),
    .i_fifoTxFull(fifoTxFull),
    .i_aluOverflow(),
    .i_aluZero(),
    .i_txDone(),
    .i_rxDone(),

    .o_fifoRxRead(fifoRxRead),
    .o_fifoTxWrite(fifoTxWrite),
    .o_dataToWrite(dataToWrite),
    .o_aluOpSelector(opSelector),
    .o_aluOperandA(operandA),
    .o_aluOperandB(operandB)
);

fifoBuffer#
(
    .DATA_LEN(DATA_LEN),
    .PTR_LEN(PTR_LEN)
) fifoRx
(
    .i_clk(clk),     
    .i_reset(reset),
    .i_fifoRead(fifoRxRead),            
    .i_fifoWrite(fifoRxWrite),
    .i_dataToWrite(fifoRxDataToWrite),
    .o_fifoEmpty(fifoRxEmpty),
    .o_fifoFull(),
    .o_dataToRead(fifoRxDataToRead)
);


fifoBuffer#
(
    .DATA_LEN(DATA_LEN),
    .PTR_LEN(PTR_LEN)
) fifoTx
(
    .i_clk(clk),     
    .i_reset(reset),
    .i_fifoRead(fifoTxRead),            
    .i_fifoWrite(fifoTxWrite),
    .i_dataToWrite(dataToWrite),
    .o_fifoEmpty(),
    .o_fifoFull(fifoTxFull),
    .o_dataToRead(fifoTxDataToRead)
);


always begin
    #5 clk = ~clk; 
end

initial begin
    clk = 0;
    reset = 1;
    aluResult = 8'h03;
    fifoRxWrite = 0; //used to store data in fifo
    fifoRxDataToWrite = 0;
    fifoTxRead = 0; //Used to see result

    #10 reset = 0;
    fifoRxDataToWrite = 8'h20;
    fifoRxWrite = 1'b1;
    #10;
    fifoRxWrite = 1'b0;
    fifoRxDataToWrite = 8'h01;
    fifoRxWrite = 1'b1;
    #10;
    fifoRxWrite = 1'b0;
    fifoRxDataToWrite = 8'h02;
    fifoRxWrite = 1'b1;
    #10;
    fifoRxWrite = 1'b0;


end


endmodule
