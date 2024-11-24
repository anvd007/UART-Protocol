`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2024 21:02:28
// Design Name: 
// Module Name: Transmitter_alt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// https://github.com/hell03end/verilog-uart/blob/master/uart/Uart8Transmitter.v

module Transmitter_alt(
    input transmit,
    input clk,
    input en,
    input reset,
    input [7:0] data_in,
    output reg tx_data
    );

    // State declarations
    reg [1:0] state;
    reg [7:0] tx_reg;

    // State encoding
    parameter IDLE = 2'b00, 
              STARTBIT = 2'b01, 
              DATABITS = 2'b10, 
              STOPBIT = 2'b11;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            tx_data <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    if (transmit & en) begin
                        tx_reg <= data_in; // Load data to be transmitted
                        tx_data <= 1'b1;  // Idle state TX line is high
                        state <= STARTBIT;
                    end
                end

                STARTBIT: begin
                    tx_data <= 1'b0;  // Send start bit (logic 0)
                    state <= DATABITS;
                end

                DATABITS: begin
                    tx_data <= tx_reg[0];      // Transmit LSB of data
                    tx_reg <= tx_reg >> 1;    // Shift data right
                    if (&tx_reg)              // If all data bits are transmitted
                        state <= STOPBIT;     // Move to stop bit state
                end

                STOPBIT: begin
                    tx_data <= 1'b1;  // Send stop bit (logic 1)
                    state <= IDLE;   // Return to idle state
                end
            endcase
        end
    end
endmodule

