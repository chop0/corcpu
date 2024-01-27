`timescale 1ns / 1ps


module bu #(parameter DATA_WIDTH = 64) (
	input logic [DATA_WIDTH-1:0] lhs,
	input logic [DATA_WIDTH-1:0] rhs,

	input logic lhs_valid,
	input logic rhs_valid,

	input operation_specification op_spec,

	input logic [DATA_WIDTH-1:0] pc,

	output logic [DATA_WIDTH-1:0] result,
	output logic result_valid
);
	typedef enum {
		EQ,
		NE,
		LT,
		GE,
		LTU,
		GEU
	} CMP_OP;

	function CMP_OP decode(bit [2:0] funct3);
		case (funct3)
			3'h0: return EQ;
			3'h1: return NE;
			3'h4: return LT;
			3'h5: return GE;
			3'h6: return LTU;
			3'h7: return GEU;
			default: return CMP_OP'('X);
		endcase
	endfunction

	function bit compare(bit [DATA_WIDTH-1:0] a, bit [DATA_WIDTH-1:0] b, CMP_OP op);
		case (op)
			EQ: return a == b;
			NE: return a != b;
			LT: return $signed(a) < $signed(b);
			GE: return $signed(a) >= $signed(b);
			LTU: return a < b;
			GEU: return a >= b;
		endcase
	endfunction

	assign result = compare(lhs, rhs, decode(op_spec.funct3)) ? pc + op_spec.imm : pc + 4;
	assign result_valid = lhs_valid && rhs_valid;
endmodule : bu