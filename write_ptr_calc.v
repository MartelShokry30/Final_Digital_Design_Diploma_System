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


module write_ptr_calc
    #(parameter addr_range = 3)//, parameter no_of_addresses = 8) 
    (
    input wire winc,wclk,wrst_n,
    input wire [addr_range:0] sync_rptr,
    output reg [addr_range-1:0] waddr,
    output wire [addr_range:0] wptr,
    output wire wfull
    );
    reg [addr_range:0] wptr_bin;
    //full logic here
    assign wfull = !wrst_n?1'b0:(wptr[addr_range]!=sync_rptr[addr_range])
    &&(wptr[addr_range-1]!=sync_rptr[addr_range-1])
    &&(wptr[addr_range-2:0]==sync_rptr[addr_range-2:0]);
    bin_to_gray_converter #(addr_range) DUT (
        .bin(wptr_bin),
        .gray(wptr)
    );
    
    
    always @( posedge(wclk) or negedge wrst_n) begin
        if (!wrst_n) begin
            waddr <= {addr_range{1'b0}};
            wptr_bin <= {addr_range+1{1'b0}};
        end
        else begin
            if (!wfull && winc) begin
                //if (waddr != no_of_addresses -1) begin
                    waddr <= waddr+1'b1; 
                    wptr_bin <= wptr_bin + 1'b1;
                
//                end
//                else begin
//                    waddr <= {addr_range{1'b0}}; 
//                    wptr_bin <= {addr_range+1{1'b0}};
                
//                end
            end
            else begin
                waddr <= waddr;     
                wptr_bin <= wptr_bin;            
            end 
        end    
    
    end
endmodule
