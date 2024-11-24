`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2024 20:58:14
// Design Name: 
// Module Name: Top_Module
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


module Top_Module(
input transmit,
input [7:0] datain,
input en, 
input clk,
input reset,
output reg tx_data
    );
    
    Transmitter uut1 ();
    debounce_ckt uut2 ();
    
endmodule
