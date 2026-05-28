# 4-Stage Pipelined RISC-V Processor

A 32-bit pipelined RISC-V processor written in Verilog. The core supports R/I/S/B/U/J instruction formats, word-level load/store operations, arithmetic and logic instructions, signed branch instructions, jumps, `LUI`, and `AUIPC`. The processor was verified with custom Verilog testbenches, VCD waveform analysis, instruction-level debug traces, and an assembly bubble-sort program.

## Project Highlights

- 4-stage pipeline: instruction fetch, decode, execute/memory, writeback
- 32 general-purpose registers with `x0` hardwired to zero
- Supports R/I/S/B/U/J immediate formats
- Implements hazard detection, data forwarding, branch flushing, and pipeline stalls
- Runs an assembly bubble-sort test program
- Synthesized using Yosys
- Placement, routing, and timing analysis performed using OpenROAD, OpenSTA, and the Sky130 technology library

## Architecture Overview

The processor is organized into four pipeline stages:

1. **Instruction Fetch**
   - Generates program counter values
   - Interfaces with instruction memory
   - Handles PC update, stall, and branch redirection behavior

2. **Instruction Decode**
   - Decodes opcode, funct3, funct7, source registers, and destination register
   - Reads register file operands
   - Generates immediates for R/I/S/B/U/J instruction formats
   - Produces control signals for later pipeline stages

3. **Execute / Memory**
   - Performs ALU operations
   - Computes branch and jump targets
   - Evaluates branch conditions
   - Interfaces with data memory for word-level loads and stores

4. **Writeback**
   - Selects writeback data from ALU result, data memory, immediate value, or PC+4
   - Writes results back to the register file

## Supported Instructions

### Arithmetic / Logic

- `ADD`, `SUB`
- `AND`, `OR`, `XOR`
- `SLL`, `SRL`, `SRA`
- `SLT`, `SLTU`

### Immediate Arithmetic / Logic

- `ADDI`
- `ANDI`, `ORI`, `XORI`
- `SLLI`, `SRLI`, `SRAI`
- `SLTI`, `SLTIU`

### Memory

- `LW`
- `SW`

### Branch / Jump

- `BEQ`, `BNE`, `BLT`, `BGE`
- `JAL`, `JALR`

### Upper Immediate

- `LUI`
- `AUIPC`

## Current Limitations

- Word-level memory operations only
  - `LW` and `SW` are supported
  - byte and halfword memory operations are not currently implemented
- Unsigned branch instructions are not currently implemented
  - `BLTU` and `BGEU` are not supported yet
- CSR/system instructions are not implemented
  - `ECALL`, `EBREAK`, and CSR instructions are not supported
- Memory timing currently assumes fixed-latency behavior used by the testbench

## Verification

The processor was tested using:

- Custom Verilog testbenches
- Icarus Verilog simulation
- VCD waveform inspection in GTKWave
- Instruction-level debug traces
- Assembly test programs, including a bubble-sort program

## ASIC Flow

The design was synthesized and analyzed using an open-source ASIC flow:

* Yosys for synthesis
* OpenROAD for placement and routing
* OpenSTA for static timing analysis
* Sky130 as the target technology library
* Docker/XQuartz used for the tool environment

## Repository Structure

```text
.
├── src/              # Verilog source files
├── tb/               # Testbenches
├── asm/              # Assembly test programs
├── sim/              # Simulation outputs and scripts
└── README.md
```

Update this section to match your actual repository organization.

## Future Improvements

* Add byte and halfword load/store support
* Add unsigned branch instructions
* Add CSR/system instruction support
* Improve memory interface from handlking one fixed memory latency to handling variable memory latency
* Explore integration with a small matrix multiplication accelerator
* Optimize placement, routing, and sta

