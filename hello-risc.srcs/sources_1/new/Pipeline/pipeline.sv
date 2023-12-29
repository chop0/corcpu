`timescale 1ns / 1ps

import types::*;

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 05:50:33 PM
// Design Name: 
// Module Name: cpu
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

typedef struct {
    bit [63:0] rs1;
    bit [63:0] rs2;
    bit [63:0] imm;
    
    bit [4:0] rd;
        
    e_instruction_format fmt;
    e_functional_unit unit;
} decode_output;

typedef struct {
    reg [63:0] writeback_value;
    reg [4:0] rd;
} execute_output;

module pipeline(
        input [31:0] fd_instruction,
        input clk,
        input d_active,
        input rst,
        output reg [63:0] pc,
        output reg [63:0] retired_count
);
    reg [63:0] registers [31:0];
    
    decode_stage decode (
        .clk ( clk ),
        .rst ( rst ),
        
        .enable ( d_active ),
        
        .instruction ( fd_instruction ),
        .registers ( registers ),
        
        .out ( ),
        .output_valid ( )
    );
    
    execute_stage execute (
        .clk ( clk ),
        .rst ( rst ),
        
        .enable ( decode.output_valid ),
        .decoded ( decode.out ),
        
        .out ( )
    );
    
    writeback_stage writeback (
        .clk ( clk ),
        .rst ( rst ),
        
        .enable ( execute.output_valid ),
        .execute ( execute.out ),
        
        .registers ( registers ),
        .retired_count ( retired_count )
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            for (int i = 0; i < 32; i++) registers[i] <= 64'd0;
        end;
    end

endmodule
