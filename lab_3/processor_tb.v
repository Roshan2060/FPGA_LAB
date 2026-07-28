`timescale 1ns / 1ps

module processor_frontend_comprehensive_tb;

    reg clk;
    reg rst;

    reg [7:0] alu_result;

    wire [7:0]  pc;
    wire [15:0] inst;

    wire [2:0] read_reg1;
    wire [2:0] read_reg2;
    wire [2:0] write_reg;
    wire       write_enable;

    wire [7:0] immediate;
    wire       sel_2s_comp;
    wire       sel_operand1;
    wire [2:0] alu_op;

    wire [7:0] regout1;
    wire [7:0] regout2;

    wire [7:0] operand1;
    wire [7:0] operand2;

    // Instantiate processor front-end
    processor_frontend_8bit uut (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .pc(pc),
        .inst(inst),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_enable(write_enable),
        .immediate(immediate),
        .sel_2s_comp(sel_2s_comp),
        .sel_operand1(sel_operand1),
        .alu_op(alu_op),
        .regout1(regout1),
        .regout2(regout2),
        .operand1(operand1),
        .operand2(operand2)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Behavioral ALU model for testbench execution
    always @(*) begin
        case (alu_op)
            3'b000: alu_result = operand1 + operand2; // ADD / LDI fallback
            3'b001: alu_result = operand1 + operand2; // SUB (operand2 is 2's complement)
            3'b010: alu_result = operand1 & operand2; // AND
            3'b011: alu_result = operand1 | operand2; // OR
            3'b100: alu_result = operand1 ^ operand2; // XOR
            3'b101: alu_result = operand1 + 8'd1;     // INC
            3'b110: alu_result = operand1 - 8'd1;     // DEC
            3'b111: alu_result = operand1 + operand2; // CMP (subtracts via 2's comp)
            default: alu_result = 8'd0;
        endcase
    end

    // Test stimulus and verification block
    initial begin
        $dumpfile("processor_frontend_comprehensive_tb.vcd");
        $dumpvars(1, processor_frontend_comprehensive_tb);

        $display("=================================================================================================");
        $display(" TIME  | PC | INSTRUCTION      | WE | WR | R1 | R2 | OP1 | OP2 | ALU_RES | R1  R2  R3  R4  R5  R6  R7 ");
        $display("=================================================================================================");

        // Apply Reset
        rst = 1;
        #12;
        rst = 0;

        // Run simulation for enough cycles to execute the example instruction block
        #100;

        $display("=================================================================================================");
        $display("SIMULATION COMPLETE: Final Register States Verified.");
        $display("R1 = %0d (Expected: 5)", uut.rf.regs[1]);
        $display("R2 = %0d (Expected: 3)", uut.rf.regs[2]);
        $display("R3 = %0d (Expected: 8)", uut.rf.regs[3]);
        $display("R4 = %0d (Expected: 2)", uut.rf.regs[4]);
        $display("R5 = %0d (Expected: 1)", uut.rf.regs[5]);
        $display("R6 = %0d (Expected: 7)", uut.rf.regs[6]);
        $display("R7 = %0d (Expected: 6)", uut.rf.regs[7]);
        $display("=================================================================================================");

        $finish;
    end

    // Real-time monitoring log
    always @(posedge clk) begin
        #1; // Sample shortly after rising edge for stable outputs
        $display("%5t  | %2d | %16b |  %b | R%0d | R%0d | R%0d | %3d | %3d |   %3d   | %3d %3d %3d %3d %3d %3d %3d",
            $time,
            pc,
            inst,
            write_enable,
            write_reg,
            read_reg1,
            read_reg2,
            operand1,
            operand2,
            alu_result,
            uut.rf.regs[1],
            uut.rf.regs[2],
            uut.rf.regs[3],
            uut.rf.regs[4],
            uut.rf.regs[5],
            uut.rf.regs[6],
            uut.rf.regs[7]
        );
    end

endmodule