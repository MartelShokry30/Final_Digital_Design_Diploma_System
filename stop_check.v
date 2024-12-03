module stop_check (
    input wire clk,
    input wire reset_n,
    input wire stp_chk_en,
    input wire sampled_bit,sample_valid,
    output reg stp_err
);
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        stp_err <= 1'b0;
    end
    else begin
        if (stp_chk_en) begin
            if (sample_valid) begin
                if (sampled_bit == 1'b0) begin
                    stp_err <= 1'b1;
                end
                else begin
                    stp_err <= 1'b0;
                end
            end
            else begin
                stp_err <= stp_err;
            end
        end
        else begin
            stp_err <= 1'b0;
        end
    end
end

endmodule
