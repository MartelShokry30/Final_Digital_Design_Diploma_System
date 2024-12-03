
module Parity_calc(
    input Data_Valid,
    input [7:0] P_DATA,
    input PAR_TYP,
    input busy,
    output reg par_bit,
    input clk,
    input rstn
    );
    //parity_type 1 for odd
    reg par_bit_d;
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            par_bit <= 1'b0;
        end
        else begin
            par_bit <= par_bit_d;
        end
    end
    always @(*) begin
        if (!busy && Data_Valid) begin
            if (( PAR_TYP == 1'b1 && ^P_DATA == 1'b0) || ( PAR_TYP == 1'b0 && ^P_DATA == 1'b1)) begin
                par_bit_d = 1'b1;
            end 
            else begin
                par_bit_d = 1'b0;
            end
        end 
	    else begin
		    par_bit_d = par_bit;	
	    end
    end
endmodule