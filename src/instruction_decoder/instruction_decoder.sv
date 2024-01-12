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
        R_FORMAT : begin
        	decode_instruction.spec.R.funct7 = instruction[31:25];
        	decode_instruction.spec.R.rs2 = rs2;
        	decode_instruction.spec.R.rs1 = rs1;
        	decode_instruction.spec.R.funct3 = funct3;
        	decode_instruction.spec.R.rd = rd;
		end

        I_FORMAT : begin
			decode_instruction.spec.I.imm = instruction[31:20];
			decode_instruction.spec.I.rs1 = rs1;
			decode_instruction.spec.I.funct3 = funct3;
			decode_instruction.spec.I.rd = rd;
		end

        S_FORMAT : begin
			decode_instruction.spec.SB.imm = { instruction[31:25] , instruction[11:7] };
			decode_instruction.spec.SB.rs2 = rs2;
			decode_instruction.spec.SB.rs1 = rs1;
			decode_instruction.spec.SB.funct3 = funct3;
		end

        B_FORMAT : begin
        	decode_instruction.spec.SB.imm = { instruction[31] , instruction[7] , instruction[30:25] , instruction[11:8], 1'b0 };
			decode_instruction.spec.SB.rs2 = rs2;
			decode_instruction.spec.SB.rs1 = rs1;
			decode_instruction.spec.SB.funct3 = funct3;
		end
    endcase

	decode_instruction.encoding = format;
	decode_instruction.opcode = opcode;

endfunction : decode_instruction

module instruction_issuer(
        input logic clk,
        input logic rst,

        input [31:0] instruction,
        input instruction_valid,

        output issue_bus issue_bus
);
    instruction_format_decoder fmt_decoder(
        .instruction ( instruction ),
        .format ( ),
        .unit ( )
    );

    operation_specification op = decode_instruction(instruction, fmt_decoder.format);

    assign issue_bus = '{
        valid: instruction_valid,
        rs_id: fmt_decoder.unit,
        op: op
    };
endmodule
