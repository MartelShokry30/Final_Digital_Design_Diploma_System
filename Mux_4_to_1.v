`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2024 15:35:15
// Design Name: 
// Module Name: Mux_4_to_1
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


module Mux_4_to_1(
    input start_bit,
    input stop_bit,
    input [1:0] mux_sel,
    input ser_data,
    input par_bit,
    output reg TX_OUT
    );
    
    always @(*) begin
        case (mux_sel) 
           2'b00: TX_OUT = start_bit; 
           2'b01: TX_OUT = stop_bit; 
           2'b10: TX_OUT = ser_data; 
           2'b11: TX_OUT = par_bit; 
           default : TX_OUT = 1'b0;
        endcase
    end
endmodule
