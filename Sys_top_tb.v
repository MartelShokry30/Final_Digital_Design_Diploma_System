`timescale 1ns / 1ps

module tb_SYS_TOP;
    
    // Parameters
    parameter WIDTH = 8;
    parameter no_of_addresses = 16;
    parameter address_bits = $clog2(no_of_addresses);

    // Clock and Reset Signals
    reg RST_N;
    reg UART_CLK;
    reg REF_CLK;
    parameter Test_Cases = 18;
    reg    [8:0]   Expec_Outs   [Test_Cases-1:0] ; //p_data and data valid signals concatenated together
    
    // UART RX and TX Signals
    reg UART_RX_IN;
    wire UART_TX_O;
    
    // Error Signals
    wire parity_error;
    wire framing_error;
    integer z;
    // Instantiate the DUT (Device Under Test)
    SYS_TOP #(
        .WIDTH(WIDTH),
        .no_of_addresses(no_of_addresses),
        .address_bits(address_bits)
    ) dut (
        .RST_N(RST_N),
        .UART_CLK(UART_CLK),
        .REF_CLK(REF_CLK),
        .UART_RX_IN(UART_RX_IN),
        .UART_TX_O(UART_TX_O),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );

    // Clock Generation for UART_CLK
    initial begin
        UART_CLK = 0;
        forever #135 UART_CLK = ~UART_CLK;  // 50 MHz Clock (20ns period)
    end

    // Clock Generation for REF_CLK
    initial begin
        REF_CLK = 0;
        forever #10 REF_CLK = ~REF_CLK;  // 50 MHz Clock (16ns period)
    end

    // Reset Generation
    initial begin
        RST_N = 0;            // Assert reset (active low)
        #270 RST_N = 1;        // De-assert reset 
    end

    // UART Data Transmission Task
    integer prescale;
    // Test Sequence
    initial begin
        // Initialize Inputs
        UART_RX_IN = 1;  // Idle state for UART line
        ///UART_TX_O = 1;
        // Wait for Reset De-assertion
        @(posedge RST_N);
        //#100;

         //Send UART Data
        send_uart_data(8'hAA);//setting prescale to 16
        send_uart_data(8'h02);  
        send_uart_data(8'b01000001);
        #(32*135*2);
//        prescale = 16;
        send_uart_data(8'hAA);  // writing 0x5 to the address A
        send_uart_data(8'h0A);
        send_uart_data(8'h05);  
        send_uart_data(8'hBB);// reading from same address
        send_uart_data(8'h0A); //success
        //check_out_parity(Expec_Outs[0],0);  
        send_uart_data(8'hCC);//alu with operands operation
        send_uart_data(8'h0A);
        send_uart_data(8'h0C);
        send_uart_data(8'h00);//success (adding A and C)
        //check_out_parity(Expec_Outs[0],0);
        //alu without operands
        send_uart_data(8'hDD);
        send_uart_data(8'h06);//success (NAND for saved operands in addresses 0x1 and 0x2
        //check_out_parity(Expec_Outs[0],0);
        send_uart_data(8'hDD);
        send_uart_data(8'h05); //success (A OR B)
        //check_out_parity(Expec_Outs[0],0);
        send_uart_data(8'hAA);//setting prescale to 8
        send_uart_data(8'h02);  
        send_uart_data(8'b00100001);
        #(32*135*2);
        send_uart_data(8'hAA);  // writing 0x5 to the address A
        send_uart_data(8'h0A);
        send_uart_data(8'h05);  
        send_uart_data(8'hBB);// reading from same address
        send_uart_data(8'h0A); //success
        //check_out_parity(Expec_Outs[0],0);  
        send_uart_data(8'hCC);//alu with operands operation
        send_uart_data(8'h0A);
        send_uart_data(8'h0C);
        send_uart_data(8'h00);//success (adding A and C)
        //check_out_parity(Expec_Outs[0],0);
        //alu without operands
        send_uart_data(8'hDD);
        send_uart_data(8'h06);//success (NAND for saved operands in addresses 0x1 and 0x2
        //check_out_parity(Expec_Outs[0],0);
        send_uart_data(8'hDD);
        send_uart_data(8'h05); //success (A OR B)
        // Wait for some time to observe the system response
        
        send_uart_data(8'hAA);//setting parity type to odd instead of even and handling parity bit in sen uart data taska ccordingly
        send_uart_data(8'h02);  
        send_uart_data(8'b00100011);
        #(32*135*2);
        send_uart_data_odd(8'hAA);  // writing 0x5 to the address A
        send_uart_data_odd(8'h0A);
        send_uart_data_odd(8'h05);  
        send_uart_data_odd(8'hBB);// reading from same address
        send_uart_data_odd(8'h0A); //success
        //check_out_parity(Expec_Outs[0],0);  
        send_uart_data_odd(8'hCC);//alu with operands operation
        send_uart_data_odd(8'h0A);
        send_uart_data_odd(8'h0C);
        send_uart_data_odd(8'h00);//success (adding A and C)
        //check_out_parity(Expec_Outs[0],0);
        //alu without operands
        send_uart_data_odd(8'hDD);
        send_uart_data_odd(8'h06);//success (NAND for saved operands in addresses 0x1 and 0x2
        //check_out_parity(Expec_Outs[0],0);
        send_uart_data_odd(8'hDD);
        send_uart_data_odd(8'h05); //success (A OR B)
        // Wait for some time to observe the system response
        #500000;
        $finish;
    end
    
    initial begin
        $readmemb("expect_outs.txt", Expec_Outs);
        for (z = 0; z < Test_Cases; z = z + 1) begin
            check_out_parity(Expec_Outs[z],z);
//            UART_RX_IN = data[i];
//            #(2*135*32);  // 1 bit time
        end
    end
    task send_uart_data;
        input [7:0] data;
        integer i;
        begin
            // Start bit (LOW)
            UART_RX_IN = 0;
            $display ("%d",prescale);
            #(2*135*32);  // 1 bit time (9600 baud rate ~104us)

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                UART_RX_IN = data[i];
                #(2*135*32);  // 1 bit time
            end

            // Stop bit (HIGH)
            UART_RX_IN = (^data);
            #(2*135*32);  
            UART_RX_IN = 1;
            #(2*135*32);  // 1 bit time

        end
    endtask
    
    task send_uart_data_odd;
        input [7:0] data;
        integer i;
        begin
            // Start bit (LOW)
            UART_RX_IN = 0;
            $display ("%d",prescale);
            #(2*135*32);  // 1 bit time (9600 baud rate ~104us)

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                UART_RX_IN = data[i];
                #(2*135*32);  // 1 bit time
            end

            // Stop bit (HIGH)
            UART_RX_IN = !(^data);
            #(2*135*32);  
            UART_RX_IN = 1;
            #(2*135*32);  // 1 bit time

        end
    endtask
    reg [8:0] gener_out_par;
    task check_out_parity;
       integer x;
       input [8:0] expect_out;
       input integer oper_num;
       begin
           if (z==0) begin
              #(20*135*32);
           end
           @(negedge UART_TX_O);
           #(135*32);
           for (x=0;x<9;x=x+1) begin
               #(2*135*32)
               gener_out_par[x] = UART_TX_O;
               $display(" %b %b",gener_out_par[x], x); 
               
           end 
       
           if (gener_out_par == expect_out) begin
               $display("Test case %d has succeeded",oper_num);
               $display(" %b , %b",gener_out_par,expect_out); 
           end 
           else begin
               $display("Test case %d has failed",oper_num);
               $display(" %b , %b",gener_out_par,expect_out);
           end
       end
  endtask
    // Monitor Outputs

endmodule
