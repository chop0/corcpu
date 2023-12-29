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


module decode_stage(
    input clk,
    input rst,
    input enable,
    
    input [31:0] instruction,
    input [63:0] registers [31:0],
    
    output decode_output out,
    output reg output_valid
    );
    
    instruction_decoder d_decoder (
        .instruction ( instruction )
    );
    
    always_ff @(posedge clk) begin
        if (!rst && enable) begin
               out <= '{
                    rs1: registers[d_decoder.read_register1],
                    rs2: registers[d_decoder.read_register2],
                    imm: d_decoder.imm,
                    
                    fmt: d_decoder.fmt,
                    unit: d_decoder.unit,
                    
                    rd: instruction[11:7]
               };
        end
        
        output_valid <= !rst && enable;
    end
endmodule
