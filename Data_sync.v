module Data_sync #(
    parameter WIDTH = 8, // Parameter for the bus width (default is 8)
    parameter N = 2
)(
    input  wire [WIDTH-1:0] unsync_bus, // Unsynchronized bus (parameterized width)
    input  wire bus_enable,             // Source domain enable signal
    input  wire CLK,                    // Destination domain clock
    input  wire RST,                    // Active Low Asynchronous Reset
    output reg [WIDTH-1:0] sync_bus,   // Synchronized bus (parameterized width)
    output reg enable_pulse            // Destination domain enable signal
);

    reg [N-2:0] meta_flop;
    reg sync_flop,enable_flop;
    wire enable_pulse_d;
    wire [WIDTH-1:0]sync_bus_d;
    integer i;
    assign enable_pulse_d = !enable_flop && sync_flop;
    assign sync_bus_d = enable_pulse_d? unsync_bus:sync_bus;
    
    // Module implementation here
    always @(posedge CLK or negedge RST)//multi flip_flop
    begin
        if (!RST) begin
            meta_flop <={N{1'b0}};
            sync_flop <= 1'b0;
            enable_flop <= 1'b0;
            enable_pulse <= 1'b0;
            sync_bus <= {WIDTH{1'b0}};
        end
        else begin
           // enable_pulse <= sync_flop && ;
            meta_flop[0] <= bus_enable;
            for (i=1;i<N-1;i=i+1)
            begin
                meta_flop[i] <= meta_flop[i-1];
            end
            
            sync_flop <= meta_flop[N-2]; 
            enable_flop <= sync_flop;
            enable_pulse <= enable_pulse_d;//!enable_flop && sync_flop;
            sync_bus <= sync_bus_d;
        end
    end
    

endmodule
