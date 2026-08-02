module i2c_slave(
    input wire clk,           // System clock
    input wire rst,           // Reset signal
    input wire scl,           // I2C Clock Line
    inout wire sda,           // I2C Data Line (Bidirectional)
    output reg [7:0] data_out, // Received Data Output
    output reg ack_out        // Acknowledge signal to master
);

    reg [6:0] slave_address = 7'b1010001; // Set your Slave Address
    reg [7:0] received_data;
    reg [3:0] bit_count;       // Bit counter for data reception
    reg sda_out;               // Internal SDA output buffer
    reg sda_en;                // Enable signal for SDA control

    assign sda = (sda_en) ? sda_out : 1'bz; // Tri-state buffer for SDA

    // State Encoding using Parameters
    parameter IDLE          = 3'b000;
    parameter ADDRESS_MATCH = 3'b001;
    parameter ACK_ADDRESS   = 3'b010;
    parameter RECEIVING     = 3'b011;
    parameter ACK_DATA      = 3'b100;

    reg [2:0] state;

    always @(negedge scl or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            received_data <= 8'b0;
            bit_count <= 0;
            sda_en <= 0;
            ack_out <= 0;
            data_out <= 8'b0;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 0;
                    ack_out <= 0;
                    if (sda == 0) // Start condition detected (SDA goes low while SCL is high)
                        state <= ADDRESS_MATCH;
                end

                ADDRESS_MATCH: begin
                    received_data[6:0] <= {received_data[5:0], sda}; // Shift SDA into address buffer
                    bit_count <= bit_count + 1;
                    if (bit_count == 6) // After receiving 7 address bits
                        state <= ACK_ADDRESS;
                end

                ACK_ADDRESS: begin
                    if (received_data[6:0] == slave_address) begin
                        sda_en <= 1;  // Enable SDA to send ACK
                        sda_out <= 0; // Send ACK (pull SDA low)
                        ack_out <= 1; // Indicate ACK sent to master
                        state <= RECEIVING;
                    end else begin
                        state <= IDLE; // Address mismatch, return to IDLE
                    end
                    bit_count <= 0;
                end

                RECEIVING: begin
                    received_data <= {received_data[6:0], sda}; // Shift SDA into received_data
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) // After receiving 8 bits
                        state <= ACK_DATA;
                end

                ACK_DATA: begin
                    sda_en <= 1;  // Enable SDA to send ACK
                    sda_out <= 0; // Send ACK (pull SDA low)
                    ack_out <= 1; // Indicate ACK sent to master
                    data_out <= received_data; // Store received data
                    state <= IDLE; // Go back to IDLE for next transaction
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule