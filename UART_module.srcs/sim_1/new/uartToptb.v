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
    
    reg [31:0] seed;
    reg [DBIT-1:0] testData [3:0];
    reg [2:0] i;

    initial begin
        seed = 135;
        clk = 0;
        reset = 1;
        rd_uart = 0;
        wr_uart = 0;
        w_data = 8'b0;

        #1000 reset = 0;
        
        if(!rx_empty) begin
            $error("Rx FIFO not empty at start");
        end
        if(tx_full)begin
            $error("Rx FIFO full at start");
        end
        
        //Tx 4 bytes
        i = 8'b0;
        for(i = 0; i<4; i = i + 1)
        begin
            testData[i] = $random(seed);
            w_data = testData[i];
            wr_uart = 1;
            #20;
            wr_uart = 0;
            #20;
        end //End for
        
        #20
        
        if(!tx_full)begin
            $error("Tx FIFO not full after filling");
        end
        
        //Wait data transfer
        #600000
        
        if(rx_empty) begin
            $error("Rx FIFO empty after recieving data");
        end
        
        //Rx 4 bytes
        i = 8'b0;
        for(i = 0; i<4; i = i + 1)
        begin
            if(r_data != testData[i]) begin
                $error("Data rx different from tx, %d != %d", r_data, testData[i]); 
            end
            rd_uart = 1;
            #20;
            rd_uart = 0;
            #20;
        end //End for
        
        if(rx_empty != 1'b1) begin
            $error("Rx FIFO not empty at end");
        end
    end
endmodule