`timescale 1ns / 1ps

import types::*;

localparam ARITH_OPCODE = 7'b0110011;
localparam ARITH_IMM_OPCODE = 7'b0010011;
localparam LOAD_OPCODE = 7'b0000011;
localparam STORE_OPCODE = 7'b0100011;
localparam BRANCH_OPCODE = 7'b1100011;

module instruction_format_decoder(input [31:0] instruction, output e_instruction_format format, output e_functional_unit unit);
    wire [6:0] opcode = instruction[6:0];

    always_comb begin
        unique case (opcode)
                ARITH_OPCODE                  : format = R_FORMAT;
                ARITH_IMM_OPCODE, LOAD_OPCODE : format = I_FORMAT;
                STORE_OPCODE                  : format = S_FORMAT;
                BRANCH_OPCODE                 : format = B_FORMAT;
                default                       : format = R_FORMAT;
        endcase
        
        unique case (opcode)
            ARITH_OPCODE, ARITH_IMM_OPCODE : unit = ALU;
            BRANCH_OPCODE                  : unit = BU;
            LOAD_OPCODE, STORE_OPCODE      : unit = LSU;
            
            default                         : unit = ALU;
        endcase
    end
endmodule

function operation_specification decode_instruction(input bit [31:0] instruction, input e_instruction_format format);
    automatic bit [6:0] opcode = instruction[6:0];
    automatic bit [4:0] rd = instruction[11:7];
    automatic bit [2:0] funct3 = instruction[14:12];
    automatic bit [4:0] rs1 = instruction[19:15];
    automatic bit [4:0] rs2 = instruction[24:20];

    case (format)
        R_FORMAT : decode_instruction = '{
        	encoding: format,
        	opcode: opcode,
        	rs1: rs1,
        	funct3: funct3,
        	rs2: rs2,
        	rd: rd,
        	funct7: instruction[31:25],
        	imm: 'X
        };

        I_FORMAT : decode_instruction = '{
        	encoding: format,
            opcode: opcode,
			rs1: rs1,
			funct3: funct3,
			rs2: 'X,
			rd: rd,
			funct7: 'X,
			imm: instruction[31:20]
		};

        S_FORMAT : decode_instruction = '{
        	encoding: format,
            opcode: opcode,
			rs1: rs1,
			funct3: funct3,
			rs2: rs2,
			rd: 'X,
			funct7: 'X,
			imm: { instruction[31:25] , instruction[11:7] }
		};

        B_FORMAT : decode_instruction = '{
        	encoding: format,
            opcode: opcode,
			rs1: rs1,
			funct3: funct3,
			rs2: rs2,
			rd: 'X,
			funct7: 'X,
			imm: { instruction[31] , instruction[7] , instruction[30:25] , instruction[11:8], 1'b0 }
		};
    endcase
endfunction : decode_instruction

module instruction_decoder(
        input [31:0] instruction,

        output logic [2:0] rs_id,
        output operation_specification op
);
	e_instruction_format format;

    instruction_format_decoder fmt_decoder(
        .instruction ( instruction ),
        .format ( format ),
        .unit ( rs_id )
    );

    assign op = decode_instruction(instruction, format);
endmodule
