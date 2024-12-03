vlib work
vlog ALU.v bin_to_gray_converter.v CLKDIV_MUX.v Clk_Div.v CLK_GATE.v data_sampling.v Data_sync.v deserializer.v edge_bit_counter.v Fifo_memory.v Gray_sync.v Mux_4_to_1.v Parity_calc.v parity_check.v PULSE_GEN.v RAM.v read_ptr_calc.v Rst_sync.v Rx_fsm.v Serializer.v start_check.v stop_check.v sync_r2w.v Sys_ctrl.v SYS_TOP.v  top_fifo.v TOP_module.v Tx_FSM.v uart_rx_top.v write_ptr_calc.v Sys_top_tb.v
vsim -voptargs=+acc work.tb_SYS_TOP -cover
add wave *
run -all
//quit -sim
//vlog Fifo_tb.v bin_to_gray_+cover