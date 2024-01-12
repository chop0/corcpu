`timescale 1ns / 1ps
import types::*;

module Bus_Arbiter #(parameter RS_COUNT = 3) (
	// issue
	input logic fetch_valid, // do we have a valid instruction to issue?
	input logic [2:0] fetch_target_rs, // which reservation station is the instruction going to?
	input operation_specification fetch_op_spec, // what operation is the instruction?
	output logic QueuePolled, // is the instruction issued?

	input logic [RS_COUNT - 1:0] Busy,

	input logic [RS_COUNT - 1:0] poll_write_enable_units,
	input logic [4:0] poll_write_units [RS_COUNT - 1:0],
	input register poll_write_value_units [RS_COUNT - 1:0],

	input logic [RS_COUNT - 1:0] read1_enable_units, read2_enable_units,
	input logic [4:0] read1_register_units [RS_COUNT - 1:0],
	input logic [4:0] read2_register_units [RS_COUNT - 1:0],

	output logic poll_write_enable,
	output logic [4:0] poll_write_register,
	output register poll_write_value,

	output logic read1_enable,
	output logic [4:0] read1_register,
	output logic read2_enable,
	output logic [4:0] read2_register,

	output logic [RS_COUNT - 1:0] DoIssue,

	// retirement
	input logic [RS_COUNT - 1:0] ReadyToRetire,

	input logic [RS_COUNT - 1:0] retire_write_enable_units,
	input logic [4:0] retire_write_units [RS_COUNT - 1:0],
	input register retire_write_value_units [RS_COUNT - 1:0],

	output logic retire_write_enable,
	output logic [4:0] retire_write_register,
	output register retire_write_value,

	output logic [RS_COUNT - 1:0] DoRetire
);
	always_comb
		if (fetch_valid && !Busy[fetch_target_rs]) begin
				QueuePolled = 'b1;

				poll_write_enable = poll_write_enable_units[fetch_target_rs];
				poll_write_register = poll_write_units[fetch_target_rs];
				poll_write_value = poll_write_value_units[fetch_target_rs];

				read1_enable = read1_enable_units[fetch_target_rs];
				read1_register = read1_register_units[fetch_target_rs];
				read2_enable = read2_enable_units[fetch_target_rs];
				read2_register = read2_register_units[fetch_target_rs];

				DoIssue = 1 << fetch_target_rs;
		end else begin
			QueuePolled = 'b0;

			poll_write_enable = 'b0;
			poll_write_register = '{ default: 'bX };
			poll_write_value = 'bX;

			read1_enable = 'b0;
			read1_register = 'bX;
			read2_enable = 'b0;
			read2_register = 'bX;

			DoIssue = 'b0;
		end

	int victim;
	bit is_retiring;

	always_comb begin
		is_retiring = 0;

		for (int i = 0; i < RS_COUNT; i++) begin
			if (ReadyToRetire[i]) begin
				victim = i;
				is_retiring = 'b1;
			end
		end

		if (is_retiring) begin
			retire_write_enable = retire_write_enable_units[victim];
			retire_write_register = retire_write_units[victim];
			retire_write_value = retire_write_value_units[victim];

			DoRetire = 'b1 << victim;
		end else begin
			retire_write_enable = 'b0;
			retire_write_register = 'bX;
			retire_write_value = 'bX;

			DoRetire = 'b0;
		end
	end
endmodule : Retirement_Arbiter