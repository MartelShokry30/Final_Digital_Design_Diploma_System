`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 12:34:52
// Design Name: 
// Module Name: Gray_sync
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


module Gray_sync
    #(parameter addr_range = 3)
    (
    input wire clk,rst_n,
    input wire [addr_range:0] ptr,
    output reg [addr_range:0] sync_ptr
    );
    reg [addr_range:0] mid_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ptr <= {addr_range+1{1'b0}};
            mid_sync <= {addr_range+1{1'b0}};
        end
        else begin
            sync_ptr <= mid_sync;
            mid_sync <= ptr; 
        end
    end
endmodule
