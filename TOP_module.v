`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.09.2024 13:35:16
// Design Name: 
// Module Name: TOP_module
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


module Uart_tx#(parameter WIDTH = 8)
	(
    input Data_Valid,
    input [WIDTH-1:0] P_DATA,
    input PAR_EN,
    input PAR_TYP,
    input clk,
    input rstn,
    output TX_OUT,
    output busy
    );
    parameter stop_bit = 1'b1;
    parameter start_bit = 1'b0;
    wire ser_en;
    wire [1:0] mux_sel;
    wire ser_done;
    wire ser_data;
    wire par_bit;
    FSM fsm_inst (
        .Data_Valid(Data_Valid),
        .ser_done(ser_done),
        .ser_en(ser_en),
        .mux_sel(mux_sel),
        .busy(busy),
        .PAR_EN(PAR_EN),
        .clk(clk),
        .rstn(rstn)
    );

    // Instantiate the Serializer
    Serializer serializer_inst (
        .clk(clk),
        .rstn(rstn),
        .P_DATA(P_DATA),
        .ser_en(ser_en),
        .data_valid(Data_Valid),
        .busy(busy),
        .ser_done(ser_done),
        .ser_data(ser_data)
    );

    // Instantiate the Parity Calculator
    Parity_calc parity_calc_inst (
        .Data_Valid(Data_Valid),
        .P_DATA(P_DATA),
        .PAR_TYP(PAR_TYP),
        .busy(busy),
        .par_bit(par_bit),
        .clk(clk),
        .rstn(rstn)
    );

    // Instantiate the 4-to-1 Mux
    Mux_4_to_1 mux_inst (
        .start_bit(start_bit),
        .stop_bit(stop_bit),
        .mux_sel(mux_sel),
        .ser_data(ser_data),
        .par_bit(par_bit),
        .TX_OUT(TX_OUT)
    );
endmodule
