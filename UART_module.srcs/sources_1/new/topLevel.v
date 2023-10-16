module topLevel#
(
    parameter DATA_LEN = 8,
    parameter SB_TICK = 16,
    parameter COUNTER_MOD = 326,
    parameter COUNTER_BITS = 9,
    parameter PTR_LEN = 2,
    parameter OP_LEN = 6     
)
( 
    input wire i_clk,
    input wire i_reset,
    input wire i_uartRx,
    output wire o_uartTx
);

wire txFull;
wire rxEmpty;
wire [DATA_LEN-1:0] dataToRead;

wire rxRead;
wire txWrite;
wire [DATA_LEN-1:0] dataToWrite;
wire [OP_LEN-1:0] aluOpSelector;
wire [DATA_LEN-1:0] aluOperandA;
wire [DATA_LEN-1:0] aluOperandB;

wire rxDone;
wire [DATA_LEN-1:0] aluResult;
wire zero;
wire overFlow;

uart#
(
    .DATA_LEN(DATA_LEN),
    .SB_TICK(SB_TICK),
    .COUNTER_MOD(COUNTER_MOD),
    .COUNTER_BITS(COUNTER_BITS),
    .PTR_LEN(PTR_LEN)        
) uartUnit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_readUart(rxRead),
    .i_writeUart(txWrite),
    .i_uartRx(i_uartRx),
    .i_dataToWrite(dataToWrite),

    .o_txFull(txFull),
    .o_rxEmpty(rxEmpty),
    .o_uartTx(o_uartTx),
    .o_dataToRead(dataToRead),
    .o_rxDone(rxDone)
);

aluUartInterface#
(
    .DATA_LEN(DATA_LEN),
    .OP_LEN(OP_LEN)     
) interfaceUnit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_aluResult(aluResult),
    .i_dataToRead(dataToRead),
    .i_fifoRxEmpty(rxEmpty),
    .i_fifoTxFull(txFull),
    .i_aluOverflow(overFlow),
    .i_aluZero(zero),
    .i_rxDone(rxDone),

    .o_fifoRxRead(rxRead),
    .o_fifoTxWrite(txWrite),
    .o_dataToWrite(dataToWrite),
    .o_aluOpSelector(aluOpSelector),
    .o_aluOperandA(aluOperandA),
    .o_aluOperandB(aluOperandB),
    .o_validFlag()
);

alu#
(
    .DATA_LEN(DATA_LEN),
    .OP_LEN(OP_LEN)
) aluUnit
( 
    .i_operandA(aluOperandA),
    .i_operandB(aluOperandB),
    .i_opSelector(aluOpSelector),
    .o_aluResult(aluResult),
    .o_zero(zero),
    .o_overFlow(overFlow)
); 

endmodule
