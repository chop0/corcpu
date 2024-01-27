// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2024, <COMPANY>
//
// Created : 21. Jan 2024 9:46 PM
//-------------------------------------------------------------------
`include "types.sv"
import types::*;

// verilator lint_off PINMISSING
module ifu_tb(input logic clk, input logic rst, input logic en);
	localparam ADDRESS_WIDTH = 64;

	logic [7:0] mem [1024];

	logic instruction_poll_i = 'b0;

	logic bcast_valid_i = 'b0;
	logic [ADDRESS_WIDTH-1:0] bcast_value_i = 'b0;
	e_functional_unit bcast_rs_i;
	logic [31:0] imem_load_insn_i = 'b0;

	logic [ADDRESS_WIDTH-1:0] load_pc;
	logic [31:0] loaded_insn;
	
	assign loaded_insn = {mem[load_pc], mem[load_pc+1], mem[load_pc+2], mem[load_pc+3]};
	ifu dut (
		.clk(clk),
		.rst(rst),
		.instruction_poll_i(instruction_poll_i),
		.bcast_valid_i(bcast_valid_i),
		.bcast_value_i(bcast_value_i),
		.bcast_rs_i(bcast_rs_i),
		.fetch_ready_o( ),
		.fetch_insn_o( ),
		
		.imem_load_addr_o( load_pc ),
		.imem_load_insn_i( loaded_insn )
	);

	ifu_behavioural ifu_behavioural (
		.clk(clk),
		.rst(rst),
		.instruction_poll_i(instruction_poll_i),
		.bcast_valid_i(bcast_valid_i),
		.bcast_value_i(bcast_value_i),
		.bcast_rs_i(bcast_rs_i),
		.fetch_ready_o(),
		.fetch_insn_o(),

		.mem( mem )
	);

	logic finished;

	always_ff @(posedge clk) if (rst) begin
		for (int i = 0; i < 1024; i += 4) begin
					mem[i] = i;
					mem[i+1] = $random;
					mem[i+2] = $random;
					mem[i+3] = (1'($random) & 1'b1) ? 8'b01100011 : $random;
		end
		finished <= 0;
		bcast_value_i <= $urandom % 1020;
	end

	always_ff @(posedge clk) if (!rst) begin
		bcast_valid_i <= $urandom;
		bcast_rs_i <= e_functional_unit'($urandom % FU_CNT);
		instruction_poll_i <= $random & dut.fetch_ready_o & !(bcast_valid_i & bcast_rs_i == BU);

		if (instruction_poll_i) begin
			bcast_value_i <= $urandom % 1020;
		end

		// compare outputs and print inputs and mismatched outputs if they are not equal
		if (!finished & en & dut.fetch_ready_o &
		 (  ifu_behavioural.fetch_ready_o !=  dut.fetch_ready_o
			|| ifu_behavioural.fetch_insn_o != dut.fetch_insn_o)) begin
			$display("Mismatch between behavioural and RTL ifu");
			$display("Inputs:");
			$display("	instruction_poll_i: %b", instruction_poll_i);
			$display("	bcast_valid_i: %b", bcast_valid_i);
			$display("	bcast_value_i: %h", bcast_value_i);
			$display("	bcast_rs_i: %h", bcast_rs_i);
			$display("Outputs:");
			$display("	fetch_ready_o: behavioural: %b, RTL: %b", ifu_behavioural.fetch_ready_o, dut.fetch_ready_o);
			$display("	fetch_insn_o: behavioural: %h, RTL: %h", ifu_behavioural.fetch_insn_o, dut.fetch_insn_o);
			$stop;
		end

		if (!finished & ifu_behavioural.pc >= 1020) begin
			finished <= 1;
			$display("IFU finished");
		end
	end
endmodule : ifu_tb