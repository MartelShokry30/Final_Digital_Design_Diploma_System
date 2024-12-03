module data_sampling (
    input wire clk,
    input wire reset_n,
    input wire dat_samp_en,
    input wire [4:0]edge_cnt,
    input wire [5:0] prescale,
    input wire rx_in,
    output reg sampled_bit,sample_valid
);
wire [4:0] sample_pnt;
reg  [1:0] counter_ones = 2'b00;
reg  [1:0] counter_zeros = 2'b00;
reg  [1:0] counter_samples = 2'b00;
assign sample_pnt = prescale/2;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        sampled_bit <= 1'b0;
        sample_valid <= 1'b0;
        counter_ones <= 2'b00;
        counter_zeros <= 2'b00;
        counter_samples <= 2'b00;
    end
    else begin
        if (dat_samp_en) begin

            if ((edge_cnt == sample_pnt)||(edge_cnt == sample_pnt - 1'b1)||(edge_cnt == sample_pnt +1'b1)) begin
                //sampled
                counter_samples<=counter_samples+1'b1;
                //sampled_bit <= rx_in;
                if (rx_in == 1'b1) begin
                    counter_ones<=counter_ones+1'b1;
                    
                end
                else begin
                    counter_zeros<=counter_zeros+1'b1;
                end
                
                if (counter_samples == 2'b10) begin //taking 3 samples into account
                    if (counter_ones > counter_zeros) begin
                        sampled_bit <= 1'b1;
                    end
                    else if (counter_ones < counter_zeros) begin
                        sampled_bit <= 1'b0;
                    end
                    else begin
                        if (rx_in == 1'b1) begin
                            sampled_bit <= 1'b1;
                            
                        end
                        else begin
                            sampled_bit <= 1'b0;
                        end                        
                    end
                    counter_samples <= 2'b00;
                    counter_ones <= 2'b00;
                    counter_zeros <= 2'b00;
                    sample_valid <= 1'b1;
                end
                
            end
            else begin
                sampled_bit <= sampled_bit;
                sample_valid <= 1'b0;
            end 
       end
       else begin
            sampled_bit <= 1'b0;
            sample_valid <= 1'b0;
       end
    end
end


endmodule
