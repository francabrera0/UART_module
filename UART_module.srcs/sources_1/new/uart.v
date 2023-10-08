`timescale 1ns / 1ns

module uart#
(
    parameter DBIT = 8,
    parameter SB_TICK = 16,
    parameter DVSR = 27,
    parameter DVSR_BIT = 5,
    parameter FIFO_W = 2
)
(
    input wire clk,
    input wire reset,
    input wire rd_uart,
    input wire wr_uart,
    input wire rx,
    input wire [DBIT-1 : 0] w_data,
    output wire tx_full,
    output wire rx_empty,
    output wire tx,
    output wire [DBIT-1 : 0] r_data
);

//Signal declaration
wire tick;
wire rx_done_tick;
wire tx_done_tick;
wire tx_empty;
wire tx_fifo_not_empty;
wire [DBIT-1 : 0] tx_fifo_out;
wire [DBIT-1 : 0] rx_data_out;

//body
modMCounter #
(
    .M(DVSR),
    .N(DVSR_BIT)
) baudRateGeneratorUnit
(
    .clk(clk),
    .reset(reset),
    .q(),
    .max_tick(tick)
);

uartRX #
(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) uartRxUnit
(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(tick),
    .rx_done_tick(rx_done_tick),
    .dout(rx_data_out)
);

fifoBuffer #
(
    .B(DBIT),
    .W(FIFO_W)
) fifoBufferRXUnit
(
    .clk(clk),
    .reset(reset),
    .rd(rd_uart),
    .wr(rx_done_tick),
    .w_data(rx_data_out),
    .empty(rx_empty),
    .full(),
    .r_data(r_data)
);

fifoBuffer #
(
    .B(DBIT),
    .W(FIFO_W)
) fifoBufferTXUnit
(
    .clk(clk),
    .reset(reset),
    .rd(tx_done_tick),
    .wr(wr_uart),
    .w_data(w_data),
    .empty(tx_empty),
    .full(tx_full),
    .r_data(tx_fifo_out)
);

uartTX #
(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) uartTxUnit
(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_fifo_not_empty),
    .s_tick(tick),
    .din(tx_fifo_out),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
);

assign tx_fifo_not_empty = ~tx_empty;

endmodule
