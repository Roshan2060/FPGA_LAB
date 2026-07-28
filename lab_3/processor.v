`timescale 1ns / 1ps

// ======================================================
// 1. Instruction Memory
// ======================================================

module instruction_memory(
    input  wire [7:0]  pc,
    output wire [15:0] inst
);

    reg [15:0] memory [0:255];
    integer i;

    // Opcode definitions
    localparam OP_ADD = 4'b0000;
    localparam OP_SUB = 4'b0001;
    localparam OP_AND = 4'b0010;
    localparam OP_OR  = 4'b0011;
    localparam OP_XOR = 4'b0100;
    localparam OP_INC = 4'b0101;
    localparam OP_DEC = 4'b0110;
    localparam OP_CMP = 4'b0111;
    localparam OP_LDI = 4'b1000;
    localparam OP_NOP = 4'b1111;

    initial begin
        // Default all memory locations as NOP
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = {OP_NOP, 12'b0};
        end

        // Example program

        // LDI R1, 5
        // Format: opcode, write_reg, unused, immediate
        memory[0] = {OP_LDI, 3'd1, 1'b0, 8'd5};

        // LDI R2, 3
        memory[1] = {OP_LDI, 3'd2, 1'b0, 8'd3};

        // ADD R3, R1, R2
        // R3 = R1 + R2
        memory[2] = {OP_ADD, 3'd3, 3'd1, 3'd2, 3'b000};

        // SUB R4, R1, R2
        // R4 = R1 - R2
        memory[3] = {OP_SUB, 3'd4, 3'd1, 3'd2, 3'b000};

        // AND R5, R1, R2
        memory[4] = {OP_AND, 3'd5, 3'd1, 3'd2, 3'b000};

        // OR R6, R1, R2
        memory[5] = {OP_OR, 3'd6, 3'd1, 3'd2, 3'b000};

        // XOR R7, R1, R2
        memory[6] = {OP_XOR, 3'd7, 3'd1, 3'd2, 3'b000};
    end

    // Instruction output based on current PC
    assign inst = memory[pc];

endmodule


// ======================================================
// 2. Control Unit
// ======================================================

module control_unit(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] inst,

    output reg  [7:0]  pc,

    // Register file controls
    output reg  [2:0]  read_reg1,
    output reg  [2:0]  read_reg2,
    output reg  [2:0]  write_reg,
    output reg         write_enable,

    // Datapath controls
    output reg  [7:0]  immediate,
    output reg         sel_2s_comp,
    output reg         sel_operand1,

    // ALU control
    output reg  [2:0]  alu_op
);

    // Opcode definitions
    localparam OP_ADD = 4'b0000;
    localparam OP_SUB = 4'b0001;
    localparam OP_AND = 4'b0010;
    localparam OP_OR  = 4'b0011;
    localparam OP_XOR = 4'b0100;
    localparam OP_INC = 4'b0101;
    localparam OP_DEC = 4'b0110;
    localparam OP_CMP = 4'b0111;
    localparam OP_LDI = 4'b1000;
    localparam OP_NOP = 4'b1111;

    // Program Counter
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 8'd0;
        else
            pc <= pc + 8'd1;
    end

    // Instruction Decode
    always @(*) begin
        // Default values
        read_reg1     = inst[8:6];
        read_reg2     = inst[5:3];
        write_reg     = inst[11:9];
        immediate     = inst[7:0];

        write_enable  = 1'b0;
        sel_2s_comp   = 1'b0;
        sel_operand1  = 1'b0;
        alu_op        = 3'b000;

        case (inst[15:12])

            OP_ADD: begin
                alu_op       = 3'b000;
                write_enable = 1'b1;
            end

            OP_SUB: begin
                alu_op       = 3'b001;
                sel_2s_comp  = 1'b1;
                write_enable = 1'b1;
            end

            OP_AND: begin
                alu_op       = 3'b010;
                write_enable = 1'b1;
            end

            OP_OR: begin
                alu_op       = 3'b011;
                write_enable = 1'b1;
            end

            OP_XOR: begin
                alu_op       = 3'b100;
                write_enable = 1'b1;
            end

            OP_INC: begin
                alu_op       = 3'b101;
                write_enable = 1'b1;
            end

            OP_DEC: begin
                alu_op       = 3'b110;
                write_enable = 1'b1;
            end

            OP_CMP: begin
                alu_op       = 3'b111;
                sel_2s_comp  = 1'b1;
                write_enable = 1'b0;
            end

            OP_LDI: begin
                // Load immediate into register
                alu_op       = 3'b000;
                sel_operand1 = 1'b1;
                write_enable = 1'b1;

                // Immediate instruction does not need register read
                read_reg1    = 3'd0;
                read_reg2    = 3'd0;
            end

            OP_NOP: begin
                write_enable = 1'b0;
            end

            default: begin
                write_enable = 1'b0;
            end

        endcase
    end

endmodule


// ======================================================
// 3. 8 x 8 Register File
// ======================================================

module register_file_8x8(
    input  wire       clk,
    input  wire       rst,

    input  wire [2:0] read_reg1,
    input  wire [2:0] read_reg2,
    input  wire [2:0] write_reg,

    input  wire [7:0] write_data,
    input  wire       write_enable,

    output wire [7:0] regout1,
    output wire [7:0] regout2
);

    reg [7:0] regs [0:7];
    integer i;

    // Asynchronous read
    assign regout1 = regs[read_reg1];
    assign regout2 = regs[read_reg2];

    // Synchronous write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 8'd0;
            end
        end
        else begin
            if (write_enable) begin
                regs[write_reg] <= write_data;
            end
        end
    end

endmodule


// ======================================================
// 4. Top Module: Control Unit + Instruction Memory + Register File
// ======================================================

module processor_frontend_8bit(
    input  wire       clk,
    input  wire       rst,

    // This will come from ALU later
    input  wire [7:0] alu_result,

    output wire [7:0]  pc,
    output wire [15:0] inst,

    output wire [2:0]  read_reg1,
    output wire [2:0]  read_reg2,
    output wire [2:0]  write_reg,
    output wire        write_enable,

    output wire [7:0]  immediate,
    output wire        sel_2s_comp,
    output wire        sel_operand1,
    output wire [2:0]  alu_op,

    output wire [7:0]  regout1,
    output wire [7:0]  regout2,

    // Outputs going toward ALU
    output wire [7:0]  operand1,
    output wire [7:0]  operand2
);

    localparam OP_LDI = 4'b1000;

    wire [7:0] regout2_2s_comp;
    wire [7:0] register_write_data;

    // Instruction Memory
    instruction_memory imem (
        .pc(pc),
        .inst(inst)
    );

    // Control Unit
    control_unit cu (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .pc(pc),

        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_enable(write_enable),

        .immediate(immediate),
        .sel_2s_comp(sel_2s_comp),
        .sel_operand1(sel_operand1),

        .alu_op(alu_op)
    );

    // 2's complement unit
    assign regout2_2s_comp = (~regout2) + 8'd1;

    // Operand selection
    assign operand1 = (sel_operand1) ? immediate : regout1;
    assign operand2 = (sel_2s_comp)  ? regout2_2s_comp : regout2;

    // For LDI instruction, write immediate directly.
    // For other instructions, write ALU result.
    assign register_write_data = (inst[15:12] == OP_LDI) ? immediate : alu_result;

    // Register File
    register_file_8x8 rf (
        .clk(clk),
        .rst(rst),

        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),

        .write_data(register_write_data),
        .write_enable(write_enable),

        .regout1(regout1),
        .regout2(regout2)
    );

endmodule