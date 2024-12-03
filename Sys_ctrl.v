`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2024 13:49:05
// Design Name: 
// Module Name: Sys_ctrl
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


module Sys_ctrl
#
(
parameter WIDTH = 8,
parameter no_of_addresses = 16,
parameter address_bits = $clog2(no_of_addresses)
)
(
    input clk,
    input rstn,
    input data_valid,
    input [WIDTH-1:0] p_data,
    input FIFO_FULL,
    input [2*WIDTH-1:0] ALU_OUT,
    input OUT_Valid,
    input [WIDTH-1:0] Rd_D,
    input Rd_D_Vld,
    output reg WrEn,
    output reg RdEn,
    output reg [address_bits-1:0] Addr,
    output reg [WIDTH-1:0]Wr_D,
    output reg [3:0] FUN,
    output reg EN,
	output reg Gate_EN,
    output reg [WIDTH-1:0] WR_DATA,
    output reg WR_INC
    );
    reg [address_bits-1:0] Addr_reg;
//    reg [WIDTH-1:0]Wr_D1;
//    reg [WIDTH-1:0]Wr_D2;
    reg [3:0] FUN_reg;
    
localparam Idle = 4'b0000, //states
           //dummy_state = 4'b0001,
           wr_addr = 4'b0010,
           wr_Data = 4'b0011,
           rd_addr = 4'b0100,
           op1 = 4'b0101,
           op2 = 4'b0110,
           ALU_fun = 4'b0111,
		   Filling_Fifo = 4'b1000,
		   Filling_Fifo_ALU = 4'b1001;
           
reg [3:0] current_state, next_state;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        current_state <= Idle;
        Addr_reg <= 'd0;
        FUN_reg <= 'd0;
    end
    else begin
        current_state <= next_state;
        if ((current_state == wr_addr) && data_valid) begin
            Addr_reg <=  p_data; 
        end
        if ((current_state == rd_addr) && data_valid) begin
            Addr_reg <=  p_data; 
        end
//        if ((current_state == op1) && data_valid) begin
//            Wr_D1 <=  p_data; 
//        end
//        if ((current_state == op2) && data_valid) begin
//            Wr_D2 <=  p_data; 
//        end
        if ((current_state == ALU_fun) && data_valid) begin
            FUN_reg <=  p_data; 
        end
    end
end

always @(*) begin
    WrEn    = 1'b0;
    RdEn    = 1'b0;
    Addr    = 'd0;
    Wr_D    = 'd0;
    FUN     = 3'd0;
    EN      = 1'b0;
    WR_DATA = 'd0;
    WR_INC  = 1'b0;//outputting 0 (stop bit)
    Gate_EN = 1'b0;
    next_state = Idle;
	case(current_state)
		Idle: begin //added it to prevent taking the wrong data while data_valid is 1
                WrEn    = 1'b0;
                RdEn    = 1'b0;
                Addr    = 'd0;
                Wr_D    = 'd0;
                FUN     = 3'd0;
                EN      = 1'b0;
                WR_DATA = 'd0;
                WR_INC  = 1'b0;//outputting 0 (stop bit)
                Gate_EN = 1'b0;
                
                if (data_valid) begin
                                            
                    case(p_data)
                       'hAA: next_state = wr_addr;
                       'hBB: next_state = rd_addr; 
                       'hCC: next_state = op1; // ALU WITH OP
                       'hDD: next_state = ALU_fun; // NO OPERANDS ALU
                       default: next_state = Idle;
                   endcase
                end
                else begin
                    next_state = Idle;
                end
               end
		wr_addr: begin
					if (data_valid) begin
					    next_state = wr_Data;
					    //Addr = p_data;
						
					end
					else begin
						next_state = wr_addr;
						//Addr = 'd0;
					end
			     end
		wr_Data: begin
					if (data_valid) begin
						next_state = Idle;
						Wr_D = p_data; WrEn = 1'b1;Addr = Addr_reg; 
					end
					else begin
						next_state = wr_Data;
						Wr_D = 'd0; WrEn = 1'b0;
					end
				 end
		rd_addr: begin
					if (data_valid) begin
						next_state = Filling_Fifo;
						Addr = p_data;RdEn = 1'b1;
					end
					else begin
						next_state = rd_addr;
						Addr = 'd0;RdEn = 1'b0;
					end
			     end                 
		op1: begin
					if (data_valid) begin
						next_state = op2;
						Addr = 'h0;WrEn = 1'b1;Wr_D=p_data;
					end
					else begin
						next_state = op1;
						Addr = 'h0;WrEn = 1'b0;Wr_D='d0;
					end
			     end
		op2: begin
					
					if (data_valid) begin
						next_state = ALU_fun;
						Addr = 'h1;WrEn = 1'b1;Wr_D=p_data;
					end
					else begin
						next_state = op2;
						Addr = 'h1;WrEn = 1'b0;Wr_D='d0;
					end
			     end
		ALU_fun: begin
					if (data_valid) begin
						next_state = Filling_Fifo;
						FUN = p_data; EN = 1'b1; Gate_EN = 1'b1; WrEn = 1'b0;
					end
					else begin
						next_state = ALU_fun;
						FUN = 'd0; EN = 1'b0; Gate_EN = 1'b0; WrEn = 1'b0;
					end
				 end
		Filling_Fifo: begin
					if (!FIFO_FULL) begin
						
						WR_INC = 1'b1;
	                    if (Rd_D_Vld) begin
	                        Addr = Addr_reg;
	                        RdEn = 1'b1;
                            WR_DATA = Rd_D;
                            next_state = Idle;
                        end
                        else if (OUT_Valid) begin
                            FUN = FUN_reg;
                            Gate_EN = 1'b1;
                            EN = 1'b1;
                            WR_DATA = ALU_OUT[WIDTH-1:0];
                            next_state = Filling_Fifo_ALU;
                        end
                           
					end
					else begin
						next_state =Filling_Fifo;
			            WR_INC = 1'b0;
                        WR_DATA = 'd0;
					end
				 end	
		Filling_Fifo_ALU: begin
                         Gate_EN = 1'b1;
                         EN = 1'b1;
                         WR_INC = 1'b1;
                         FUN = FUN_reg;
                         WR_DATA = ALU_OUT[2*WIDTH-1:WIDTH-1];
                         next_state = Idle;
                        end    				 	
		default: begin
					next_state = Idle;
        		    WrEn    = 1'b0;
                    RdEn    = 1'b0;
                    Addr    = 'd0;
                    Wr_D    = 'd0;
                    FUN     = 3'd0;
                    EN      = 1'b0;
                    WR_DATA = 'd0;
                    WR_INC  = 1'b0;//outputting 0 (stop bit)
                    Gate_EN = 1'b0;
				 end
	endcase
end
//always @(*) begin

//	case(current_state) 
//	    Idle:
//	    begin

//	    end
//		wr_addr: 
//		begin 
//			if (data_valid) begin
				 
//			end
//		end
//		wr_Data:  
//		begin 
//			if (data_valid) begin
				
//			end
//		end
//		rd_addr: 
//		begin 
//			if (data_valid) begin
				
//			end
//		end
//		op1: 
//		begin 
//			if (data_valid) begin
				
//			end
//		end
//		op2: 
//		begin 
//			if (data_valid) begin
				
//			end
//		end
//		ALU_fun: 
//		begin 
//			if (data_valid) begin
				
//			end
//		end
//		Filling_Fifo: 
//		begin 
//			if (!FIFO_FULL) begin

//			end
//			else begin

//			end
//		end
//	default: 
//			begin
//		    WrEn    = 1'b0;
//            RdEn    = 1'b0;
//            Addr    = 'd0;
//            Wr_D    = 'd0;
//            FUN     = 3'd0;
//            EN      = 1'b0;
//            WR_DATA = 'd0;
//            WR_INC  = 1'b0;//outputting 0 (stop bit)
//            Gate_EN = 1'b0;
//			end
//	endcase
//end

endmodule

