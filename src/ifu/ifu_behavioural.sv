// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2024, <COMPANY>
//
// Created : 21. Jan 2024 9:29 PM
//-------------------------------------------------------------------
import types::*;

module ifu_behavioural #(parameter ADDRESS_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic instruction_poll_i,

	input logic bcast_valid_i,
	input logic [ADDRESS_WIDTH-1:0] bcast_value_i,
	input e_functional_unit bcast_rs_i,

	output logic fetch_ready_o,
	output e_functional_unit fetch_rs_id_o,
	output logic [31:0] fetch_insn_o,

	input logic [7:0] mem [1024]
 );
 	bit [ADDRESS_WIDTH-1:0] pc = 0;

	logic [31:0] current_insn;
	assign current_insn = { mem[pc], mem[pc + 1], mem[pc + 2], mem[pc + 3] };
	assign fetch_insn_o = current_insn;

	always_ff @(posedge(clk)) begin
		if (rst) begin
			pc <= 0;
			fetch_ready_o <= 1;
		end

		if (instruction_poll_i) begin
			if (mem[pc + 3][6:0] != 7'b1100011) begin
				pc <= pc + 4;
				fetch_ready_o <= 1;
			end else begin
				fetch_ready_o <= 0;
			end
		end

		if (bcast_valid_i && bcast_rs_i == BU) begin
			pc <= bcast_value_i;
			fetch_ready_o <= 1;
		end
	end
endmodule : ifu_behavioural