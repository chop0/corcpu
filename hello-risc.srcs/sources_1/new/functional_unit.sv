`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2023 05:08:32 PM
// Design Name: 
// Module Name: functional_unit
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

interface functional_unit (input clk);
    logic [2:0] rs;
    logic [63:0] result;
    
    logic result_available;
    logic ack_broadcasted;
        
    //modport FU  (output result_available, output result, output rs, input  ack_broadcasted);
    //modport CDB (input  result_available, input  result, input  rs, output ack_broadcasted);
endinterface