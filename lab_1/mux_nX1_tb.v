`timescale 1ns/1ps

module mux_n_to_1_tb;

    parameter NUM_INPUTS = 4;
    parameter SEL_WIDTH  = $clog2(NUM_INPUTS);

    reg  [NUM_INPUTS-1:0] data;
    reg  [SEL_WIDTH-1:0] sel;
    wire out;

    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    mux_n_to_1 #(
        .NUM_INPUTS(NUM_INPUTS)
    ) uut (
        .data(data),
        .sel(sel),
        .out(out)
    );

    // Generate waveform
    initial begin
        $dumpfile("mux.vcd");
        $dumpvars(1, mux_n_to_1_tb);
    end

    // Reusable task
    task check;
        input [NUM_INPUTS-1:0] test_data;
        input [SEL_WIDTH-1:0] test_sel;
        input expected;

        begin
            data = test_data;
            sel  = test_sel;
            #10;

            if (out === expected) begin
                $display("[PASS] data=%b sel=%0d out=%b",
                          test_data, test_sel, out);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] data=%b sel=%0d out=%b expected=%b",
                          test_data, test_sel, out, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;

        // Test cases
        check(4'b1010, 2'd0, 0);
        check(4'b1010, 2'd1, 1);
        check(4'b1010, 2'd2, 0);
        check(4'b1010, 2'd3, 1);

        check(4'b1111, 2'd0, 1);
        check(4'b0000, 2'd3, 0);

        $display("-----------------------");
        $display("Passed = %0d", pass_count);
        $display("Failed = %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule