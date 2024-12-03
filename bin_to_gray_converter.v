`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 14:52:14
// Design Name: 
// Module Name: bin_to_gray_converter
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


module bin_to_gray_converter #(parameter N=4)
(
input [N:0] bin,
output [N:0] gray
);
genvar i;
generate 
for (i=0;i<N;i=i+1) begin
    assign gray[i] = bin[i] ^ bin[i+1];
end 
endgenerate

assign gray[N] = bin[N];
endmodule
