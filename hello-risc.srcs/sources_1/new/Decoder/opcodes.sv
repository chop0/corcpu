`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2023 01:19:37 PM
// Design Name: 
// Module Name: opcodes
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

package opcodes;
    localparam ARITH_OPCODE = 7'b0110011;
    localparam ARITH_IMM_OPCODE = 7'b0010011;
    localparam LOAD_OPCODE = 7'b0000011;
    localparam STORE_OPCODE = 7'b0100011;
    localparam BRANCH_OPCODE = 7'b1100011;
endpackage