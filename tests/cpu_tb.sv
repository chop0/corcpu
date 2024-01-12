`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2023 12:24:34 PM
// Design Name: 
// Module Name: cpu_tb
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


module cpu_tb;
	logic clk, rst;
	
	cpu cpu (
		.clk ( clk ),
		.rst ( rst )
	);
	
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		rst = 0;
		@(posedge(clk));
		rst = 1;
		@(posedge(clk));
		rst = 0;
	end
endmodule : cpu_tb
