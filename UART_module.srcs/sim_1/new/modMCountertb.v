`timescale 1ns / 1ps

module modMCountertb();

    localparam N = 4;
    localparam M = 10;

    reg clk;
    reg reset;
    wire max_tick;
    wire [N-1 : 0] q;

    modMCounter #
    (
        .N(N),
        .M(M)
    )baudRateGen
    (
        .clk(clk),
        .reset(reset),
        .max_tick(max_tick),
        .q(q)
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
