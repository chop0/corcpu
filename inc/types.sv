`ifndef TYPES_SV
`define TYPES_SV

package types;
localparam FU_CNT = 3;
localparam INSN_FMT_CNT = 4;
typedef enum logic [1:0] {
        R_FORMAT, I_FORMAT, S_FORMAT, B_FORMAT
} e_instruction_format;

typedef enum logic [1:0]{
    ALU, BU, LSU
} e_functional_unit;

function bit has_rs1(e_instruction_format format);
	return format == R_FORMAT || format == I_FORMAT || format == S_FORMAT || format == B_FORMAT;
endfunction

function bit has_rs2(e_instruction_format format);
	return format == R_FORMAT || format == S_FORMAT || format == B_FORMAT;
endfunction

function bit has_rd(e_instruction_format format);
	return format == R_FORMAT || format == I_FORMAT;
endfunction

function bit has_imm(e_instruction_format format);
	return format == I_FORMAT || format == S_FORMAT || format == B_FORMAT;
endfunction

typedef struct {
    bit [6:0] opcode;
    e_instruction_format encoding;

    bit [4:0] rs1;
    bit[2:0] funct3;
    bit [4:0] rs2;
    bit [4:0] rd;
    bit [6:0] funct7;

    bit [11:0] imm;
} operation_specification;


typedef struct {
	bit is_virtual;

	union {
		e_functional_unit rs_id;
		bit [64 - 1:0] value;
	} data;
} register;

typedef struct {
    bit valid;

    bit [2:0] rs_id;
    operation_specification op;
} issue_bus;

endpackage

`endif