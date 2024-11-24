`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2024 20:42:19
// Design Name: 
// Module Name: debounce_ckt
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


module debounce_ckt( // By default, module-defined variables are considered net type
    input clk,
    input transmit,
    output reg checked_transmit
    );

    reg pulse_counter;
    reg threshold;

    // Synchronizing the asynchronous input using a 2-FF Synchronizer
    reg ff1, ff2;

    always @(posedge clk) begin
        ff1 <= transmit;
        ff2 <= ff1;
    end

    // FF2's output is the synchronized signal of the asynchronous `transmit` signal
    always @(posedge clk) begin
        if (ff2) begin
            pulse_counter <= pulse_counter + 1;
            if (pulse_counter > threshold) begin
                pulse_counter <= 0;
                checked_transmit <= 1'b1;
            end else begin
                checked_transmit <= 1'b0;
            end
        end else begin
            pulse_counter <= 0;
        end
    end
endmodule
