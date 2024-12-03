module Fifo_memory 
#
(
parameter WIDTH = 8,
parameter no_of_addresses = 16,
parameter address_bits = $clog2(no_of_addresses)
)
(
input wire wclken, rclken, wclk, rst,
input wire [WIDTH - 1:0] wdata,
input wire [address_bits-1:0] waddr, raddr,
output wire [WIDTH - 1:0] rdata
);
reg [WIDTH-1:0] memory [0:no_of_addresses-1]; //2*width as it hold also alu operation result
integer i;
assign rdata = memory[raddr];
always @(posedge wclk or negedge rst) 
begin
    if (!rst) begin
        for (i=0;i<no_of_addresses;i=i+1)
        begin
            memory[i] <= {WIDTH{1'b0}};
        end
    end
    else begin
    if (wclken) begin
        memory [waddr] <= wdata;
    end
    else begin
        memory [waddr]<= memory [waddr];    
    end
    end
end
    
endmodule
