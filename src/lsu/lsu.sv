`timescale 1ns / 1ps

import types::*;

module load_unit(
    output [63:0] result
); 
endmodule

module store_unit(
    output [63:0] result
);
endmodule

module lsu (input wire [31:0] instruction, input e_instruction_format fmt, input wire [63:0] rs1, input wire [63:0] rs2, input wire [63:0] imm, output wire [63:0] result);
    wire [63:0] lhs, rhs;
    
    assign result = (fmt == S_FORMAT) ? store_unit.result : load_unit.result;
endmodule
