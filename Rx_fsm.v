module fsm (
    input wire clk,
    input wire reset_n,
    input wire rx_in,
    input wire par_en,
    input wire stp_err, strt_glitch, par_err,
	input wire [4:0] edge_cnt, 
	input wire [3:0] bit_cnt,
	input wire [5:0] prescale,
    output reg dat_samp_en, par_chk_en, strt_chk_en, stp_chk_en, des_en, enable,data_valid
);

	reg [2:0] current_state, next_state;
	parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010,  PARITY = 3'b011, STOP = 3'b100, VALIDITY = 3'b101;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			current_state <= IDLE;	
		end
		else begin
			current_state <= next_state;
		end
	end
	
	always @(*) begin
		case (current_state)
			IDLE: 
			begin
				if (rx_in == 1'b0) begin
					next_state = START;
						
				end
				else begin
					next_state = IDLE;
				end 
			end
			START:
			begin
				if (edge_cnt == prescale - 2'd2) begin //edge_cnt??
					if (!strt_glitch) begin //lazem a check glitch abl edge 7 (at 6 maslan)
						next_state = DATA;	
					end
					else begin
						next_state = IDLE;
					end
				end
                else begin
                    next_state = START;
                end
			end
			DATA:
			begin
				if (bit_cnt == 8 && (edge_cnt == prescale - 2'd1)) begin
					if (!par_en) begin
						next_state = STOP;
					end
					else begin
						next_state = PARITY;
					end 
				end
				else begin
					next_state = DATA;
				end
			end
			PARITY:
			begin
				if (edge_cnt == prescale - 2'd1) begin
				    if (par_err == 1'b0) begin
					   next_state = STOP;
				    end
				    else begin
				       next_state = IDLE; 
				    end
				end 
				else begin
				    next_state = PARITY;
				end
			end
			STOP:
			begin
				if (edge_cnt == prescale - 2'd1) begin //-2 to prevent taking one extra clock cycle for validity
				    if (stp_err == 1'b0) begin
					   next_state = VALIDITY;
					end
					else begin
					   next_state = IDLE;
					end
				end
				else begin
				    next_state = STOP;
				end
			end
			VALIDITY:
            begin
                if (rx_in==0) 
                begin  
                    next_state = START;
                end 
                else begin
                    next_state = IDLE;
                end   
              
            end	
            default: begin
                next_state =IDLE;
            end		
		endcase
		
	end
	always @(*) begin
	     par_chk_en = 1'b0; 
         strt_chk_en = 1'b0; 
         stp_chk_en = 1'b0;
         des_en = 1'b0;
         dat_samp_en = 1'b0;
         enable = 1'b0;
         data_valid = 1'b0;
	   case (current_state) 
	       IDLE: begin
	           par_chk_en = 1'b0; 
	           strt_chk_en = 1'b0; 
	           stp_chk_en = 1'b0;
	           des_en = 1'b0;
	           dat_samp_en = 1'b0;
	           enable = 1'b0;
	           data_valid = 1'b0;
	       end
	       START: begin
               par_chk_en = 1'b0; 
               strt_chk_en = 1'b1; 
               stp_chk_en = 1'b0;
               des_en = 1'b0;
               dat_samp_en = 1'b1;
               enable = 1'b1;
               data_valid = 1'b0;
           end
	       DATA: begin
               par_chk_en = 1'b0; 
               strt_chk_en = 1'b0; 
               stp_chk_en = 1'b0;
               des_en = 1'b1;
               dat_samp_en = 1'b1;
               enable = 1'b1;
               data_valid = 1'b0;
           end       
	       PARITY: begin
               par_chk_en = 1'b1; 
               strt_chk_en = 1'b0; 
               stp_chk_en = 1'b0;
               des_en = 1'b0;
               enable = 1'b1;
               dat_samp_en = 1'b1;
               data_valid = 1'b0;
           end  
	       STOP: begin
               par_chk_en = 1'b0; 
               strt_chk_en = 1'b0; 
               stp_chk_en = 1'b1;
               des_en = 1'b0;
               enable = 1'b1;
               dat_samp_en = 1'b1;
               data_valid = 1'b0;              

           end 
	       VALIDITY: begin
               par_chk_en = 1'b0; 
               strt_chk_en = 1'b0; 
               stp_chk_en = 1'b0;
               des_en = 1'b0;
               dat_samp_en = 1'b0;
               enable = 1'b0;
               data_valid = 1'b1;
           end
           default: begin 
           	   par_chk_en = 1'b0; 
               strt_chk_en = 1'b0; 
               stp_chk_en = 1'b0;
               des_en = 1'b0;
               dat_samp_en = 1'b0;
               enable = 1'b0;
               data_valid = 1'b0;
           end  
	   endcase
	end
endmodule

