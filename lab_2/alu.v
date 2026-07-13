// ============================================================
// 8-bit Arithmetic Logic Unit (ALU)
// ============================================================


module alu_8bit(
    input [7:0] A ,// first 8-bit input 
    input [7:0] B, // second 8-bit input 
    input[2:0] sel, // selection line 

    output reg [7:0] result, // 8-bit ALU output
    output reg       carry,  // Carry / borrow / shifted-out bit
    output reg       zero    // Zero flag
);

// here we will implement the combinational logic for the ALU

always @(*) begin
    // Default values prevent latch generation
        result = 8'b00000000;
        carry  = 1'b0;
        zero   = 1'b0;


        case(sel)
                    // ------------------------------------------------
            // 000: Addition
            // result = A + B
            // carry stores the 9th bit of the addition result
            // ------------------------------------------------
            3'b000:begin
                {carry,result} = A+B ; 
            end
            // ------------------------------------------------
            // 001: Subtraction
            // result = A - B
            // carry = 1 means borrow occurred, i.e., A < B
            // ------------------------------------------------
            3'b001:begin
                result = A-B;
                if(A<B) carry =1'b1; //carry 1
                else carry = 1'b0;   // carry 0
            end
            // ------------------------------------------------
            // 010: Bitwise AND
            // ------------------------------------------------
            3'b010:begin
                result = A & B;
            end

            // ------------------------------------------------
            // 011: Bitwise OR
            // ------------------------------------------------
            3'b011:begin
                result = A|B;
            end
            // ------------------------------------------------
            // 100: Bitwise XOR
            // ------------------------------------------------
            
            3'b100:begin
                result = A ^ B;
            end

            // ------------------------------------------------
            // 101: Bitwise AND of A
            // B is not used in this operation 
            // ------------------------------------------------
            3'b101:begin 
                result =~A;
            end
            // ------------------------------------------------
            // 110: Logical left shift of A by one bit
            // A[7] is shifted out and stored in carry
            // ------------------------------------------------
            3'b110: begin
                result = A << 1;
                carry  = A[7];
            end

            // ------------------------------------------------
            // 111: Logical right shift of A by one bit
            // A[0] is shifted out and stored in carry
            // ------------------------------------------------
            3'b111: begin
                result = A >> 1;
                carry  = A[0];
            end
        
         // Default case for safety
            default: begin
                result = 8'b00000000;
                carry  = 1'b0;
            end

        endcase

        // ----------------------------------------------------
        // Zero flag generation
        // zero = 1 when result is exactly 00000000
        // ----------------------------------------------------
        if (result == 8'b00000000)
            zero = 1'b1;
        else
            zero = 1'b0;

    end

endmodule 