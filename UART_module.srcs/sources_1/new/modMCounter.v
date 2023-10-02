module modMCounter#
(
    parameter N = 4, //Number of bits in counter
    parameter M = 10 //Mod-M
)
(
    input wire clk,
    input wire reset,
    output wire max_tick,
    output wire [N-1 : 0] q
);

//Signal declaration
reg [N-1 : 0] rReg;
wire [N-1 : 0] rNext;

//Body
//Register
always @(posedge clk) begin
    if (reset) begin
        rReg <= 0;
    end
    else begin
        rReg <= rNext;
    end
end

//Next-state logic
assign rNext = (rReg == (M-1)) ? 0 : rReg + 1;

assign q = rReg;
assign max_tick = (rReg == (M-1)) ? 1'b1 : 1'b0;

endmodule
