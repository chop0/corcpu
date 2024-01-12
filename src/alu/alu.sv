`timescale 1ns / 1ps
import types::*;

module alu #(parameter DATA_WIDTH = 64) (
	input logic [DATA_WIDTH-1:0] lhs,
	input logic [DATA_WIDTH-1:0] rhs,

	input logic lhs_valid,
	input logic rhs_valid,
	input logic uses_imm,

	input logic [2:0] funct3,
	input logic [6:0] funct7,

	output logic [DATA_WIDTH-1:0] result,
	output logic result_valid
);
	always_comb
		if (!uses_imm) case ({ funct3, funct7 })
				{ 3'h0, 7'h00 } : result = lhs + rhs;
				{ 3'h0, 7'h20 } : result = lhs - rhs;
				{ 3'h4, 7'h00 } : result = lhs ^ rhs;
				{ 3'h6, 7'h00 } : result = lhs | rhs;
				{ 3'h7, 7'h00 } : result = lhs & rhs;
				{ 3'h1, 7'h00 } : result = lhs << rhs;
				{ 3'h5, 7'h00 } : result = lhs >> rhs;
				{ 3'h5, 7'h20 } : result = $signed(lhs) >>> rhs;
				{ 3'h2, 7'h00 } : result = ($signed(lhs) < $signed(rhs)) ? 1 : 0;
				{ 3'h3, 7'h00 } : result = (lhs < rhs) ? 1 : 0;
				default 		: result = {DATA_WIDTH{1'bx}};
			endcase
		else casex ({ funct3, funct7 })
				{ 3'h0, 7'hxx } : result = lhs + rhs;
				{ 3'h4, 7'hxx } : result = lhs ^ rhs;
				{ 3'h6, 7'hxx } : result = lhs | rhs;
				{ 3'h7, 7'hxx } : result = lhs & rhs;
				{ 3'h1, 7'h00 } : result = lhs << rhs[4:0];
				{ 3'h5, 7'h00 } : result = lhs >> rhs[4:0];
				{ 3'h5, 7'h20 } : result = $signed(lhs) >>> rhs[4:0];
				{ 3'h2, 7'hxx } : result = ($signed(lhs) < $signed(rhs)) ? 1 : 0;
				{ 3'h3, 7'hxx } : result = (lhs < rhs) ? 1 : 0;
				default 		: result = {DATA_WIDTH{1'bx}};
			endcase

   assign result_valid = lhs_valid & rhs_valid;
endmodule

