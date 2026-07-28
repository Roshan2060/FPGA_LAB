# 8-Bit Processor Front-End Design and Simulation Using Verilog HDL

| Details | Information |
|---|---|
| **Student Name** | Roshan Bhatt |
| **Roll Number** | THA079BEI033 |
| **Assignment** | Assignment 3 – Implement 8-Bit Processor Front-End in Verilog |
| **Tools Used** | Icarus Verilog and GTKWave |
| **Design Type** | Sequential + Combinational Logic (Instruction Memory, Control Unit, Register File) |

---

## 1. Objective

The objective of this assignment is to design, simulate, and verify the **front-end of an 8-bit processor** using Verilog HDL.

The front-end fetches instructions from an instruction memory, decodes them using a control unit, reads operands from a register file, and prepares operands for an external ALU. The design is verified using a self-contained testbench with a behavioral ALU model and register-state tracking.

---

## 2. Introduction

A processor front-end is the part of a CPU responsible for **fetching and decoding instructions** and **preparing operands** before execution. It typically consists of:

- An **Instruction Memory** that stores the program
- A **Control Unit** that decodes instructions and generates control signals
- A **Register File** that stores and supplies operand data
- Operand-selection logic that prepares data for the ALU

In this assignment, a 16-bit instruction format is used with a 4-bit opcode supporting nine operations: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `INC`, `DEC`, `CMP`, and `LDI`, plus a `NOP` (no operation).

The design does not include the ALU itself — the `alu_result` and `alu_op` signals are the interface points where an external ALU module would be connected. In the testbench, a simple behavioral ALU model is used to emulate this connection so the full fetch–decode–execute–writeback path can be exercised.

---

## 3. Project Folder Structure

```text
REPORT_3/
│
├── processor_frontend.v                     # Instruction memory, control unit, register file, top module
├── processor_frontend_comprehensive_tb.v     # Testbench with behavioral ALU and register tracking
├── processor_frontend_comprehensive_tb.vcd   # Generated waveform file
├── sim                                       # Compiled simulation output
│
└── Assignment documentation
```

---

### Signal Flow

```text
                 ┌────────────────────┐
   PC ─────────► │ Instruction Memory │
                 └─────────┬──────────┘
                           │ inst[15:0]
                           ▼
                 ┌────────────────────┐
                 │    Control Unit    │
                 └─────────┬──────────┘
        read_reg1/2, write_reg, write_enable,
        immediate, sel_2s_comp, sel_operand1, alu_op
                           │
                           ▼
                 ┌────────────────────┐
                 │    Register File   │
                 └─────────┬──────────┘
                   regout1 │ regout2
                           ▼
              Operand selection + 2's complement
                           │
                           ▼
                 operand1, operand2 ───► (External ALU)
                                              │
                                        alu_result
                                              │
                                              ▼
                                  Written back to Register File
```

---

## 4. Module Overview

| Module | Description |
|---|---|
| `instruction_memory` | 256 × 16-bit ROM preloaded with a sample program. Combinationally outputs the instruction at the current PC. |
| `control_unit` | Contains the Program Counter (PC) register and the instruction decoder. Generates all register-file and datapath control signals. |
| `register_file_8x8` | 8 registers, each 8 bits wide. Two asynchronous read ports and one synchronous write port. |
| `processor_frontend_8bit` | Top-level module. Connects instruction memory, control unit, and register file, and prepares `operand1`/`operand2` for the external ALU. |

---

## 5. Input and Output Ports (Top Module: `processor_frontend_8bit`)

| Signal | Width | Direction | Description |
|---|---:|---|---|
| `clk` | 1-bit | Input | System clock |
| `rst` | 1-bit | Input | Synchronous-style reset (asserted high) |
| `alu_result` | 8-bit | Input | Result computed by the external ALU, written back to the register file |
| `pc` | 8-bit | Output | Current program counter value |
| `inst` | 16-bit | Output | Instruction fetched from instruction memory |
| `read_reg1`, `read_reg2` | 3-bit | Output | Register file read-address selects |
| `write_reg` | 3-bit | Output | Register file write-address select |
| `write_enable` | 1-bit | Output | Enables writing to the register file |
| `immediate` | 8-bit | Output | Immediate value extracted from the instruction |
| `sel_2s_comp` | 1-bit | Output | Selects two's-complement of `regout2` for subtraction/compare |
| `sel_operand1` | 1-bit | Output | Selects `immediate` instead of `regout1` (used for `LDI`) |
| `alu_op` | 3-bit | Output | Operation code sent to the external ALU |
| `regout1`, `regout2` | 8-bit | Output | Raw register file read data |
| `operand1`, `operand2` | 8-bit | Output | Final operands sent to the ALU |

---

## 6. Instruction Format

Each instruction is 16 bits wide:

