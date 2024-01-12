package types;
typedef enum logic [1:0] {
        R_FORMAT, I_FORMAT, S_FORMAT, B_FORMAT
} e_instruction_format;

typedef enum {
    ALU, BU, LSU
} e_functional_unit;

typedef union {
    struct {
    	bit [4:0] rs1; // 5 bits
    	bit [2:0] funct3; // 3 bits
    	bit [4:0] rs2; // 5 bits
        bit [4:0] rd; // 5 bits
        bit [6:0] funct7; // 7 bits
    } R; // 25 bits

    struct {
    	bit [4:0] rs1; // 5 bits
    	bit [2:0] funct3; // 3 bits
        bit [4:0] rd; // 5 bits
        bit [11:0] imm; // 12 bits
    } I; // 25 bits

    struct {
        bit [4:0] rs1; // 5 bits
        bit [2:0] funct3; // 3 bits
        bit [4:0] rs2; // 5 bits
        bit [11:0] imm; // 12 bits
    } SB; // 25 bits
} op_fields;

typedef struct {
    e_instruction_format encoding;
    bit [6:0] opcode;

    op_fields spec;
} operation_specification;


typedef struct {
	bit is_virtual;

	union {
		bit [64 - 1:0] rs_id;
		bit [64 - 1:0] value;
	} data;
} register;

typedef struct {
    bit valid;

    bit [2:0] rs_id;
    operation_specification op;
} issue_bus;

endpackage