
module FSM(
    input Data_Valid,
    input ser_done,
    output reg ser_en,
    output reg [1:0] mux_sel,
    output reg busy,
    input PAR_EN,
    input clk,
    input rstn
    );
    
    
    localparam Idle = 3'b000, //states
               Start = 3'b001,
               Data = 3'b010,
               Parity = 3'b011,
               Stop = 3'b100;
    reg [2:0] current_state, next_state;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            current_state <= Idle;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    always @(*) begin
        case(current_state)
            Idle : begin
                        if (Data_Valid) begin
                            next_state = Start;
                        end 
                        else begin
                            next_state = Idle;
                        end
                   end
            Start: begin
                        next_state = Data;   
                   end
            Data: begin
                        if (ser_done && PAR_EN) begin
                            next_state = Parity;  
                        end 
                        else if (ser_done && !PAR_EN) begin
                            next_state = Stop;
                        end
                        else begin
                            next_state = Data;
                        end     
                  end
            Parity: begin
                        next_state = Stop;
                        end                 
            Stop: begin
                        next_state = Idle;
                  end
            default: begin
                        next_state = Idle;
                     end
        endcase
    end
    always @(*) begin
        case(current_state) 
            Idle:  begin mux_sel = 1; busy = 0; ser_en = 0; end //outputting 0 (stop bit)
            Start: begin mux_sel = 0; busy = 1; ser_en = 1; end 
            Data:  begin mux_sel = 2; busy = 1; ser_en = 1; end
            Parity: begin mux_sel = 3; busy = 1; ser_en = 0; end
            Stop:  begin mux_sel = 1; busy = 1; ser_en = 0; end
	    default: begin mux_sel = 1; busy = 0; ser_en = 0; end
        endcase
    end
    
                
               
endmodule