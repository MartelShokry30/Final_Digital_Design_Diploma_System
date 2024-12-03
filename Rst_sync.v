`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 16:27:30
// Design Name: 
// Module Name: Rst_sync
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


module Rst_sync #(parameter N=2)(//n for number of flip flops
    input wire RST,
    input wire CLK,
    output reg SYNC_RST
    );
    reg [N-2:0] MID_RST;
    integer i;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            SYNC_RST <= 1'b0;
            MID_RST <={N{1'b0}};
        end
        else begin
            MID_RST[0] <= 1'b1;
            for (i=1;i<N-1;i=i+1)
            begin
                MID_RST[i] <= MID_RST[i-1];
            end
            SYNC_RST <= MID_RST[N-2];
        end
    end
endmodule
