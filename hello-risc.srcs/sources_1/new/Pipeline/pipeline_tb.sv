`timescale 1ns / 100ps

import instructions::*;

module pipeline_tb;

    // Testbench Signals
    reg [31:0] fd_instruction;
    reg clk, d_active, rst;
    wire [63:0] pc;
    reg [63:0] retired;
reg [63:0] registers [31:0];
    // Instantiate CPU
    pipeline dut(
        .fd_instruction(fd_instruction),
        .clk(clk),
        .d_active(d_active),
        .rst(rst),
        .pc(pc),
        .retired_count (retired)
    );

    task clock_cycle;
        begin;
            clk = 0;
            #5;
            clk = 1;
            #5;
            clk = 0;
        end
    endtask

    // Task to Initialize Testbench State
    task initialize;
        begin
            fd_instruction = 32'd0;
            d_active = 0;
            rst = 1;
            clock_cycle();
            rst = 0;
        end
    endtask

    // Task to Load an Instruction
    task load_instruction(input [31:0] instr);
        begin
            fd_instruction = instr;
            d_active = 1;
            clock_cycle();
            d_active = 0;
            clock_cycle();
            clock_cycle();
        end
    endtask

    // Task to Validate PC Increment
    task validate_pc(input [63:0] expected_pc);
        begin
            if ((pc) != (expected_pc)) begin
                $display("Test Failed: PC expected to be %d, found %d", expected_pc, pc);
                $finish;
            end
        end
    endtask
    
`define ASSERT_EQ(actual, expected, msg) \
    assert ((actual) === (expected)) else begin \
        $display("Assertion failed for %s. Expected: %h, Actual: %h", (msg), (expected), (actual)); \
        $finish; \
        end
    
    // Test Sequence
    initial begin
        initialize();
        
        load_instruction(addi(2, 0, 5));
        load_instruction(addi(3, 0, 10));

        
        load_instruction(add(1, 2, 3));
        `ASSERT_EQ(dut.registers[1], 64'd15, "add(1, 2, 3)");
        
        load_instruction(sub(1, 3, 2));
        `ASSERT_EQ(dut.registers[1], 64'd5, "sub(1, 3, 2)");
        
        load_instruction(addi(1, 2, 10));
        `ASSERT_EQ(dut.registers[1], 64'd15, "addi(1, 2, 10)");
        
        load_instruction(slti(1, 2, 8));
        `ASSERT_EQ(dut.registers[1], 64'd1, "slti(1, 2, 8)");
        
        load_instruction(xor_(1, 2, 3));
        `ASSERT_EQ(dut.registers[1], dut.registers[2] ^ dut.registers[3], "xor_(1, 2, 3)");
        
        load_instruction(ori(1, 64'd2, 8'hF0));
        `ASSERT_EQ(dut.registers[1], dut.registers[2] | 8'hF0, "ori(1, 2, 8'hF0)");
        
        load_instruction(and_(1, 2, 3));
        `ASSERT_EQ(dut.registers[1], dut.registers[2] & dut.registers[3], "and_(1, 2, 3)");
        
        $display("All tests passed!");
        $finish;
    
    end

endmodule

