// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2023, <COMPANY>
//
// Created : 31. Dec 2023 12:31 AM
//-------------------------------------------------------------------
import types::*;

module core #(parameter DATA_WIDTH = 64, FETCH_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic [15:0] max_instructions_i,
	output logic done_o,

	input logic dmem_busy_i,
	input logic imem_busy_i,

	input logic dmem_rdy_i,
	input logic imem_rdy_i,

	input logic [FETCH_WIDTH - 1:0] dmem_rd_data_i,
	input logic [FETCH_WIDTH - 1:0] imem_rd_data_i,

	output logic dmem_rd_en_o,
	output logic imem_rd_en_o,
	output logic dmem_wr_en_o,

	output logic [DATA_WIDTH - 1:0] dmem_addr_o,
	output logic [DATA_WIDTH - 1:0] imem_addr_o,

	output logic [$clog2(FETCH_WIDTH / 8) - 1:0] dmem_wr_size_o,
	output logic [FETCH_WIDTH - 1:0] dmem_wr_data_o
);
	logic [15:0]             issued_instruction_cnt;
	logic                    issue_en;
	logic                    issue_ifu_ready;
	logic [31:0]             issue_insn;
	logic                    issue_wr_en;
	operation_specification  issue_op;
	e_functional_unit        issue_rs;
	register                 issue_read1_value;
	register                 issue_read2_value;

	e_functional_unit        retire_rs;
	logic                    retire_en;
	logic                    bcast_valid;
	logic [DATA_WIDTH - 1:0] bcast_value;

	logic [FU_CNT - 1:0]  retirement_ready;
	logic [FU_CNT - 1:0]  station_busy;
	logic [DATA_WIDTH - 1:0] unit_results [FU_CNT];

	logic                    alu_rop1;
	logic                    alu_rop2;
	logic                    alu_done;
	logic                    alu_retirement_ready;
	logic                    alu_retire_en;
	operation_specification  alu_curr_op;
	logic [63:0]             alu_lhs;
	logic [63:0]             alu_rhs;
	logic [63:0]             alu_result;
	
	logic                    lsu_rop1;
	logic                    lsu_rop2;
	logic                    lsu_done;
	logic                    lsu_retirement_ready;
	logic                    lsu_retire_en;
	operation_specification  lsu_curr_op;
	logic [63:0]             lsu_addr;
	logic [63:0]             lsu_store_data;
	logic [63:0]             lsu_result;
	
	logic                    bu_rop1;
	logic                    bu_rop2;
	logic                    bu_done;
	logic                    bu_retirement_ready;
	logic                    bu_retire_en;
	operation_specification  bu_curr_op;
	logic [63:0]             bu_lhs;
	logic [63:0]             bu_rhs;
	logic [63:0]             bu_result;

	ifu #(DATA_WIDTH) ifu (
		.clk ( clk ),
		.rst ( rst ),

		.instruction_poll_i ( issue_en ),

		.bcast_valid_i ( bcast_valid ),
		.bcast_rs_i ( retire_rs ),
		.bcast_value_i ( bcast_value ),

		.fetch_ready_o ( issue_ifu_ready ),
		.fetch_insn_o ( issue_insn ),

		.imem_load_addr_o ( imem_addr_o ),
		.imem_load_en_o ( imem_rd_en_o ),
		.imem_load_insn_i ( imem_rd_data_i[63:32] ),
		.imem_load_busy_i ( imem_busy_i ),
		.imem_load_rdy_i ( imem_rdy_i )
	);

	instruction_decoder decoder (
		.instruction ( issue_insn ),
		.op ( issue_op ),
		.rs_id ( issue_rs )
	);

	register_file rf (
		.clk ( clk ),
		.rst ( rst ),

		.issue_wr_en_i ( issue_wr_en ),
		.issue_dst_i ( issue_op.rd ),
		.issue_rs_i ( issue_rs ),

		.bcast_valid_i ( bcast_valid ),
		.bcast_rs_i ( retire_rs ),
		.bcast_value_i ( bcast_value ),

		.read_reg1_i ( issue_op.rs1 ),
		.read_reg2_i ( issue_op.rs2 ),

		.read_value1_o ( issue_read1_value ),
		.read_value2_o ( issue_read2_value )
	);

	Retirement_Arbiter #(DATA_WIDTH) ra (
		.retirement_ready_i ( retirement_ready ),
		.unit_result_i ( unit_results ),

		.unit_retire_o ( retire_rs ),
		.retire_en_o ( retire_en ),
		.bcast_valid_o ( bcast_valid ),
		.bcast_value_o ( bcast_value )
	);

	`define RESERVATION_STATION(MODULE_NAME, ID, UNIT_DONE, CURR_OP, R_OPER1, R_OPER2, OPER1, OPER2) \
		reservation_station	#(DATA_WIDTH, ID) MODULE_NAME (                                          \
			.clk ( clk ),                                                                            \
			.rst ( rst ),                                                                            \
                                                                                                     \
			.read1_value_i ( issue_read1_value ),                                                    \
			.read2_value_i ( issue_read2_value ),                                                    \
                                                                                                     \
			.busy_o ( station_busy[ID] ),                                                            \
                                                                                                     \
			.issue_en_i ( issue_en && issue_rs == ID ),                                              \
			.issue_op_i ( issue_op ),                                                                \
                                                                                                     \
			.unit_done_i ( UNIT_DONE ),                                                              \
                                                                                                     \
			.resolved_op1_o ( R_OPER1 ),                                                             \
			.resolved_op2_o ( R_OPER2 ),                                                             \
                                                                                                     \
			.bcast_en_i ( bcast_valid ),                                                             \
			.bcast_data_i ( bcast_value ),                                                           \
			.bcast_rs_i ( retire_rs ),                                                               \
                                                                                                     \
			.retire_i ( retire_en && retire_rs == ID ),                                              \
			.retirement_ready_o ( retirement_ready[ID] ),                                            \
                                                                                                     \
			.current_op_o ( CURR_OP ),                                                               \
                                                                                                     \
			.op1_value_o ( OPER1 ),                                                                  \
			.op2_value_o ( OPER2 )                                                                   \
		);
	
	`RESERVATION_STATION(alu_rs, ALU, alu_done, alu_curr_op, alu_rop1, alu_rop2, alu_lhs, alu_rhs)
	alu alu (
		.lhs ( alu_lhs ),
		.rhs ( alu_rhs ),

		.lhs_valid ( alu_rop1 ),
		.rhs_valid ( alu_rop2 ),

		.op_spec ( alu_curr_op ),

		.result ( alu_result ),
		.result_valid ( alu_done )
	);

	`RESERVATION_STATION(lsu_rs, LSU, lsu_done, lsu_curr_op, lsu_rop1, lsu_rop2, lsu_addr, lsu_store_data)
	lsu #(DATA_WIDTH, FETCH_WIDTH) lsu (
		.clk ( clk ),
		.rst ( rst ),

		.addr_i ( lsu_addr ),
		.addr_valid_i ( lsu_rop1 ),

		.store_data_i ( lsu_store_data ),
		.store_data_valid_i ( lsu_rop2 ),

		.op_spec_i ( lsu_curr_op ),

		.result_o ( lsu_result ),
		.done_o ( lsu_done ),

		.dmem_busy_i ( dmem_busy_i ),
		.dmem_rdy_i ( dmem_rdy_i ),

		.dmem_rd_en_o ( dmem_rd_en_o ),
		.dmem_wr_en_o ( dmem_wr_en_o ),

		.dmem_addr_o ( dmem_addr_o ),

		.dmem_wr_size_o ( dmem_wr_size_o ),
		.dmem_wr_data_o ( dmem_wr_data_o ),
		.dmem_rd_data_i ( dmem_rd_data_i )
	);

	`RESERVATION_STATION(bu_rs, BU, bu_done, bu_curr_op, bu_rop1, bu_rop2, bu_lhs, bu_rhs)
	bu bu (
		.lhs ( bu_lhs ),
		.rhs ( bu_rhs ),

		.lhs_valid ( bu_rop1 ),
		.rhs_valid ( bu_rop2 ),

		.op_spec ( bu_curr_op ),

		.pc ( imem_addr_o ),

		.result ( bu_result ),
		.result_valid ( bu_done )
	);

	assign unit_results[LSU] = lsu_result;
	assign unit_results[ALU] = alu_result;
	assign unit_results[BU]  = bu_result;

	assign issue_en = issue_ifu_ready && !station_busy[issue_rs] && (issued_instruction_cnt < max_instructions_i);
	assign issue_wr_en = issue_en && has_rd(issue_op.encoding);

	assign done_o = issued_instruction_cnt == max_instructions_i && station_busy == 'b0;

	always_ff @ (posedge clk)
		if (rst) issued_instruction_cnt <= 0;
		else if (issue_en) issued_instruction_cnt <= issued_instruction_cnt + 1;
endmodule : core