module uart_rx_top  #(parameter WIDTH = 8)(
    input wire clk,
    input wire reset_n,
    input wire rx_in,
    input wire [5:0] prescale,
    input wire par_en,
    input wire par_typ,
    output wire data_valid,
    output wire [WIDTH-1:0] p_data,
    output wire framing_error,
    output wire parity_error
);
    // Internal signals
    wire dat_samp_en, par_chk_en, strt_chk_en, stp_chk_en, des_en, enable;
    wire [3:0] bit_cnt; 
    wire [4:0] edge_cnt;
    wire sampled_bit, sample_valid;
    wire stp_err, strt_glitch, par_err;
    // Edge and bit counter
    edge_bit_counter u_edge_bit_counter (
        .clk(clk),
        .reset_n(reset_n),
        .prescale(prescale),
        .enable(enable),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt)
    );

    // Data sampling
    data_sampling u_data_sampling (
        .clk(clk),
        .reset_n(reset_n),
        .dat_samp_en(dat_samp_en),
        .edge_cnt(edge_cnt),
        .prescale(prescale),
        .rx_in(rx_in),
        .sampled_bit(sampled_bit),
        .sample_valid(sample_valid)
    );

    // Start bit checking
    start_check u_start_check (
        .clk(clk),
        .reset_n(reset_n),
        .strt_chk_en(strt_chk_en),
        .sampled_bit(sampled_bit),
        .sample_valid(sample_valid),
        .strt_glitch(strt_glitch)
    );

    // Stop bit checking
    stop_check u_stop_check (
        .clk(clk),
        .reset_n(reset_n),
        .stp_chk_en(stp_chk_en),
        .sampled_bit(sampled_bit),
        .sample_valid(sample_valid),
        .stp_err(framing_error)
    );

    // Parity checking
    parity_check u_parity_check (
        .clk(clk),
        .reset_n(reset_n),
        .par_chk_en(par_chk_en),
        .par_typ(par_typ),
        .p_data(p_data),
        .sampled_bit(sampled_bit),
        .sample_valid(sample_valid),
        .par_err(parity_error)
    );

    // Deserializer
    deserializer u_deserializer (
        .clk(clk),
        .reset_n(reset_n),
        .des_en(des_en),
        .sampled_bit(sampled_bit),
        .bit_cnt(bit_cnt),
        .sample_valid(sample_valid),
        .p_data(p_data)
    );

    // FSM to control everything
    fsm u_fsm (
        .clk(clk),
        .reset_n(reset_n),
        .rx_in(rx_in),
        .par_en(par_en),
        .stp_err(framing_error),
        .strt_glitch(strt_glitch),
        .par_err(parity_error),
        .edge_cnt(edge_cnt),
        .bit_cnt(bit_cnt),
        .dat_samp_en(dat_samp_en),
        .par_chk_en(par_chk_en),
        .strt_chk_en(strt_chk_en),
        .stp_chk_en(stp_chk_en),
        .des_en(des_en),
        .enable(enable),
        .data_valid(data_valid),
        .prescale(prescale)
    );

endmodule
