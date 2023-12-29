`timescale 1ns / 1ps

module cdb #( parameter FUNCTIONAL_UNITS = 2 ) (
        input logic clk,

        output logic broadcast,
        output logic [2:0] rs,
        output logic [63:0] data,
        
        input logic available_units [FUNCTIONAL_UNITS - 1:0],
        input logic [63:0] results [FUNCTIONAL_UNITS - 1:0],
        input logic [2:0] rss [FUNCTIONAL_UNITS - 1:0],
        output logic ack [FUNCTIONAL_UNITS - 1:0]
    );
    
    logic has_available_unit;
    logic [$clog2(FUNCTIONAL_UNITS) - 1:0] next_unit;

    always_comb begin
        for (int i = 0; i < FUNCTIONAL_UNITS; i++) ack[i] = 1'b0;
        
        next_unit = 0;
        has_available_unit = 0;
        
        for (int i = FUNCTIONAL_UNITS - 1; i >= 0; i--) begin
            if (available_units[i]) begin 
                next_unit = i;
                has_available_unit = 1;
            end
        end
        
        ack[next_unit] = 1'b1;
        
        rs = rss[next_unit];
        data = results[next_unit];
        broadcast = has_available_unit;
    end
endmodule
