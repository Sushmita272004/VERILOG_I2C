`timescale 1ms/1ns

module i2c_tb;

    reg clk, rst, start;
    reg [6:0] addr; // 7-bit I2C address
    reg rw;         // Read (1) or Write (0)
    reg [7:0] data; // Data to send
    wire sda, scl, busy;
    wire [7:0] received_data;

    // Instantiate the I2C Master
    i2c_master master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .addr(addr),
        .rw(rw),
        .scl(scl),
        .sda(sda),
        .busy(busy),
        .data(data)
    );

    // Instantiate the I2C Slave
    i2c_slave slave (
        .clk(clk),
        .rst(rst),
        .scl(scl),
        .sda(sda),
        .data_out(received_data)
    );

    // Clock Generation
    always #10 clk = ~clk; // 10ns period (100MHz clock)

    // Simulation Process
    initial begin
        // Open VCD file for GTKWave
        $dumpfile("i2c_waveform.vcd"); 
        $dumpvars(0, i2c_tb);

        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        addr = 7'b1010001; // Example Slave Address
        rw = 0;            // Write operation
        data = 8'h00;      // Data to send

        #20 rst = 0;  // De-assert reset
        #50 start = 1; // Start I2C transaction
        #20 start = 0;

        // Wait for transaction to complete
        wait (busy == 0);
        
        #100; // Hold for some time
        $display("Received Data: %h",received_data);
        $finish;
    end

endmodule