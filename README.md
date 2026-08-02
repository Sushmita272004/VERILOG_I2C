# I2C Verilog Master–Slave Simulation

A Verilog HDL project that models the structure of an I²C master, an addressed I²C slave, and a simulation testbench. The design uses shared, tri-state `SDA` wiring and produces a VCD waveform that can be inspected in GTKWave.

> **Project status:** educational / work in progress. The repository provides a useful starting point for an I²C finite-state-machine design and simulation flow. It is **not yet a protocol-complete I²C controller**; see [Current limitations](#current-limitations) before using it for FPGA hardware or relying on it as an I²C compliance implementation.

## Contents

```text
.
├── I2C_masterfinal.v  # Master finite-state-machine model
├── I2C_slavefinal.v   # Slave address/data receiver model
├── I2C_testfinal.v    # Simulation testbench and VCD generation
└── README.md
```

## Implemented design elements

- Master control states for idle, start, address, acknowledge, data, and stop phases.
- A configurable 7-bit master target address input (`addr`) and read/write input (`rw`).
- A slave with the fixed 7-bit address `7'b1010001` (`0x51`).
- Shared bidirectional `SDA` line using Verilog tri-state (`Z`) control.
- Master `busy` output to indicate an active request.
- Slave address comparison, ACK intent, received-data register, and `data_out` output.
- Reset handling for master and slave state registers.
- Self-contained testbench that writes `i2c_waveform.vcd` for GTKWave.
- Console output at the end of simulation, for example `Received Data: 00`.

## Prerequisites

Install the following tools and ensure their commands are available in your terminal:

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) — compilation and simulation (`iverilog`, `vvp`)
- [GTKWave](https://gtkwave.sourceforge.net/) — optional VCD waveform viewer (`gtkwave`)

## Run the simulation

Open PowerShell in the directory containing the Verilog files, then run:

```powershell
iverilog -g2012 -o i2c_sim.vvp I2C_testfinal.v I2C_masterfinal.v I2C_slavefinal.v
vvp .\i2c_sim.vvp
```

Expected console output includes:

```text
VCD info: dumpfile i2c_waveform.vcd opened for output.
Received Data: 00
```

The simulation creates these generated files:

```text
i2c_sim.vvp        # compiled Icarus Verilog simulation
i2c_waveform.vcd   # waveform database
```

## View the waveform

After running the simulation:

```powershell
gtkwave .\i2c_waveform.vcd
```

In GTKWave, add and inspect at least:

```text
clk, rst, start, busy, scl, sda, addr[6:0], data[7:0], received_data[7:0]
```

Use **View → Zoom → Zoom Full** to display the complete simulation interval. The testbench declares `` `timescale 1ms/1ns``, so the waveform may initially appear empty if GTKWave is zoomed into only the first few nanoseconds.

## Module interfaces

### `i2c_master`

| Signal | Direction | Description |
|---|---|---|
| `clk` | input | System clock driving the master FSM. |
| `rst` | input | Active-high asynchronous reset. |
| `start` | input | Requests a transaction from the idle state. |
| `addr[6:0]` | input | Target 7-bit I²C address. |
| `rw` | input | Read/write bit (`0` = write, `1` = read). |
| `data[7:0]` | input | Data value supplied to the master. |
| `scl` | output | I²C clock line driven by the master model. |
| `sda` | inout | Shared I²C serial-data line. |
| `busy` | output | Indicates that the master is processing a request. |

### `i2c_slave`

| Signal | Direction | Description |
|---|---|---|
| `clk` | input | Declared system-clock input (not currently used by the slave FSM). |
| `rst` | input | Active-high asynchronous reset. |
| `scl` | input | I²C clock used to trigger slave sampling. |
| `sda` | inout | Shared I²C serial-data line. |
| `data_out[7:0]` | output | Captured slave receive register. |
| `ack_out` | output | Indicates that the slave has asserted an ACK. |

## Testbench configuration

`I2C_testfinal.v` instantiates one master and one slave. It uses:

| Setting | Value |
|---|---|
| Slave address | `7'b1010001` (`0x51`) |
| Transaction address | `7'b1010001` (`0x51`) |
| Read/write input | `0` (write) |
| Input data | `8'h00` |
| Reset | Asserted initially, then de-asserted |
| Waveform output | `i2c_waveform.vcd` |

## Current limitations

The current source should be treated as a behavioural scaffold, not a finished I²C implementation:

- `scl` is initialized high but is not toggled by the master. Consequently, the slave FSM—which is sensitive to `negedge scl`—does not receive a complete clocked I²C transaction.
- The master loads address and data registers but does not shift and transmit all eight bits across SCL cycles.
- The master releases `SDA` for acknowledgement but does not sample or validate the slave ACK.
- Read transfers (`rw = 1`) are not implemented; the `rw` bit is only included when loading the address byte.
- Open-drain pull-up behavior is not explicitly modelled. A complete model should use pull-ups and only actively drive `SDA`/`SCL` low.
- The testbench’s comment labels `#10` as a 10 ns period, but under `` `timescale 1ms/1ns`` it represents 10 ms per half-cycle. Update the timescale or comment if nanosecond timing is intended.
- There are no automated assertions or self-checking pass/fail criteria.

## Recommended next improvements

1. Add an SCL clock-divider/enable and generate SCL low/high phases.
2. Shift one address/data bit per SCL cycle, MSB first.
3. Sample the ACK bit during the ninth SCL clock and report NACKs.
4. Add complete read-path support, including master ACK/NACK after received bytes.
5. Model open-drain lines with pull-ups and add protocol assertions.
6. Add test cases for matching/mismatching addresses, write data, read data, ACK, and NACK behavior.

## Git hygiene

Generated simulator and waveform files should not be committed. Add this to `.gitignore`:

```gitignore
*.vvp
*.vcd
*.gtkw
```

## License

No license file is currently included. Add a license (for example, MIT) before distributing the project if you want to define reuse permissions.
