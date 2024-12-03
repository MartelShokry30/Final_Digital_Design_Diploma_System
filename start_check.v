module start_check (
    input wire clk,
    input wire reset_n,
    input wire strt_chk_en,
    input wire sampled_bit,sample_valid,
    output reg strt_glitch
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        strt_glitch <= 1'b0;
    end
    else begin
        if (strt_chk_en) begin
            if (sample_valid) begin
                if (sampled_bit == 1'b1) begin
                    strt_glitch <= 1'b1;
                end
                else begin
                    strt_glitch <= 1'b0;
                end
            end
            else begin
                strt_glitch <= strt_glitch;
            end
        end
        else begin
            strt_glitch <= 1'b0;
        end
    end
end
    

endmodule
