`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 01:10:34 AM
// Design Name: 
// Module Name: alu_tb
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


module alu_tb;
    reg clk;
    initial clk = 0;
    initial begin
        clk = 0;
        forever 
             #5 clk = ~clk;
    end
        

    // Testbench Variables
    reg [31:0] instruction;
    reg [63:0] rs1, rs2, imm;
    wire [63:0] o;

    // Instantiate the ALU Module
    instruction_decoder decoder(instruction, rs1, rs2, imm);
    alu DUT (decoder, o);

    // Testbench Procedure
    initial begin
        // Initialize the inputs
        instruction = 32'b0;
        rs1 = 64'b0;
        rs2 = 64'b0;
        imm = 64'b0;

        // Monitor Changes
        $monitor("Time = %t, Instruction = %b, rs1 = %d, rs2 = %d, imm = %d, Output = %d", 
                 $time, instruction, rs1, rs2, imm, o);

        // Test Cases
        // Add more test cases here
        instruction = 32'b00000000010100001000000010010011; // a
        rs1 = 64'd10;  // Example rs1
        rs2 = 64'd15;
        imm = 64'd5;

        #100; 
        assert (o == 15);
        
        #100 $finish;
    end

endmodule
