`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 16:01:18
// Design Name: 
// Module Name: write_ptr_calc
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


module read_ptr_calc
    #(parameter addr_range = 3)//, parameter no_of_addresses = 8)   
    (
    input wire rclk,rrst_n,
    input wire [addr_range:0] sync_wptr,
    output reg [addr_range-1:0] raddr,
    output wire [addr_range:0] rptr,
    input wire rinc,
    output wire rempty
    );
    reg [addr_range:0] rptr_bin;
    assign rempty = !rrst_n?1'b1:(rptr == sync_wptr);
    bin_to_gray_converter #(addr_range) DUT (
        .bin(rptr_bin),
        .gray(rptr)
    );
    
    always @( posedge(rclk) or negedge rrst_n) begin
        if (!rrst_n) begin
            raddr <= {addr_range{1'b0}};
            rptr_bin <= {addr_range+1{1'b0}};
        end
        else begin
            if ((!rempty && rinc)) begin
//                if (raddr != no_of_addresses -1) begin
                    raddr <= raddr+1'b1; 
                    rptr_bin <= rptr_bin + 1'b1;
                
//                end
//                else begin
//                    raddr <= {addr_range{1'b0}}; 
//                    rptr_bin <= {addr_range+1{1'b0}};
                
//                end
            end
            else begin
                raddr <= raddr;
                rptr_bin <= rptr_bin;
            end
        end    
    
    end
endmodule
