`timescale 1ns / 1ps

module Transmitter(
    input transmit,
    input [7:0] datain,
    input en, 
    input clk,
    input reset,
    output reg tx_data
    );

    // FSM Based Modeling with 2 states: Idle State and Transmitting State
    reg [9:0] tx_reg;             // 10-bit width to include start and stop bits
    reg sft_tx_reg;               // Shift control signal for tx_reg
    reg ld_tx_reg;                // Load control signal for tx_reg
    reg [3:0] bit_counter;        // 4-bit counter to track 10-bit transmission
    reg [13:0] baud_counter;      // 14-bit counter for 9600 Baudrate
    reg state, next_state;        // FSM state and next state signals
    
    // Sequential logic for state transitions and data transmission
    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            tx_data <= 1;
            bit_counter <= 0;
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
            if (baud_counter == 10415) begin
                baud_counter <= 0; // For 10ns clock period, count to 10415 clk pulses for 9600 Baudrate
                if (ld_tx_reg) tx_reg <= {1'b1, datain, 1'b0}; // Load start (0), data, stop (1) bits
                if (sft_tx_reg) begin
                    tx_data <= tx_reg[0];
                    tx_reg <= tx_reg >> 1;
                    bit_counter <= bit_counter + 1;
                end
            end
        end
    end

    // Check if all bits are transmitted
    wire check_count;
    assign check_count = bit_counter == 4'd9 ? 1'd1 : 1'd0;

    // FSM Logic
    always @(posedge clk) begin
        case (state)
            1'b0: begin // Idle State
                if (transmit & en) begin
                    ld_tx_reg <= 1'b1;
                    state <= 1'b1;
                end
                sft_tx_reg <= 1'b0;
            end

            1'b1: begin // Transmitting State
                ld_tx_reg <= 1'b0;
                sft_tx_reg <= 1'b1;
                tx_data <= tx_reg[0];
                if (check_count)
                    state <= 1'b0; // Return to Idle after transmission
                else
                    state <= 1'b1;
            end
        endcase
    end
endmodule
