module aluUartInterface#
(
    parameter DATA_LEN = 8,
    parameter OP_LEN = 6     
)
(
    input wire i_clk,
    input wire i_reset,
    input wire [DATA_LEN-1:0] i_aluResult,
    input wire [DATA_LEN-1:0] i_dataToRead,
    input wire i_fifoRxEmpty,
    input wire i_fifoTxFull,
    input wire i_aluOverflow,
    input wire i_aluZero,

    output wire o_fifoRxRead,
    output wire o_fifoTxWrite,
    output wire [DATA_LEN-1:0] o_dataToWrite,
    output wire [OP_LEN-1:0] o_aluOpSelector,
    output wire [DATA_LEN-1:0] o_aluOperandA,
    output wire [DATA_LEN-1:0] o_aluOperandB,
    output wire o_validFlag
);

localparam [3:0] IDLE = 4'b0000;
localparam [3:0] OPSELECTOR = 4'b0001;
localparam [3:0] OPERANDA = 4'b0010;
localparam [3:0] OPERANDB = 4'b0011;
localparam [3:0] CRC = 4'b0100;
localparam [3:0] CRCCHECK= 4'b0101;
localparam [3:0] RESULT = 4'b0110;
localparam [3:0] CRCRESULT = 4'b0111;
localparam [3:0] WAIT = 4'b1000;


reg [3:0] stateReg, stateNext;
reg fifoRxReadReg, fifoRxReadNext;
reg fifoTxWriteReg, fifoTxWriteNext;

reg [OP_LEN-1:0] opSelectorReg, opSelectorNext;
reg [DATA_LEN-1:0] operandAReg, operandANext;
reg [DATA_LEN-1:0] operandBReg, operandBNext;
reg [DATA_LEN-1:0] resultReg, resultNext;
reg [DATA_LEN-1:0] crcReg, crcNext;
reg [3:0] waitReg, waitNext;

wire [DATA_LEN-1:0] crc;


always @(posedge i_clk) begin
    if(i_reset) begin
        stateReg <= IDLE;
        fifoRxReadReg <= 1'b0;
        fifoTxWriteReg <= 1'b0;
        opSelectorReg <= {OP_LEN{1'b0}};
        operandAReg <= {DATA_LEN{1'b0}};
        operandBReg <= {DATA_LEN{1'b0}};
        resultReg <= {DATA_LEN{1'b0}};
        crcReg <= {DATA_LEN{1'b0}};
        waitReg <= 4'b0000;
    end
    else begin
        stateReg <= stateNext;
        fifoRxReadReg <= fifoRxReadNext;
        fifoTxWriteReg <= fifoTxWriteNext;
        opSelectorReg <= opSelectorNext;
        operandAReg <= operandANext;
        operandBReg <= operandBNext;
        resultReg <= resultNext;
        crcReg <= crcNext;
        waitReg <= waitNext;
    end
end

always @(*) begin
    stateNext = stateReg;
    fifoRxReadNext = fifoRxReadReg;
    fifoTxWriteNext = fifoTxWriteReg;
    opSelectorNext = opSelectorReg;
    operandANext = operandAReg;
    operandBNext = operandBReg;
    resultNext = resultReg;
    crcNext = crcReg;
    waitNext = waitReg;

    case (stateReg)
        IDLE: begin
            fifoTxWriteNext = 1'b0;    
            if(~i_fifoRxEmpty) begin
                stateNext = OPSELECTOR;
                fifoRxReadNext = 1'b1;
            end
        end
        
        WAIT: begin
            if(~i_fifoRxEmpty) begin
                stateNext = waitReg;
                fifoRxReadNext = 1'b1;
            end
        end
        
        OPSELECTOR: begin
            if(i_fifoRxEmpty) begin
                fifoRxReadNext = 1'b0;
                stateNext = WAIT;
                waitNext = OPSELECTOR;
            end
            else begin
                stateNext = OPERANDA;
                opSelectorNext = i_dataToRead[OP_LEN-1:0];
                fifoRxReadNext = 1'b1;
            end
        end 

        OPERANDA: begin
            if(i_fifoRxEmpty) begin
                fifoRxReadNext = 1'b0;
                stateNext = WAIT;
                waitNext = OPERANDA;
            end
            else begin
                stateNext = OPERANDB;
                operandANext = i_dataToRead;
                fifoRxReadNext = 1'b1;
            end
        end

        OPERANDB: begin
            if(i_fifoRxEmpty) begin
                fifoRxReadNext = 1'b0;
                stateNext = WAIT;
                waitNext = OPERANDB;
            end
            else begin
                stateNext = CRC;
                operandBNext = i_dataToRead;
                fifoRxReadNext = 1'b1;
            end
        end

        CRC: begin
            if(i_fifoRxEmpty) begin
                fifoRxReadNext = 1'b0;
                stateNext = WAIT;
                waitNext = CRC;
            end
            else begin
                stateNext = CRCCHECK;
                crcNext = i_dataToRead;
                fifoRxReadNext = 1'b0;
            end
        end

        CRCCHECK: begin
            fifoRxReadNext = 1'b0;
            if(o_validFlag) begin
                stateNext = RESULT;
            end
            else begin
                stateNext = IDLE;
            end
        end

        RESULT: begin
            if(~i_fifoTxFull) begin
                stateNext = CRCRESULT;
                resultNext = i_aluResult;
                fifoTxWriteNext = 1'b1;
            end
        end

        CRCRESULT: begin
            if(~i_fifoTxFull) begin
                stateNext = IDLE;
                resultNext = resultReg ^ 8'hff;
                fifoTxWriteNext = 1'b1;
            end
        end

        default: begin
            stateNext = IDLE;
            fifoRxReadNext = 1'b0;
            fifoTxWriteNext = 1'b0;
        end

    endcase
end


assign crc = opSelectorReg ^ operandAReg ^ operandBReg ^ 8'hff;
assign o_validFlag = (crc == crcReg) ? 1 : 0;
assign o_aluOperandA = operandAReg;
assign o_aluOperandB = operandBReg;
assign o_aluOpSelector = opSelectorReg;
assign o_dataToWrite = resultReg;
assign o_fifoTxWrite = fifoTxWriteReg;
assign o_fifoRxRead = fifoRxReadReg;


endmodule
