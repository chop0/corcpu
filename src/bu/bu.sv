`timescale 1ns / 1ps


module bu #(parameter DATA_WIDTH = 64) (
	input clk,
	input rst,

	output logic [4:0] write1,
	output logic [4:0] write2,

	output logic [4:0] read1,
	output logic [4:0] read2,

	output logic write1_enable, write2_enable, read1_enable, read2_enable,

	output register write1_value,
	output register write2_value,
	input register read1_value,
	input register read2_value,

	issue_bus issue_bus,
	
	input logic Retire,

	input logic CDB_valid,
	input logic [DATA_WIDTH-1:0] CDB_result,
	input logic [2:0] CDB_rs_id,

	output logic result_valid,
	output logic [DATA_WIDTH-1:0] result,

	output logic InstructionPolled,
	output logic Busy
);
	typedef enum {
		EQ,
		NE,
		LT,
		GE,
		LTU,
		GEU
	} CMP_OP;

	reservation_station #(DATA_WIDTH, BU) rs(
		.clk ( clk ),
		.rst ( rst ),

		.write1 ( write1 ),
		.write2 ( write2 ),
		.write1_enable ( write1_enable ),
		.write2_enable ( write2_enable ),
		.write1_value ( write1_value ),
		.write2_value ( write2_value ),

		.read1 ( read1 ),
		.read2 ( read2 ),
		.read1_enable ( read1_enable ),
		.read2_enable ( read2_enable ),
		.read1_value ( read1_value ),
		.read2_value ( read2_value ),

		.issue ( issue_bus ),

		.InstructionPolled ( InstructionPolled ),
		.Busy ( Busy ),

		.Retire ( Retire ),

		.CDB_valid ( CDB_valid ),
		.CDB_result ( CDB_result ),
		.CDB_rs_id ( CDB_rs_id )
	);

	function CMP_OP decode(bit [2:0] funct3);
		case (funct3)
			3'h0: return EQ;
			3'h1: return NE;
			3'h4: return LT;
			3'h5: return GE;
			3'h6: return LTU;
			3'h7: return GEU;
		endcase
	endfunction

	function bit compare(bit [DATA_WIDTH-1:0] a, bit [DATA_WIDTH-1:0] b, CMP_OP op);
		case (op)
			EQ: return a == b;
			NE: return a != b;
			LT: return a < b;
			GE: return a >= b;
			LTU: return a < b;
			GEU: return a >= b;
		endcase
	endfunction

	logic [DATA_WIDTH-1:0] result = compare(rs.j.data.value, rs.k.data.value, decode(rs.Op.spec.R.funct3));
	assign result_valid = rs.Busy && !rs.j.is_virtual && !rs.k.is_virtual;
endmodule