```text
 15            12 11     9  8      6  5      3  2         0
┌────────────────┬─────────┬────────┬────────┬────────────┐
│     opcode      │ write_reg │ read_reg1 │ read_reg2 │  unused/imm │
└────────────────┴─────────┴────────┴────────┴────────────┘
```

For arithmetic/logic instructions, bits `[8:6]` and `[5:3]` select the two source registers.
For `LDI`, bits `[7:0]` hold the 8-bit immediate value instead of two register selects.

---

## 7. Opcode Table

| Opcode (`inst[15:12]`) | Mnemonic | `alu_op` | Operation | `write_enable` |
|---|---|---|---|---:|
| `0000` | `ADD` | `000` | `R_write = R1 + R2` | 1 |
| `0001` | `SUB` | `001` | `R_write = R1 - R2` (via 2's complement) | 1 |
| `0010` | `AND` | `010` | `R_write = R1 & R2` | 1 |
| `0011` | `OR`  | `011` | `R_write = R1 \| R2` | 1 |
| `0100` | `XOR` | `100` | `R_write = R1 ^ R2` | 1 |
| `0101` | `INC` | `101` | `R_write = R1 + 1` | 1 |
| `0110` | `DEC` | `110` | `R_write = R1 - 1` | 1 |
| `0111` | `CMP` | `111` | Compares `R1` and `R2` (2's complement); no writeback | 0 |
| `1000` | `LDI` | `000` | `R_write = immediate` | 1 |
| `1111` | `NOP` | — | No operation | 0 |

---

## 8. Sample Program (Preloaded in Instruction Memory)

| Address | Instruction | Meaning |
|---:|---|---|
| 0 | `LDI R1, 5` | `R1 = 5` |
| 1 | `LDI R2, 3` | `R2 = 3` |
| 2 | `ADD R3, R1, R2` | `R3 = R1 + R2 = 8` |
| 3 | `SUB R4, R1, R2` | `R4 = R1 - R2 = 2` |
| 4 | `AND R5, R1, R2` | `R5 = R1 & R2 = 1` |
| 5 | `OR R6, R1, R2` | `R6 = R1 \| R2 = 7` |
| 6 | `XOR R7, R1, R2` | `R7 = R1 ^ R2 = 6` |
| 7–255 | `NOP` | No operation (default fill) |

---

## 9. Design Methodology

### 9.1 Instruction Memory

Implemented as a 256-entry array of 16-bit registers, initialized in an `initial` block. All locations default to `NOP`, and the sample program is written into the first seven addresses. Fetch is purely combinational:

```verilog
assign inst = memory[pc];
```

### 9.2 Control Unit

Contains the **Program Counter**, updated synchronously every clock edge:

```verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 8'd0;
    else
        pc <= pc + 8'd1;
end
```

Instruction decoding is combinational, using a `case` statement on `inst[15:12]` to set `alu_op`, `write_enable`, `sel_2s_comp`, and `sel_operand1`. Default values are assigned before the `case` block to avoid unintended latch inference.

### 9.3 Register File

8 registers of 8 bits each, with **asynchronous reads**:

```verilog
assign regout1 = regs[read_reg1];
assign regout2 = regs[read_reg2];
```

and a **synchronous write**, gated by `write_enable`:

```verilog
always @(posedge clk or posedge rst) begin
    if (rst)
        for (i = 0; i < 8; i = i + 1) regs[i] <= 8'd0;
    else if (write_enable)
        regs[write_reg] <= write_data;
end
```

### 9.4 Operand Preparation (Top Module)

- A dedicated two's-complement unit computes `regout2_2s_comp = (~regout2) + 1`.
- `operand1` is chosen between `regout1` and `immediate` based on `sel_operand1` (used for `LDI`).
- `operand2` is chosen between `regout2` and its two's complement based on `sel_2s_comp` (used for `SUB`/`CMP`).
- The register write-back data is chosen between `immediate` (for `LDI`) and the external `alu_result` (for all other write-enabled instructions).

```verilog
assign operand1 = (sel_operand1) ? immediate : regout1;
assign operand2 = (sel_2s_comp)  ? regout2_2s_comp : regout2;
assign register_write_data = (inst[15:12] == OP_LDI) ? immediate : alu_result;
```

---

## 10. Testbench Description

The file `processor_frontend_comprehensive_tb.v` verifies the design end-to-end:

1. Instantiates `processor_frontend_8bit` as the unit under test (`uut`).
2. Generates a 10 ns-period clock (`#5` half-period toggling).
3. Applies an active-high reset for 12 ns, then releases it so the program counter starts incrementing and the sample program executes.
4. Implements a **behavioral ALU model** in an `always @(*)` block that reacts to `alu_op`, `operand1`, and `operand2`, mimicking the external ALU that the front-end is designed to interface with.
5. Logs a formatted trace on every rising clock edge, showing time, PC, instruction, control signals, operands, ALU result, and the live contents of registers `R1`–`R7`.
6. After 100 ns of simulation, prints the final contents of `R1`–`R7` alongside the expected values for manual verification.
7. Dumps waveform data to `processor_frontend_comprehensive_tb.vcd` for GTKWave viewing.

```verilog
$dumpfile("processor_frontend_comprehensive_tb.vcd");
$dumpvars(1, processor_frontend_comprehensive_tb);
```

---

## 11. Expected Final Register States

| Register | Expected Value | Source Instruction |
|---|---:|---|
| `R1` | 5 | `LDI R1, 5` |
| `R2` | 3 | `LDI R2, 3` |
| `R3` | 8 | `ADD R3, R1, R2` |
| `R4` | 2 | `SUB R4, R1, R2` |
| `R5` | 1 | `AND R5, R1, R2` |
| `R6` | 7 | `OR R6, R1, R2` |
| `R7` | 6 | `XOR R7, R1, R2` |

These values are printed by the testbench at the end of simulation and should be checked against the console output.

---

## 12. Simulation Procedure

### Step 1: Compile the Verilog Files

```bash
iverilog -o frontend_sim processor_frontend.v processor_frontend_comprehensive_tb.v
```

| Command Part | Meaning |
|---|---|
| `iverilog` | Icarus Verilog compiler |
| `-o frontend_sim` | Creates simulation output named `frontend_sim` |
| `processor_frontend.v` | Instruction memory, control unit, register file, top module |
| `processor_frontend_comprehensive_tb.v` | Testbench file |

### Step 2: Run the Simulation

```bash
vvp frontend_sim
```

The terminal prints a cycle-by-cycle trace followed by the final register-state summary.

### Step 3: View Waveform in GTKWave

```bash
gtkwave processor_frontend_comprehensive_tb.vcd
```

Recommended signals to add to the waveform window:

```text
clk
rst
pc
inst[15:0]
read_reg1[2:0]
read_reg2[2:0]
write_reg[2:0]
write_enable
alu_op[2:0]
operand1[7:0]
operand2[7:0]
alu_result[7:0]
```

---

## 13. Important Verilog Concepts Used

### Module Hierarchy

The design demonstrates hierarchical composition, with `processor_frontend_8bit` instantiating `instruction_memory`, `control_unit`, and `register_file_8x8` as sub-modules.

### `localparam`

Opcodes are defined as named constants for readability instead of magic numbers:

```verilog
localparam OP_ADD = 4'b0000;
localparam OP_LDI = 4'b1000;
```

### Combinational vs. Sequential Logic

- **Combinational**: instruction fetch (`assign inst = memory[pc];`) and instruction decode (`always @(*)`).
- **Sequential**: the program counter and register file writes, both using `always @(posedge clk or posedge rst)`.

### Memory Modeling with `reg` Arrays

The instruction memory and register file are modeled as arrays of `reg`:

```verilog
reg [15:0] memory [0:255];
reg [7:0]  regs   [0:7];
```

### Ternary Operators for Multiplexers

Operand selection and write-back data selection use conditional (`? :`) expressions to implement 2-to-1 multiplexers:

```verilog
assign operand1 = (sel_operand1) ? immediate : regout1;
```

### Two's Complement Subtraction

Rather than a dedicated subtractor, `SUB` and `CMP` reuse the adder by feeding it the two's complement of the second operand:

```verilog
assign regout2_2s_comp = (~regout2) + 8'd1;
```

### Behavioral Modeling in the Testbench

The testbench's ALU model uses a `case` statement inside an `always @(*)` block purely for simulation purposes, standing in for a real synthesizable ALU module.

---

## 14. Result

Simulation confirms that the processor front-end correctly:

- Fetches instructions sequentially from instruction memory as the PC increments
- Decodes opcodes into the correct control signals (`alu_op`, `write_enable`, `sel_2s_comp`, `sel_operand1`)
- Reads the correct source registers and forwards the correct operands to the ALU interface
- Handles the `LDI` immediate-load path separately from register-to-register operations
- Writes back computed results (or immediates) into the correct destination register on the next clock edge

All final register values (`R1`–`R7`) matched their expected results after running the sample program.

---

## 15. Conclusion

The front-end of an 8-bit processor — instruction memory, control unit, and register file — was successfully designed and simulated using Verilog HDL. The design correctly fetches, decodes, and prepares operands for nine instruction types, and interfaces cleanly with an external ALU through the `operand1`, `operand2`, `alu_op`, and `alu_result` signals.

This assignment provided practical understanding of:

- Multi-module hierarchical design in Verilog
- Separating combinational decode logic from sequential state (PC, registers)
- Instruction encoding and opcode-based control signal generation
- Building a register file with asynchronous reads and synchronous writes
- Writing a self-contained testbench with a behavioral model standing in for an unbuilt module
- Waveform-based functional verification using Icarus Verilog and GTKWave