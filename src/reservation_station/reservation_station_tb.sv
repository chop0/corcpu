// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2024, <COMPANY>
//
// Created : 22. Jan 2024 6:30 PM
//-------------------------------------------------------------------
`timescale 1ns / 1ps
`include "types.sv"
import types::*;

// verilator lint_off PINMISSING
module reservation_station_tb (input logic clk, input logic rst, input logic en);
	localparam DATA_WIDTH = 64;
	localparam RS_ID = ALU;

	register read1_value, read2_value;

	logic issue_en;
	e_functional_unit issue_target;
	operation_specification issue_op;

	logic unit_done;

	logic bcast_en;
	logic [DATA_WIDTH-1:0] bcast_data;
	e_functional_unit bcast_rs;

	logic retire_i;

	reservation_station #(
		.DATA_WIDTH(DATA_WIDTH),
		.RS_ID(RS_ID)
	) dut (
		.clk ( clk ),
		.rst ( rst ),

		.read1_value_i ( read1_value ),
		.read2_value_i ( read2_value ),

		.issue_en_i ( issue_en ),
		.issue_op_i ( issue_op ),

		.unit_done_i ( unit_done ),

		.bcast_en_i ( bcast_en ),
		.bcast_data_i ( bcast_data ),
		.bcast_rs_i ( bcast_rs ),

		.retire_i ( retire_i )
	);

	reservation_station_behavioural #(
		.DATA_WIDTH(DATA_WIDTH),
		.RS_ID(RS_ID)
	) behavioural (
		.clk ( clk ),
		.rst ( rst ),

		.read1_value_i ( read1_value ),
		.read2_value_i ( read2_value ),

		.issue_en_i ( issue_en ),
		.issue_op_i ( issue_op ),

		.unit_done_i ( unit_done ),

		.bcast_en_i ( bcast_en ),
		.bcast_data_i ( bcast_data ),
		.bcast_rs_i ( bcast_rs ),

		.retire_i ( retire_i )
	);

	always_ff @(posedge clk) if (en) begin
		`define ASSERT_EQ(a, b) if (en & (a !== b)) begin \
			$display("mismatch between DUT and behavioural RS model"); \
			$display("DUT busy_o = %b", dut.busy_o); \
			$display("BHV busy_o = %b", behavioural.busy_o); \
			$display("DUT resolved_op1_o = %b", dut.resolved_op1_o); \
			$display("BHV resolved_op1_o = %b", behavioural.resolved_op1_o); \
			$display("DUT resolved_op2_o = %b", dut.resolved_op2_o); \
			$display("BHV resolved_op2_o = %b", behavioural.resolved_op2_o); \
			$display("DUT retirement_ready_o = %b", dut.retirement_ready_o); \
			$display("BHV retirement_ready_o = %b", behavioural.retirement_ready_o); \
			$display("DUT current_op_o = %s", dut.current_op_o); \
			$display("BHV current_op_o = %s", behavioural.current_op_o); \
			$display("DUT op1_value_o = %s", dut.op1_value_o); \
			$display("BHV op1_value_o = %s", behavioural.op1_value_o); \
			$display("DUT op2_value_o = %s", dut.op2_value_o); \
			$display("BHV op2_value_o = %s", behavioural.op2_value_o); \
			$finish; \
		end

		`ASSERT_EQ(dut.busy_o, behavioural.busy_o);
		`ASSERT_EQ(dut.retirement_ready_o, behavioural.retirement_ready_o);

		if (dut.busy_o) begin
			`ASSERT_EQ(dut.resolved_op1_o, behavioural.resolved_op1_o);
			`ASSERT_EQ(dut.resolved_op2_o, behavioural.resolved_op2_o);
			`ASSERT_EQ(dut.current_op_o, behavioural.current_op_o);

			if (dut.resolved_op1_o)
				`ASSERT_EQ(dut.op1_value_o, behavioural.op1_value_o);

			if (dut.resolved_op2_o)
				`ASSERT_EQ(dut.op2_value_o, behavioural.op2_value_o);
		end
	end

	always_ff @(posedge clk) if (rst) begin
		read1_value.is_virtual <= 1'b0;
		read1_value.data.value <= 0;
		read2_value.is_virtual <= 1'b0;
		read2_value.data.value <= 0;

		issue_en <= 1'b0;
		issue_target <= e_functional_unit'(0);
		issue_op <= '{ encoding: R_FORMAT, default: 0 };

		unit_done <= 1'b0;

		bcast_en <= 1'b0;
		bcast_data <= 0;
		bcast_rs <= e_functional_unit'(0);

		retire_i <= 1'b0;
	end

	always_ff @(posedge clk) if (!rst) begin
		if ($urandom & 1'b1) begin
			read1_value.is_virtual <= 1'b1;
			read1_value.data.rs_id <= e_functional_unit'($urandom % FU_CNT);
		end else begin
			read1_value.is_virtual <= 1'b0;
			read1_value.data.value <= $urandom;
		end

		if ($urandom & 1'b1) begin
			read2_value.is_virtual <= 1'b1;
			read2_value.data.rs_id <= e_functional_unit'($urandom % FU_CNT);
		end else begin
			read2_value.is_virtual <= 1'b0;
			read2_value.data.value <= $urandom;
		end

		issue_en <= $urandom & ~dut.busy_o;
		issue_target <= e_functional_unit'($urandom % FU_CNT);
		issue_op <= '{
			opcode: $urandom,
			encoding: e_instruction_format'($urandom % INSN_FMT_CNT),
			rs1: $urandom,
			funct3: $urandom,
			rs2: $urandom,
			funct7: $urandom,
			rd: $urandom,
			imm: $urandom
		};

		unit_done <= $urandom & 1'b1;

		bcast_en <= $urandom & 1'b1;
		bcast_data <= $urandom;
		bcast_rs <= e_functional_unit'($urandom % FU_CNT);

		retire_i <= $urandom & dut.retirement_ready_o;
	end

endmodule : reservation_station_tb