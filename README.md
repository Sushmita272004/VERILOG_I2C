# I2C_Verilog
# Introduction : 
* This project implements the Inter-Integrated Circuit(I2C) protocol using Verilog HDL. 
* It includes both Master and Slave modules with proper handshaking and data transmission.
* Designed to work in simulation and can be extended to FPGA-based implementation.
# Features :
* Implements I2C Master and Slave Communication.
* Supports Start and Stop conditions, Addressing, Read/Write operations and Acknowledgement.
* Uses Serial Data and Serial Clock lines with correct timing rules.
* Simulated and verified using iverilog and GTKwave.
# I2C Communication Protocol Implementation :
* Start Condition: Master pulls SDA low while SCL is high.
* Address Phase: Master sends a 7-bit address followed by a Read/Write bit.
* ACK/NACK: Slave acknowledges if the address matches and slave is not busy by pulling SDA low.
* Data Transfer: Data is sent/received bit-by-bit with clock synchronisation.
* Stop Condition: Master releases SDA high while SCL is high.
