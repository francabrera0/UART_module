`timescale 1ns / 1ps

module modMCountertb();

    localparam COUNTER_BITS = 4;
    localparam COUNTER_MOD = 10;

    reg clk;
    reg reset;
    wire maxTick;

    modMCounter #
    (
        .COUNTER_BITS(COUNTER_BITS),
        .COUNTER_MOD(COUNTER_MOD)
    )baudRateGen
    (
        .i_clk(clk),
        .i_reset(reset),
        .o_counterMaxTick(maxTick)
    );

    always begin
        #10 clk = ~clk; // clk 50[MHz]
    end

    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        #500;
    end



endmodule
