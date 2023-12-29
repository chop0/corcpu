`timescale 1ns / 1ps
import types::*;
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 12:13:20 AM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic [3:0] {
    ADD, SUB, XOR, OR, AND, LSH, RSH, RSHS, CMPS, CMP, INVL
} e_alu_op;    

module alu_op_decoder (
    input [31:0] instruction, 
    input e_instruction_format fmt, 
    
    input [63:0] rs1, input [63:0] rs2, 
    input [63:0] imm, 
    
    output e_alu_op op,
    output logic [63:0] lhs, output logic [63:0] rhs
);
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    
    always @(*) begin
        case (funct3)
            3'h0 : op = (fmt == I_FORMAT || funct7 == 7'h0) ? ADD : SUB;
            3'h4 : op = XOR;
            3'h6 : op = OR;
            3'h7 : op = AND;
            3'h1 : op = LSH;
            3'h5 : op = funct7 == 7'h0 ? RSH : RSHS;
            3'h2 : op = CMPS;
            3'h3 : op = CMP;
            default: op = INVL;
       endcase;
       
       lhs = rs1;
       case (fmt)
            R_FORMAT : rhs = rs2;
            I_FORMAT : begin
                rhs = imm;
                if (op == LSH || op == RSH || op == RSHS) rhs[63:5] = 0;
            end
            default  : rhs = 64'h0;
       endcase
    end
endmodule

module alu_op_calculator (input e_alu_op op, input [63:0] lhs, input [63:0] rhs, output logic [63:0] result);
    always @(*) begin 
        case (op)
            ADD: result = lhs + rhs;
            SUB: result = lhs - rhs;
            XOR: result = lhs ^ rhs;
            OR: result = lhs | rhs;
            AND: result = lhs & rhs;
            LSH: result = lhs << rhs;
            RSH: result = lhs >> rhs;
            RSHS: result = lhs >>> rhs;
            CMPS: result = ($signed(lhs) < $signed(rhs)) ? 1 : 0;
            CMP: result = (lhs < rhs) ? 1 : 0;
            default: result = 'hdeadbeefdeadbeef;
        endcase
    end
endmodule

module alu (input wire [31:0] instruction, input e_instruction_format fmt, input wire [63:0] rs1, input wire [63:0] rs2, input wire [63:0] imm, output wire [63:0] result);
    e_alu_op op;
    wire [63:0] lhs, rhs;
    
    alu_op_decoder decoder(
        .instruction ( instruction ), 
        .fmt ( fmt ), 
        .rs1 ( rs1 ), 
        .rs2 ( rs2 ), 
        .imm ( imm ),
        
        .op ( op ),
        .lhs ( lhs ),
        .rhs ( rhs )
  );
    alu_op_calculator calculator(
        .op ( op ),
        
        .lhs ( lhs ),
        .rhs ( rhs ),
        
        .result ( result )
 ); 
endmodule
