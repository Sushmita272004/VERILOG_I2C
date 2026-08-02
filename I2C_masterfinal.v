module i2c_master (
    input wire clk,         // System clock
    input wire rst,         // Reset
    input wire start,       // Start signal
    input wire [7:0] data,  // Data to send
    input wire [6:0] addr,  // Slave address
    input wire rw,          // Read (1) / Write (0)
    output reg scl,         // Clock signal
    inout wire sda,         // Bidirectional data line
    output reg busy         // Indicates if I2C is busy
);

    reg [3:0] state;
    reg [7:0] shift_reg;
    reg sda_out;
    reg sda_en;  // Controls SDA as output

    assign sda = (sda_en) ? sda_out : 1'bz; // Tri-state buffer for bidirectional line

    // I2C states
    localparam IDLE = 0, START = 1, ADDRESS = 2, ACK = 3, DATA = 4, STOP = 5;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            scl <= 1;
            sda_out <= 1;
            sda_en <= 0;
            busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= START;
                        busy <= 1;
                        //scl<=~scl; #5;
                    end
                end
                START: begin
                    sda_out <= 0; // Start condition: SDA low while SCL is high
                    sda_en <= 1;
                    state <= ADDRESS;
                end
                ADDRESS: begin
                    shift_reg <= {addr, rw}; // Load address and R/W bit
                    sda_out <= shift_reg[7]; // Send MSB first
                    state <= ACK;
                end
                ACK: begin
                    sda_en <= 0; // Release SDA for slave ACK
                    state <= DATA;
                end
                DATA: begin
                    shift_reg <= data;
                    sda_out <= shift_reg[7];
                    sda_en <= 1;
                    state <= STOP;
                end
                STOP: begin
                    sda_out <= 1; // Stop condition: SDA goes high while SCL is high
                    sda_en <= 0;
                    state <= IDLE;
                    busy <= 0;
                end
            endcase
        end
    end
endmodule