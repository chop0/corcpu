`timescale 1ns / 1ps
import types::*;

module alu #(parameter DATA_WIDTH = 64) (
	input logic [DATA_WIDTH-1:0] lhs,
	input logic [DATA_WIDTH-1:0] rhs,

	input logic lhs_valid,
	input logic rhs_valid,

	input operation_specification op_spec,

	output logic [DATA_WIDTH-1:0] result,
	output logic result_valid
);

	logic [2:0] funct3;
	logic [6:0] funct7;
	logic uses_imm;

	always_comb begin
		funct3 = op_spec.funct3;
		funct7 = op_spec.funct7;
		uses_imm = has_imm(op_spec.encoding);
	end

	always_comb begin
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
				default 		: $fatal("alu: invalid instruction");
			endcase
		else casez ({ funct3, funct7 })
				{ 3'h0, 7'h?? } : result = lhs + op_spec.imm;
				{ 3'h4, 7'h?? } : result = lhs ^ op_spec.imm;
				{ 3'h6, 7'h?? } : result = lhs | op_spec.imm;
				{ 3'h7, 7'h?? } : result = lhs & op_spec.imm;
				{ 3'h1, 7'h00 } : result = lhs << op_spec.imm[4:0];
				{ 3'h5, 7'h00 } : result = lhs >> op_spec.imm[4:0];
				{ 3'h5, 7'h20 } : result = $signed(lhs) >>> op_spec.imm[4:0];
				{ 3'h2, 7'h?? } : result = ($signed(lhs) < $signed(op_spec.imm)) ? 1 : 0;
				{ 3'h3, 7'h?? } : result = (lhs < op_spec.imm) ? 1 : 0;
				default 		: $fatal("alu: invalid instruction");
			endcase	
	end

   assign result_valid = lhs_valid & rhs_valid;
endmodule

