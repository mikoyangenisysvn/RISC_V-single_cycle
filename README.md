# RV32I Single-Cycle RISC-V Core

A single-cycle implementation of the RV32I base integer instruction set, written in Verilog as part of the VNChip talent-program lab curriculum (Lab 6). This core forms the baseline that was later converted into a 5-stage pipelined design (Lab 7).

## Overview

This project implements a working single-cycle RISC-V datapath and control unit capable of executing the RV32I instruction set: arithmetic/logic instructions (R-type and I-type), loads and stores, branches, and jumps (JAL/JALR), plus LUI/AUIPC.

The design follows the classic single-cycle RISC-V organization: one instruction is fetched, decoded, executed, memory-accessed, and written back within a single clock cycle, using combinational control logic driven by the opcode/funct3/funct7 fields.

## Architecture

**Datapath modules**
- `Program_Counter` — PC register with synchronous reset
- `Instruction_Memory` — word-addressed instruction ROM
- `RegisterFile` — 32×32-bit register file, x0 hardwired to zero, synchronous write / combinational read
- `Immediate_Generator` — produces I/S/B/U/J-type sign-extended immediates from the instruction fields
- `ALU` — 11 operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, and a PASS_B pass-through operand used for LUI)
- `Branch_Comp` — computes equality and less-than (signed/unsigned) for branch resolution
- `Data_Memory` — word-addressed data RAM

**Control modules**
- `main_decoder` — opcode-level control signals: `RegWEn`, `ImmSel`, `ASel`/`BSel` (ALU operand muxing), `MemRW`, `WBSel`, and `Branch`/`Jump`/`Jalr` flags
- `ALU_decoder` — maps opcode/funct3/funct7[5] to the ALU operation select
- `control_unit` — top-level control: wires the two decoders together, derives `BrUn` (unsigned branch), evaluates the branch condition from `funct3`, and computes `PCSel` (next-PC mux select) for taken branches and unconditional jumps

**Top level**
- `RISCv_Single_Cycle` — instantiates and wires all of the above into the complete single-cycle core, including the PC+4 / branch-target / JALR-target next-PC mux and the write-back data mux (ALU result / memory read / PC+4)

## Design notes / fixes applied during development

- **SLTU/SLTIU correctness**: both the ALU and the ALU decoder originally lacked a distinct unsigned set-less-than path, so unsigned compares were silently computed as signed. Added a dedicated `SLTU_OP` in the ALU and corrected the decoder's `funct3` mapping for SLTU (R-type) and SLTIU (I-type).
- **LUI correctness**: added an ALU `PASS_B` operation so LUI writes the immediate through untouched, rather than relying on operand A being architecturally guaranteed to be zero (which depended on whatever `RegisterFile` happened to return for `Inst[19:15]`).
- **Instruction memory addressing**: the byte-to-word address shift for instruction fetch is done at the top level (`Addr_instr_mem`), not inside `Instruction_Memory`, to keep the memory module itself word-addressed and reusable.
- **Branch/jump target computation**: `ASel` selects `PC_out` (not `PC_Plus4`) as ALU operand A for branch/jump target address calculation.

## Verification

The design is verified with a self-checking testbench (`tb_RISCv_Single_Cycle`) that:
- Loads a hex program/data image via `$readmemh` into instruction and data memory
- Runs the core until a designated result word in data memory is written (with a cycle-count timeout guard)
- Checks the result word against an expected pass code
- Dumps the full 32-entry architectural register file (hex / unsigned decimal / signed decimal / binary) for debugging
- Reports a final PASS/FAIL summary

## Status

This design is complete and verified. It was subsequently used as the reusable RTL baseline for a 5-stage pipelined (IF/ID/EX/MEM/WB) conversion of this same core.

## Tools

Simulated with Cadence Xcelium (`xrun`) / `make run` flow as provided by the VNChip lab environment.
