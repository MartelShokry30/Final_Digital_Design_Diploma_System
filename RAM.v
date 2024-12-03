`timescale 1ns / 1ps

module Reg_File_8x16 
#
(
parameter WIDTH = 8,
parameter no_of_addresses = 16,
parameter address_bits = $clog2(no_of_addresses)
)
(

    input  wire                   write_enable,
    input  wire                   read_enable,
    input  wire                   clk,
    input  wire                   rstn,
    input  wire  [address_bits-1:0]            address,
    input  wire  [WIDTH-1:0]           data_in,  
    output reg   [WIDTH-1:0]           data_out,
	output reg 						   Rd_D_Vld,
    output wire [WIDTH-1:0]           Op_A,Op_B,UART_Config,Div_Ratio
);

    // 2D Array
    reg [WIDTH-1:0] memory [0:no_of_addresses-1];        
    integer i;
    assign Op_A = memory[0];
    assign Op_B = memory[1];
    assign UART_Config = memory[2];
    assign Div_Ratio = memory[3];
    always @(posedge clk or negedge rstn) 
	begin
	    if (!rstn) begin
			for (i=0;i<no_of_addresses;i=i+1)
			begin
			    if (i==2) begin
			        memory[i][7:2] <= 6'd32; //prescale
			        memory[i][0] <= 1'b1; //parity enable
			        memory[i][1] <= 1'b0; //parity type
			    end
			    else if(i==3) begin
			        memory[i] <= 'd32;
			    end
			    else begin
				    memory[i] <= {WIDTH{1'b0}};
				end
			end
		    data_out <= {WIDTH{1'b0}};
		    Rd_D_Vld <= 1'b0;
		    
			end
	    else begin
           if (write_enable) 
             begin
               memory[address] <= data_in;
               Rd_D_Vld <= 1'b0;
             end
           else if (read_enable)
             begin
               data_out <= memory[address];
			   Rd_D_Vld <= 1'b1;
             end
           else
             begin
               data_out <= {WIDTH{1'b0}};
               Rd_D_Vld <= 1'b0;               
             end
        end
    end
endmodule