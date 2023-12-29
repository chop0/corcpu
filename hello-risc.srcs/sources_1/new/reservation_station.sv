`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2023 06:35:34 PM
// Design Name: 
// Module Name: reservation_station
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


module reservation_station #(param N = 0) (
        input logic clk,
        
        input logic cdb_broadcast,
        input logic [2:0] cdb_rs,
        input logic [63:0] cdb_data
    );
    
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    reg j_pending;
    reg k_pending;
    
    reg [2:0] Qj;
    reg [2:0] Qk;
    
    reg [63:0] Vj;
    reg [63:0] Vk;
    
    reg busy;
    
    always_ff @(posedge(clk)) begin
        if (cdb_broadcast && busy) begin
            if (j_pending && cdb_rs == Qj) begin
                j_pending <= 0;
                Vj <= cdb_data;
            end
            
            if (k_pending && cdb_rs == Qk) begin
                k_pending <= 0;
                Vk <= cdb_data;
            end
        end
    end
endmodule
