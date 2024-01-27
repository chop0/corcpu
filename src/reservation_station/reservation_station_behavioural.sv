`timescale 1ns / 1ps

import types::*;

module reservation_station_behavioural
	#(parameter int DATA_WIDTH, int RS_ID)
	(
		input logic clk,
		input logic rst,

		input register read1_value_i, read2_value_i,

		input logic issue_en_i,
		input operation_specification issue_op_i,
		
		input logic unit_done_i,

		input logic bcast_en_i, // cdb arbiter->us
		input logic [DATA_WIDTH-1:0] bcast_data_i, // cdb arbiter->us
		input e_functional_unit bcast_rs_i, // cdb arbiter->us,
		
		input logic retire_i,

		output logic busy_o, // us->ifu
		output logic resolved_op1_o, // us->unit
		output logic resolved_op2_o, // us->unit

		output logic retirement_ready_o,
		
		output operation_specification current_op_o,

		output logic [DATA_WIDTH - 1:0] op1_value_o, op2_value_o
	);
	e_functional_unit op1_rs_id;
	e_functional_unit op2_rs_id;

	assign retirement_ready_o = busy_o && unit_done_i;

	always_ff @(posedge clk) begin
		if (rst) begin
			busy_o <= 1'b0;
			resolved_op1_o <= 1'b0;
			resolved_op2_o <= 1'b0;
		end else begin
			if (issue_en_i & !busy_o) begin
				busy_o <= 1'b1;
				current_op_o <= issue_op_i;

				if (read1_value_i.is_virtual)
					if (bcast_en_i && bcast_rs_i == read1_value_i.data.rs_id) begin
						op1_value_o <= bcast_data_i;
						resolved_op1_o <= 1'b1;
					end else begin
						op1_rs_id <= read1_value_i.data.rs_id;
						resolved_op1_o <= 1'b0;
					end
				else begin
					op1_value_o <= read1_value_i.data.value;
					resolved_op1_o <= 1'b1;
				end

				if (read2_value_i.is_virtual)
					if (bcast_en_i && bcast_rs_i == read2_value_i.data.rs_id) begin
						op2_value_o <= bcast_data_i;
						resolved_op2_o <= 1'b1;
					end else begin
						op2_rs_id <= read2_value_i.data.rs_id;
						resolved_op2_o <= 1'b0;
					end
				else begin
					op2_value_o <= read2_value_i.data.value;
					resolved_op2_o <= 1'b1;
				end
			end

			if (busy_o && !resolved_op1_o && bcast_en_i && bcast_rs_i == op1_rs_id) begin
				op1_value_o <= bcast_data_i;
				resolved_op1_o <= 1'b1;
			end

			if (busy_o && !resolved_op2_o && bcast_en_i && bcast_rs_i == op2_rs_id) begin
				op2_value_o <= bcast_data_i;
				resolved_op2_o <= 1'b1;
			end

			if (retire_i) begin
				busy_o <= 1'b0;
				resolved_op1_o <= 1'b0;
				resolved_op2_o <= 1'b0;
			end
		end
	end
endmodule
