module parity_check (
    input wire clk,
    input wire reset_n,
    input wire par_chk_en,
    input wire par_typ,
    input wire [7:0] p_data,
    input wire sampled_bit,
    input wire sample_valid,
    output reg par_err
);
reg par_bit_d;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        par_err <= 1'b0;
    end
    else begin
        if (par_chk_en) begin
            if (sample_valid) begin
                if ((( par_typ == 1'b1 && ^p_data == 1'b0) || ( par_typ == 1'b0 && ^p_data == 1'b1))&&(sampled_bit == 1'b1)
                ||(( par_typ == 1'b0 && ^p_data == 1'b0) || ( par_typ == 1'b1 && ^p_data == 1'b1))&&(sampled_bit == 1'b0)) begin
                     par_err <= 1'b0;
                end
                else begin
                     par_err <= 1'b1;
                end
            end
            else begin
                par_err <= par_err;
            end 
        end
        else begin
            par_err <= 1'b0;
        end 
    end
end
endmodule
