`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2024 15:35:15
// Design Name: 
// Module Name: Serializer
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


module Serializer(
    input clk,
    input rstn,
    input [7:0] P_DATA,
    input ser_en,
    input data_valid,
    input busy,
    output reg ser_done,
    output reg ser_data
    );
    reg [2:0] counter_d =0;
    reg [7:0] P_DATA_reg;
    reg ser_data_d;
    reg ser_done_d;
    reg [2:0] counter; //will wrap up after counter = 7
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            counter <= 3'd0;
            ser_data <= 1'b0;
            ser_done <= 1'b0;
            P_DATA_reg <= 8'd0;
        end
        else begin
            ser_done <= ser_done_d;
            ser_data <= ser_data_d;
            counter <= counter_d;
            if (data_valid && !busy) begin
                P_DATA_reg <= P_DATA;
                counter <= 0;
            end 
        end
    end
    
    always @(*) begin

        if (ser_en) begin
            counter_d = counter+1;
        end
        else begin
            counter_d = counter;
        end
        
        ser_data_d = P_DATA_reg[counter] && ser_en;
        
        if (counter == 3'b111 && ser_en == 1'b1) begin
            ser_done_d = 1'b1;
        end
        else begin
            ser_done_d = 1'b0;
        end
    end
endmodule
