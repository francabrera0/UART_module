`timescale 1ns / 1ns
module uartToptb();

    localparam DBIT = 8;
    localparam SB_TICK = 16;
    localparam DVSR = 27;
    localparam DVSR_BIT = 5;
    localparam FIFO_W = 2;

    reg clk;
    reg reset;
    reg rd_uart;
    reg wr_uart;
    wire rx;
    reg [DBIT-1 : 0] w_data;
    wire tx_full;
    wire rx_empty;
    wire tx;
    wire [DBIT-1 : 0] r_data;

    uart #
    (
        .DBIT(DBIT),
        .SB_TICK(SB_TICK),
        .DVSR(DVSR),
        .DVSR_BIT(DVSR_BIT),
        .FIFO_W(FIFO_W) 
    ) uartTop
    (
        .clk(clk),
        .reset(reset),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .w_data(w_data),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(r_data)
    );

    assign rx = tx;

    always begin
        #10 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        rd_uart = 0;
        wr_uart = 0;
        w_data = 8'b0;

        #1000 reset = 0;

        w_data = 0'hAA;
        wr_uart = 1;
        #20;
        wr_uart = 0;
        #100;
        w_data = 0'h55;
        wr_uart = 1;
        #20;
        wr_uart = 0; 
        #200000;
        rd_uart = 1;
        #20;
        rd_uart = 0;

    end

endmodule
