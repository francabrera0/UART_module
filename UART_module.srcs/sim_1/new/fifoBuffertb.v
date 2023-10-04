`timescale 1ns / 1ps

module fifoBuffertb();

    localparam B = 8;
    localparam W = 2;

    reg clk;     
    reg reset;
    reg rd;            
    reg wr;
    reg [B-1 : 0] w_data;
    wire empty;
    wire full;
    wire [B-1 : 0] r_data;

    reg [B-1 : 0] dataA = 0'hAA;
    reg [B-1 : 0] dataB = 0'h55;
    reg [B-1 : 0] dataC = 0'hff;
    reg [B-1 : 0] dataD = 0'h22;

    fifoBuffer #
    (
        .B(B),
        .W(W)
    )fifoBufferUnit
    ( 
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .w_data(w_data),
        .empty(empty),
        .full(full),
        .r_data(r_data)
    );

    always begin
        #10 clk = ~clk; 
    end

    initial begin
        clk = 0;
        wr = 0;
        rd = 0;
        reset = 1;
        #20
        reset = 0;

        w_data = dataA;
        wr = 1;
        #20;
        wr = 0;
        w_data = dataB;
        wr = 1;
        #20;
        wr = 0;
        w_data = dataC;
        wr = 1;
        #20;
        wr = 0;
        w_data = dataD;
        wr = 1;
        #20;
        wr = 0;
        #20;
        rd = 1;
        #20;
        rd = 0;
        #20;
        rd = 1;
        #20;
        rd = 0;

    end

endmodule
