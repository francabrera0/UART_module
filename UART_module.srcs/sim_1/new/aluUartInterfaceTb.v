`timescale 1ns / 1ns

module aluUartInterfaceTb();

localparam DATA_LEN = 8;
localparam OP_LEN = 6;
localparam PTR_LEN = 2;

reg clk;
reg reset;
reg [DATA_LEN-1:0] aluResult;

wire fifoRxReadOut;
wire fifoTxWriteOut;
wire [DATA_LEN-1:0] dataToWriteOut;
wire [OP_LEN-1:0] aluOpSelector;
wire [DATA_LEN-1:0] operandA;
wire [DATA_LEN-1:0] operandB;

reg fifoRxWriteIn; //used to store data in fifo
reg [DATA_LEN-1:0] fifoRxDataWriteIn;

wire fifoRxEmptyOut;
wire [DATA_LEN-1:0] fifoRxDataToReadOut;

reg fifoTxReadIn; //Used to see result

wire fifoTxFullOut;
wire [DATA_LEN-1:0] fifoTxDataToReadOut;



aluUartInterface#
(
    .DATA_LEN(DATA_LEN),
    .OP_LEN(OP_LEN)     
) interfaceUnit
(
    .i_clk(clk),
    .i_reset(reset),
    .i_aluResult(aluResult),
    .i_dataToRead(fifoRxDataToReadOut),
    .i_fifoRxEmpty(fifoRxEmptyOut),
    .i_fifoTxFull(fifoTxFullOut),
    .i_aluOverflow(),
    .i_aluZero(),
    .i_txDone(),
    .i_rxDone(),

    .o_fifoRxRead(fifoRxReadOut),
    .o_fifoTxWrite(fifoTxWriteOut),
    .o_dataToWrite(dataToWriteOut),
    .o_aluOpSelector(aluOpSelector),
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
    .i_fifoRead(fifoRxReadOut),            
    .i_fifoWrite(fifoRxWriteIn),
    .i_dataToWrite(fifoRxDataWriteIn),
    .o_fifoEmpty(fifoRxEmptyOut),
    .o_fifoFull(),
    .o_dataToRead(fifoRxDataToReadOut)
);


fifoBuffer#
(
    .DATA_LEN(DATA_LEN),
    .PTR_LEN(PTR_LEN)
) fifoTx
(
    .i_clk(clk),     
    .i_reset(reset),
    .i_fifoRead(fifoTxReadIn),            
    .i_fifoWrite(fifoTxWriteOut),
    .i_dataToWrite(dataToWriteOut),
    .o_fifoEmpty(),
    .o_fifoFull(fifoTxFullOut),
    .o_dataToRead(fifoTxDataToReadOut)
);


always begin
    #5 clk = ~clk; 
end

initial begin
    clk = 0;
    reset = 1;
    aluResult = 8'h03;
    fifoRxWriteIn = 0; //used to store data in fifo
    fifoRxDataWriteIn = 0;
    fifoTxReadIn = 0; //Used to see result

    #10 reset = 0;
    fifoRxDataWriteIn = 8'h20;
    fifoRxWriteIn = 1'b1;
    #10;
    fifoRxWriteIn = 1'b0;
    fifoRxDataWriteIn = 8'h01;
    fifoRxWriteIn = 1'b1;
    #10;
    fifoRxWriteIn = 1'b0;
    fifoRxDataWriteIn = 8'h02;
    fifoRxWriteIn = 1'b1;
    #10;
    fifoRxWriteIn = 1'b0;


end


endmodule
