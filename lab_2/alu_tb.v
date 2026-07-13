`timescale 1ns / 1ps

module alu_8bit_tb;

    // Inputs (declared as reg)
    reg [7:0] A;
    reg [7:0] B;
    reg [2:0] sel;

    // Outputs (declared as wire)
    wire [7:0] result;
    wire       carry;
    wire       zero;

    // Instantiate the Unit Under Test (UUT)
    alu_8bit uut (
        .A(A), 
        .B(B), 
        .sel(sel), 
        .result(result), 
        .carry(carry), 
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_8bit.vcd");
        $dumpvars(1, alu_8bit_tb);
        // Initialize signals
        A = 0; B = 0; sel = 0;

        // Monitor changes in values and print to console
        $monitor("Time=%0t | A=%h B=%h sel=%b | Res=%h Cry=%b Zero=%b", 
                 $time, A, B, sel, result, carry, zero);

        // --- Apply Test Cases ---
        #10 A = 8'h05; B = 8'h03; sel = 3'b000; // Addition
        #10 A = 8'h0A; B = 8'h04; sel = 3'b001; // Subtraction
        #10 A = 8'hAA; B = 8'h0F; sel = 3'b010; // AND
        #10 A = 8'h91; B = 8'h00; sel = 3'b110; // Left Shift
        
        #10 $finish; // End simulation
    end

endmodule