`timescale 1ns / 1ps

// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2023, <COMPANY>
//
// Created : 31. Dec 2023 12:47 AM
//-------------------------------------------------------------------
module ifu #(parameter ADDRESS_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic instruction_poll_i,

	input logic bcast_valid_i,
	input logic [ADDRESS_WIDTH-1:0] bcast_value_i,
	input e_functional_unit bcast_rs_i,

	output logic fetch_ready_o,
	output logic [31:0] fetch_insn_o,

	output logic [ADDRESS_WIDTH - 1:0] imem_load_addr_o,
	output logic imem_load_en_o,
	input logic [31:0] imem_load_insn_i,
	input logic imem_load_busy_i,
	input logic imem_load_rdy_i
);
	logic [ADDRESS_WIDTH - 1:0] insn_load_pc;
	logic branch_in_pipeline;

	logic empty, full;
	logic queue_reset;

	synchronous_fifo #(8, 32) queue (
		.clk ( clk ),
		.rst ( queue_reset ), // clear queue on branch

		.push ( imem_load_rdy_i ),
		.poll ( instruction_poll_i ),

		.data_in ( imem_load_insn_i ),

		.head ( fetch_insn_o ),
		.tail ( ),
		.empty ( empty ),
		.full ( full )
	);

	assign queue_reset = rst || (bcast_valid_i && bcast_rs_i == BU);
	assign fetch_ready_o = !rst && !empty && !queue_reset;

	assign imem_load_addr_o = insn_load_pc;
    assign imem_load_en_o = !(branch_in_pipeline || full) && !imem_load_busy_i;

	always_ff @(posedge clk) if (rst) begin
		branch_in_pipeline <= 0;
		insn_load_pc <= 'b0;
	end

	always_ff @(posedge clk) if (!rst && imem_load_rdy_i) begin
		if (imem_load_insn_i[6:0] == 7'b1100011)
			branch_in_pipeline <= 1;
		else
			insn_load_pc <= insn_load_pc + 'h4;
	end

	always_ff @(posedge clk) if (!rst && bcast_valid_i && bcast_rs_i == BU) begin
		branch_in_pipeline <= 0;
		insn_load_pc <= bcast_value_i;
	end
endmodule : ifu