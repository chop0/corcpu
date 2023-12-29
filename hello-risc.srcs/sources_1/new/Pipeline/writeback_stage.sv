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


module writeback_stage(
    input clk,
    input rst,
    input enable,
    
    input execute_output execute,
    output reg [63:0] registers [31:0],
    
    output reg [63:0] retired_count
    );
    
    always_ff @(posedge clk) begin
        if (enable && !rst) begin
            registers[execute.rd] <= execute.writeback_value;    
            retired_count <= retired_count + 1;
        end
    end
endmodule
