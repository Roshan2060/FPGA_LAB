`timescale 1ns/1ps
module mux_n_to_1 #(
    parameter NUM_INPUTS = 4,
    parameter SEL_WIDTH  = $clog2(NUM_INPUTS)
)(
    input  [NUM_INPUTS-1:0] data, 
    input  [SEL_WIDTH-1:0]sel,
    output reg out
);
     integer i;

    always @(*) begin
    
        out = 1'bx;
        
        for(i=0;i<NUM_INPUTS;i=i+1)
            if(sel == i) out= data[i];
    
    end
endmodule