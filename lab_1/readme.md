Roshan Bhatt (THA079BEI033)
N-to-1 Multiplexer
This project contains a flexible, parameterized N-to-1 Multiplexer implemented in Verilog, designed for easy scaling.

How it Works
Parameterized Design: The NUM_INPUTS parameter allows the Mux to scale automatically. The required number of selection bits is calculated using $clog2(NUM_INPUTS).

Logic Implementation: The design uses a for loop inside an always @(*) block. It checks every input; when the sel value matches the loop index, that specific data bit is routed to the output.

Testbench Features
Reusable Task: A custom check task is used to apply test stimuli and verify results, keeping the code efficient and easy to read.

Automated Reporting: The testbench maintains a pass_count and fail_count, providing a clear summary report in the console after simulation.