module fifoBuffer#
(
    parameter B = 8,
    parameter W = 4
)
(
    input wire clk,     
    input wire reset,
    input wire rd,            
    input wire wr,
    input wire [B-1 : 0] w_data,
    output wire empty,
    output wire full,
    output wire [B-1 : 0] r_data
);

localparam nop = 2'b00;
localparam readOp = 2'b01;
localparam writeOp = 2'b10;
localparam readWriteOp = 2'b11;


//Signal declaration
reg [B-1 : 0] arrayRegister [(2**W)-1 : 0];
reg [W-1 : 0] writePointerRegister; 
reg [W-1 : 0] writePointerNext; 
reg [W-1 : 0] writePointerSuccessive;

reg [W-1 : 0] readPointerRegister;
reg [W-1 : 0] readPointerNext;
reg [W-1 : 0] readPointerSuccessive;

reg fullRegister;
reg emptyRegister;
reg fullNext;
reg emptyNext;

wire writeEnable;

//Register file write operation
always @(posedge clk) begin
    if(writeEnable) begin
        arrayRegister[writePointerRegister] <= w_data;
    end
end

//Register file read operation
assign r_data = arrayRegister[readPointerRegister];

//Write enable only when FIFO is not full
assign writeEnable = wr & ~fullRegister;

//Fifo control logic
//Register for read and write pointers
always @(posedge clk) begin
    if(reset) begin
        writePointerRegister <= 0;
        readPointerRegister <= 0;
        fullRegister <= 0;
        emptyRegister <= 0;
    end
    else begin
        writePointerRegister <= writePointerNext;
        readPointerRegister <= readPointerNext;
        fullRegister <= fullNext;
        emptyRegister <= emptyNext;
    end
end

//Next-state logic for read and write pointers
always @(*) begin
    //Successive pointer values
    writePointerSuccessive = writePointerRegister + 1;
    readPointerSuccessive = readPointerRegister + 1; 
    //Default: keep old values
    writePointerNext = writePointerRegister;
    readPointerNext = readPointerRegister;
    fullNext = fullRegister;
    emptyNext = emptyRegister;

    case ({wr, rd})
        //nop:
        readOp:
            if (~emptyRegister) begin
                readPointerNext = readPointerSuccessive;
                fullNext = 1'b0;
                if (readPointerSuccessive==writePointerRegister) begin
                    emptyNext = 1'b1;
                end
            end
        writeOp:
            if (~fullRegister) begin
                writePointerNext = writePointerSuccessive;
                emptyNext = 1'b0;
                if (writePointerSuccessive==readPointerRegister) begin
                    fullNext = 1'b1;
                end
            end
        readWriteOp:
            begin
                writePointerNext = writePointerSuccessive;
                readPointerNext = readPointerSuccessive; 
            end 
        //default: ???? 

    endcase
end

//Output
assign full = fullRegister;
assign empty = emptyRegister;

endmodule
