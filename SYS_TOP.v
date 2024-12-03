module SYS_TOP 
#
(
parameter WIDTH = 8,
parameter no_of_addresses = 16,
parameter address_bits = $clog2(no_of_addresses)
)
(
    input   wire                          RST_N,       // Active low reset
    input   wire                          UART_CLK,    // UART clock
    input   wire                          REF_CLK,     // Reference clock
    input   wire                          UART_RX_IN,  // UART RX input
    output  wire                          UART_TX_O,   // UART TX output
    output  wire                          parity_error, // Parity error
    output  wire                          framing_error // Framing error
);

    // Internal signals and wires
    wire sync_rst_1, sync_rst_2;   // Synchronized reset signals
	wire RX_CLK, TX_CLK, ALU_CLK;
	wire [WIDTH-1:0]UART_Config,Mux_div_ratio,Div_Ratio;
	wire Gate_EN;
	wire [WIDTH-1:0] Op_A, Op_B;
	wire WrEn,RdEn,Rd_D_Vld,EN,OUT_Valid,WR_INC,FIFO_FULL,enable_pulse,bus_enable,F_EMPTY,Busy,RD_INC;
	wire [address_bits-1:0]Addr;
	wire [WIDTH-1:0]Wr_D,Rd_D,unsync_bus,sync_bus,WR_DATA,RD_DATA;
	wire [3:0]FUN;
	wire [2*WIDTH-1:0]ALU_OUT;
	

    // Clock gating instance
    CLK_GATE clk_gate (
        .CLK_EN(Gate_EN),         // Enable clock gating (always enabled)
        .CLK(REF_CLK),         // Reference clock
        .GATED_CLK(ALU_CLK)  // Output gated clock
    );
    
    CLKDIV_MUX #(.WIDTH(WIDTH)) mux_instance (
        .IN(UART_Config[WIDTH-1:2]),
        .OUT(Mux_div_ratio)
    );

    // Instantiate Clk_Div
    ClkDiv clk_div_TX_instance (
        .i_ref_clk(UART_CLK),
        .i_rst(sync_rst_2),
        .i_clk_en(1'b1),
        .i_div_ratio(Div_Ratio),
        .o_div_clk(TX_CLK)
    );
    ClkDiv clk_div_RX_instance (
        .i_ref_clk(UART_CLK),
        .i_rst(sync_rst_2),
        .i_clk_en(1'b1),
        .i_div_ratio(Mux_div_ratio),
        .o_div_clk(RX_CLK)
    );

    // Reset synchronizers for REF_CLK and UART_CLK domains
    Rst_sync #(.N(2)) rst_sync_1 (
        .RST(RST_N),          // Active high reset
        .CLK(REF_CLK),         // REF_CLK domain
        .SYNC_RST(sync_rst_1)  // Synchronized reset
    );

    Rst_sync #(.N(2)) rst_sync_2 (
        .RST(RST_N),          // Active high reset
        .CLK(UART_CLK),        // UART_CLK domain
        .SYNC_RST(sync_rst_2)  // Synchronized reset
    );

    // UART Receiver instance
    uart_rx_top uart_rx (
        .clk(RX_CLK),         // UART clock
        .reset_n(sync_rst_2),        // Active low reset
        .rx_in(UART_RX_IN),     // UART RX input
        .prescale(UART_Config[WIDTH-1:2]),        // Prescale value for baud rate
        .par_en(UART_Config[0]),          // Parity enable (disabled for now)
        .par_typ(UART_Config[1]),         // Parity type (N/A)
        .data_valid(rx_data_valid),  // RX data valid
        .p_data(unsync_bus),            // Received data
        .parity_error(parity_error),
        .framing_error(framing_error)
    );

    // Data Synchronizer to align RX data with REF_CLK domain
    Data_sync #(.WIDTH(8), .N(2)) data_sync (
        .unsync_bus(unsync_bus),        // Data from RX
        .bus_enable(rx_data_valid),  // Valid data signal from RX
        .CLK(REF_CLK),               // REF_CLK domain
        .RST(sync_rst_1),            // Synchronized reset
        .sync_bus(sync_bus),  // Synchronized data for FIFO
        .enable_pulse(enable_pulse)   // Pulse for FIFO write increment
    );

    // FIFO instance
    top_fifo #(.WIDTH(WIDTH), .NO_OF_ADDRESSES(no_of_addresses), .ADDR_RANGE(address_bits)) async_fifo (
        .wdata(WR_DATA),  // Data to write into FIFO
        .winc(WR_INC),       // Write increment signal
        .rinc(RD_INC),       // Read increment signal
        .wclk(REF_CLK),           // Write clock
        .wrst_n(sync_rst_1),      // Write domain reset
        .rclk(TX_CLK),          // Read clock
        .rrst_n(sync_rst_2),      // Read domain reset
        .rdata(RD_DATA),     // Data read from FIFO
        .wfull(FIFO_FULL),        // FIFO full signal
        .rempty(F_EMPTY)       // FIFO empty signal
    );

    // Pulse Generator for FIFO read increment
    PULSE_GEN pulse_gen (
        .clk(TX_CLK),            // UART clock domain
        .rst(sync_rst_2),          // Reset
        .lvl_sig(Busy),     // Level signal (when FIFO is not empty)
        .pulse_sig(RD_INC)    // Pulse signal to increment read
    );

    // Register File instance
    Reg_File_8x16 #(.WIDTH(WIDTH), .no_of_addresses(no_of_addresses), .address_bits(address_bits))reg_file (
        .write_enable(WrEn),  // Write enable signal
        .read_enable(RdEn),            // Read enable (always enabled)
        .clk(REF_CLK),                 // REF_CLK domain
        .rstn(sync_rst_1),             // Reset signal
        .address(Addr),                // Address to access
        .data_in(Wr_D),             // Input data from RX
        .data_out(Rd_D),  // Data output
        .Rd_D_Vld(Rd_D_Vld),   // Read data valid signal
        .Op_A(Op_A),
        .Op_B(Op_B),
        .Div_Ratio(Div_Ratio),
        .UART_Config(UART_Config)
    );

    // ALU instance
    ALU #(.WIDTH(WIDTH)) alu (
        .clk(ALU_CLK),               // REF_CLK domain
        .rstn(sync_rst_1),           // Reset signal
        .A(Op_A),       // Operand A from Register File
        .B(Op_B),            // Operand B from FIFO
        .ALU_FUN(FUN),           // ALU function selector
        .EN(EN),
        .ALU_OUT(ALU_OUT),        // ALU result
        .OUT_Valid(OUT_Valid)    // ALU output valid signal
    );

    // System Controller (SYS_CTRL) instance
    Sys_ctrl #(.WIDTH(WIDTH), .no_of_addresses(no_of_addresses)) sys_ctrl (
        .clk(REF_CLK),                // REF_CLK domain
        .rstn(sync_rst_1),            // Reset signal
        .data_valid(enable_pulse),   // Data valid from RX
        .p_data(sync_bus),             // Received data
        .FIFO_FULL(FIFO_FULL),        // FIFO full signal
        .ALU_OUT(ALU_OUT),         // ALU output
        .OUT_Valid(OUT_Valid),    // ALU output valid
        .Rd_D(Rd_D),     // Register File data output
        .Rd_D_Vld(Rd_D_Vld), // Register File read valid
        .WrEn(WrEn),                      // Write enable (not connected)
        .RdEn(RdEn),                      // Read enable (not connected)
        .Addr(Addr),                      // Address (not connected)
        .Wr_D(Wr_D),                      // Write data (not connected)
        .FUN(FUN),                // ALU function
        .EN(EN),                        // Enable (not connected)
        .Gate_EN(Gate_EN),                   // Clock gate enable (not connected)
        .WR_DATA(WR_DATA),                   // Write data (not connected)
        .WR_INC(WR_INC)          // FIFO write increment signal
    );

    // UART Transmitter instance
    Uart_tx #(.WIDTH(WIDTH))uart_tx 
    (
        .Data_Valid(!F_EMPTY),  // Data valid signal from ALU
        .P_DATA(RD_DATA),         // ALU result to be transmitted
        .PAR_EN(UART_Config[0]),               // Parity enable (disabled)
        .PAR_TYP(UART_Config[1]),              // Parity type (N/A)
        .clk(TX_CLK),              // UART clock
        .rstn(sync_rst_2),                // Reset signal
        .TX_OUT(UART_TX_O),          // UART TX output
        .busy(Busy)               // TX busy signal
    );

endmodule
