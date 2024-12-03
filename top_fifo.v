`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 12:11:02
// Design Name: 
// Module Name: top_fifo
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


module top_fifo #(parameter WIDTH = 8, parameter NO_OF_ADDRESSES = 16, parameter ADDR_RANGE = 4) (
    input wire [WIDTH - 1:0] wdata,
    input wire winc, rinc, wclk, wrst_n, rclk, rrst_n, 
    output wire [WIDTH - 1:0] rdata,
    output wire wfull, rempty
);

    // Internal signals
    wire [ADDR_RANGE:0] sync_rptr, sync_wptr; // Synchronized pointers
    wire [ADDR_RANGE:0] wptr, rptr; // Write and read pointers (gray code)
    wire [ADDR_RANGE-1:0] waddr, raddr; // Write and read addresses (binary)
    
    // Instantiate Write Pointer Calculator
    write_ptr_calc #(ADDR_RANGE) write_ptr_inst (
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .sync_rptr(sync_rptr),
        .waddr(waddr),
        .wptr(wptr),
        .wfull(wfull)
    );
    
    // Instantiate Read Pointer Calculator
    read_ptr_calc #(ADDR_RANGE) read_ptr_inst (
        .rclk(rclk),
        .rinc(rinc),
        .rrst_n(rrst_n),
        .sync_wptr(sync_wptr),
        .raddr(raddr),
        .rptr(rptr),
        .rempty(rempty)
    );
    
    // Instantiate Gray Synchronizers
    Gray_sync #(ADDR_RANGE) sync_w2r (
        .clk(rclk),
        .rst_n(rrst_n),
        .ptr(wptr),
        .sync_ptr(sync_wptr)
    );
    
    Gray_sync #(ADDR_RANGE) sync_r2w (
        .clk(wclk),
        .rst_n(wrst_n),
        .ptr(rptr),
        .sync_ptr(sync_rptr)
    );
    
    // Instantiate FIFO Memory
    Fifo_memory #(WIDTH, NO_OF_ADDRESSES, ADDR_RANGE) fifo_mem (
        .wclken(winc && !wfull),
        .rclken(!rempty),
        .wclk(wclk),
        .rst(wrst_n),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .rdata(rdata)
    );

endmodule


