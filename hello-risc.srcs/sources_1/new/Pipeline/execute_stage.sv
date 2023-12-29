`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2023 12:36:25 PM
// Design Name: 
// Module Name: execute_stage
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


module execute_stage(
    input clk,
    input rst,
    input enable,
    
    input decode_output decoded,
    
    output execute_output out,
    output reg output_valid
    );
     alu alu(
            .instruction ( decoded.instruction ),
            .fmt ( decoded.fmt ),
            .rs1 ( decoded.rs1 ),
            .rs2 ( decoded.rs2 ),
            .imm ( decoded.imm )
    );
    
    always_ff @(posedge clk) begin
        if (rst) 
            output_valid <= 0;
        else if (enable) begin
                    unique case (decoded.unit)
                            ALU : out.writeback_value <= alu.result; 
                    endcase
            
                    out.rd <= decoded.rd;
                    output_valid <= 1;
        end else output_valid <= 0;
    end
endmodule
