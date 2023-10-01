module uart#
(
    parameter DBIT = 8,
    parameter SB_TICK = 16,
    parameter DVSR = 163,
    parameter DVSR_BIT = 8,
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
    .o_maxTick(tick)
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
    .DBIT(DBIT),
    .ADDRESS(FIFO_W)
) fifoBufferRXUnit
(
    .clk(clk),
    .reset(reset),
    .rd(rd_uart),
    .wr(rx_done_tick),
    .w_data(rx_data_out),
    .empty(rx_empty),
    .full(),
    .r_data(tx_fifo_out)
);


assign tx_fifo_not_empty = ~tx_empty;

endmodule
