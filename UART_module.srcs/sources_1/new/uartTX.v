`timescale 1ns / 1ns

module uartTX#
(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)
(
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire s_tick,
    input wire [DBIT-1 : 0] din,
    output reg tx_done_tick,
    output wire tx
);

//symbolic state declaration
localparam [1:0] idle = 2'b00;
localparam [1:0] start = 2'b01;
localparam [1:0] data = 2'b10;
localparam [1:0] stop = 2'b11;

//signal declaration
reg [1:0] state_reg;
reg [1:0] state_next;
reg [3:0] s_reg;
reg [3:0] s_next;
reg [2:0] n_reg;
reg [2:0] n_next;
reg [DBIT-1:0] b_reg;
reg [DBIT-1:0] b_next;
reg tx_reg;
reg tx_next;

//Finite State Machine with Data (state and data registers)
always @(posedge clk) begin
    if(reset) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
        tx_reg <= 1'b1;
    end
    else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
        tx_reg <= tx_next;
    end
end

//Finite State Machine with Data (next state logic and functional units)
always @(*) begin
    state_next = state_reg;
    tx_done_tick = 1'b0;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    tx_next = tx_reg;

    case (state_reg)
        idle: begin
            tx_next = 1'b1;
            if(tx_start) begin
                state_next = start;
                s_next = 0;
                b_next = din;
            end
        end
        
        start: begin
            tx_next = 1'b0;
            if (s_tick) begin
                if (s_reg == 15) begin
                    state_next = data;
                    s_next = 0;
                    n_next = 0;
                end
                else begin
                    s_next = s_reg + 1;
                end
            end
        end

        data: begin
            tx_next = b_reg[0];
            if (s_tick) begin
                if(s_reg==15) begin
                    s_next = 0;
                    b_next = b_reg >> 1;
                    if (n_reg==(DBIT-1)) begin
                        state_next = stop;
                    end
                    else begin
                        n_next = n_reg + 1;
                    end
                end
                else begin
                    s_next = s_reg + 1;
                end
            end
        end

        stop: begin
            tx_next = 1'b1;
            if (s_tick) begin
                if (s_reg==(SB_TICK-1)) begin
                    state_next = idle;
                    tx_done_tick = 1'b1;
                end
                else begin
                    s_next = s_reg + 1;
                end
            end
        end
        default: begin
            state_next = idle;
        end
    endcase
end

assign tx = tx_reg;

endmodule
