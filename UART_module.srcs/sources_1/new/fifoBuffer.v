`timescale 1ns / 1ns

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
reg [B-1 : 0] array_reg [(2**W)-1 : 0];
reg [W-1 : 0] w_ptr_reg; 
reg [W-1 : 0] w_ptr_next; 
reg [W-1 : 0] w_ptr_succ;

reg [W-1 : 0] r_ptr_reg;
reg [W-1 : 0] r_ptr_next;
reg [W-1 : 0] r_ptr_succ;

reg full_reg;
reg empty_reg;
reg full_next;
reg empty_next;

wire writeEnable;

//Register file write operation
always @(posedge clk) begin
    if(writeEnable) begin
        array_reg[w_ptr_reg] <= w_data;
    end
end

//Register file read operation
assign r_data = array_reg[r_ptr_reg];

//Write enable only when FIFO is not full
assign writeEnable = wr & ~full_reg;

//Fifo control logic
//Register for read and write pointers
always @(posedge clk) begin
    if(reset) begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 0;
        empty_reg <= 1;
    end
    else begin
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

//Next-state logic for read and write pointers
always @(*) begin
    //Successive pointer values
    w_ptr_succ = w_ptr_reg + 1;
    r_ptr_succ = r_ptr_reg + 1; 
    //Default: keep old values
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;

    case ({wr, rd})
        //nop:
        readOp:
            if (~empty_reg) begin
                r_ptr_next = r_ptr_succ;
                full_next = 1'b0;
                if (r_ptr_succ==w_ptr_reg) begin
                    empty_next = 1'b1;
                end
            end
        writeOp:
            if (~full_reg) begin
                w_ptr_next = w_ptr_succ;
                empty_next = 1'b0;
                if (w_ptr_succ==r_ptr_reg) begin
                    full_next = 1'b1;
                end
            end
        readWriteOp:
            begin
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ; 
            end 
        default:
            begin
                w_ptr_next = w_ptr_next;
                r_ptr_next = r_ptr_next;
            end

    endcase
end

//Output
assign full = full_reg;
assign empty = empty_reg;

endmodule
