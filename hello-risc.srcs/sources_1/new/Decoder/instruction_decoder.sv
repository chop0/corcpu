`timescale 1ns / 1ps

import types::*;
import opcodes::*;


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
        unit = ALU;
    end
endmodule

module immediate_decoder(input [31:0] instruction, input e_instruction_format format, output logic [31:0] imm);
    always_comb begin
        imm = 0;
        unique case (format)
                I_FORMAT : begin                        
                        imm[31:12] = 0;
                        imm[11:0] = instruction[31:20];
                end

                S_FORMAT : begin
                        imm[31:12] = 0;
                        imm[11:5] = instruction[31:25];
                        imm[4:0] = instruction[11:7];
                end

                B_FORMAT : begin
                        imm[31:13] = 0;
                        imm[12] = instruction[31];
                        imm[10:5] = instruction[30:25];
                        imm[4:1] = instruction[11:8];
                        imm[11] = instruction[7];
                end

                default : imm = 32'hx;
        endcase
    end
endmodule

module instruction_decoder(
        input wire [31:0] instruction,

        output wire [4:0] read_register1,
        output wire [4:0] read_register2,
        output wire [31:0] imm,
        output e_instruction_format fmt,
        output e_functional_unit unit
);
    instruction_format_decoder fmt_decoder(
        .instruction ( instruction ),
        .format ( fmt ),
        .unit ( unit )
    );
    
    
    immediate_decoder imm_decoder(instruction, fmt, imm);    
    assign read_register1 = instruction[19:15];
    assign read_register2 = (fmt == I_FORMAT) ? 5'b0 : instruction[24:20];
endmodule
