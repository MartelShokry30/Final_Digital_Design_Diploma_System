module deserializer (
    input wire clk,
    input wire reset_n,
    input wire des_en,
    input wire sampled_bit,
    input wire [3:0] bit_cnt,
    input wire sample_valid,
    output reg [7:0] p_data
    
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        p_data <= 8'd0;
    end
    else begin
        if (des_en == 1'b1 && sample_valid) begin
            p_data[bit_cnt-1'b1] <= sampled_bit;
        end
    end
end
endmodule
