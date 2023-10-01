module uartRx#
(
    parameter DBIT = 8,
    parameter SB_TICK = 16
)
(
    input wire clk,
    input wire reset,
    input wire rx,
    input wire s_tick,
    output reg rx_done_tick,
    output wire [DBIT-1:0] dout 
);


//Symbolic state declaration
localparam [1:0] idle  = 2'b00;
localparam [1:0] start = 2'b01;
localparam [1:0] data  = 2'b10;
localparam [1:0] stop  = 2'b11;

//Signal declaration
reg [1:0] state_reg;  //Actual state
reg [1:0] state_next; //Next state

reg [3:0] s_reg;      //Register to count the number of ticks
reg [3:0] s_next;

reg [2:0] n_reg;     //Register to count the number of received bits
reg [2:0] n_next;

reg [DBIT-1:0] b_reg;     //Register to save te received frame
reg [DBIT-1:0] b_next;

//Finite State Machine with data (state and data registers)
always @(posedge clk) begin
    if (reset) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
    end
    else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end
end

//Finite State Machine with data (next state logic)
always @(*) begin
    state_next = state_reg;
    rx_done_tick = 1'b0;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;

    case (state_reg)
        idle:
            if (~rx) begin
               state_next = start;
               s_next = 0; 
            end
        
        start:
            if (s_tick) begin
                if (s_reg == 7) begin
                    state_next = data;
                    s_next = 0;
                    n_next = 0;
                end
                else begin
                    s_next = s_reg + 1;
                end
                
            end

        data:
            if (s_tick) begin
                if (s_reg == 15) begin
                    s_next = 0;
                    b_next = {rx, b_reg[DBIT-1:1]};
                    if (n_reg == (DBIT-1)) begin
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
        
        stop:
            if (s_tick) begin
                if (s_reg == (SB_TICK-1)) begin
                    state_next = idle;
                    if(rx) begin
                        rx_done_tick = 1'b1;
                    end
                end 
                else begin
                    s_next = s_reg + 1;
                end
            end

        default: 
            state_next = idle;   
    endcase
end

assign dout = b_reg;

endmodule