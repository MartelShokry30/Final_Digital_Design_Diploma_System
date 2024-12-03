module edge_bit_counter (
    input wire clk,
	input wire reset_n,
    input wire enable,
    input wire [5:0] prescale,
    output reg [3:0] bit_cnt,
    output reg [4:0] edge_cnt
);
always @(posedge clk or negedge reset_n)
	if (!reset_n) begin
		bit_cnt <= 'd0;
		edge_cnt <= 'd0;
	end
	else begin
		if(!enable) begin
			bit_cnt <= 'd0;
			edge_cnt <= 'd0;
		end
		else begin
			if (((bit_cnt == 'd0) && (edge_cnt == prescale - 2'd2)) || ((bit_cnt != 'd0) && (edge_cnt == prescale - 1'b1))) begin //glitch in start bit
				bit_cnt <= bit_cnt + 1'b1;
				edge_cnt <= 'd0;
			end
			else begin
				edge_cnt <= edge_cnt+1'b1;
			end
		end
	end
endmodule
