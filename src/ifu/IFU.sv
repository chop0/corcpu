`timescale 1ns / 1ps

// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2023, <COMPANY>
//
// Created : 31. Dec 2023 12:47 AM
//-------------------------------------------------------------------
module IFU #(parameter ADDRESS_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic instruction_poll,

	input logic CDB_valid,
	input logic [ADDRESS_WIDTH-1:0] CDB_result,
	input logic [2:0] CDB_rs_id,

	output logic [31:0] instruction,
	output logic instruction_valid
);
	logic [ADDRESS_WIDTH - 1:0] fetch_pc;

	logic branch_in_pipeline = 0;
	logic stall = branch_in_pipeline || queue.full;

	synchronous_fifo #(8, 32) queue (
		.clk ( clk ),
		.rst ( rst ),

		.push ( !stall ),
		.poll ( instruction_poll ),

		.data_in ( instruction )
	);

	assign instruction_valid = !queue.empty;

	memory mem (
		.clk ( clk ),
		.rst ( rst ),

		.write ( 1'b0 ),
		.addr ( fetch_pc ),
		.data_in ( 'h0 ),
		.data_out ( instruction )
	);

	always_ff @(posedge clk) begin
		if (rst) begin
			queue.becomes_empty();
			fetch_pc <= 'h0;
		end

		else begin
			if (!stall) begin
				fetch_pc <= fetch_pc + 'h4;
				if (instruction[6:0] == 1100011) begin
					branch_in_pipeline <= 1;
				end
			end

			if (CDB_valid && CDB_rs_id == BU) begin
				assert (branch_in_pipeline);

				branch_in_pipeline <= 0;
				fetch_pc <= CDB_result;
			end
		end
	end
endmodule : IFU