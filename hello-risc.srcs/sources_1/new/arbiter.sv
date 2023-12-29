`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2023 04:51:44 PM
// Design Name: 
// Module Name: arbiter
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


module arbiter 
    #(integer N_MASTERS) 
    (input logic [N_MASTERS-1:0] req, output logic [$clog2(N_MASTERS) - 1:0] ack);
    
    always_comb begin
        ack = 0;
        for (int i = N_MASTERS - 1; i >= 0; i = i - 1)
            if (req[i]) ack = i;
    end 
endmodule
