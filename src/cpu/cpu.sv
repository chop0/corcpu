// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2023, <COMPANY>
//
// Created : 31. Dec 2023 12:31 AM
//-------------------------------------------------------------------
module cpu (
    input logic clk,
    input logic rst
);
	logic instruction_poll;

	logic [2:0] ReadyToRetire;


	logic cdb_valid;
    logic [2:0] cdb_rs_id;
    logic [63:0] cdb_result;

	Retirement_Arbiter ra;
	register_file rf (
		.clk(clk),
		.rst(rst)
	);


    CDB_Arbiter #(64, 3) cdb (
    	.clk(clk),
		.rst(rst),
		
		.valid ( cdb_valid ),
		.rs_id ( cdb_rs_id ),
		.result ( cdb_result )
    );

	IFU ifu (
		.clk ( clk ),
		.rst ( rst ),

		.instruction_poll ( instruction_poll ),
		
		.CDB_valid ( cdb_valid ),
		.CDB_rs_id ( cdb_rs_id ),
		.CDB_result ( cdb_result ),

		.instruction ( ),
		.instruction_valid ( )
	);

    instruction_issuer issuer(
    	.clk(clk),
    	.rst(rst),

		.instruction ( ifu.instruction ),
		.instruction_valid ( ifu.instruction_valid ),

		.issue_bus ( )
    );

	`define RS_PARAMS(rid, rop1, rop2, done) \
		( \
				.clk(clk), \
				.rst(rst), \
	 \
				.poll_write ( rf.write1 ), \
				.retire_write ( rf.write2 ), \
				.poll_write_enable ( rf.write1_enable ), \
				.retire_wire_enable ( rf.write2_enable ), \
				.poll_write_value ( rf.write1_value ), \
				.retire_write_value ( rf.write2_value ), \
	 \
				.read1 ( rf.read1 ), \
				.read2 ( rf.read2 ), \
				.read1_enable ( rf.read1_enable ), \
				.read2_enable ( rf.read2_enable ), \
				.read1_value ( rf.read1_value ), \
				.read2_value ( rf.read2_value ), \
	 \
				.Busy ( ia.Busy[rid] ), \
				.ResolvedOp1 ( rop1 ), \
				.ResolvedOp2 ( rop2 ), \
				.UnitDone ( done ), \
	 \
				.issue_op (
	 \
				.CDB_valid ( cdb_valid ), \
				.CDB_rs_id ( cdb_rs_id ), \
				.CDB_result ( cdb_result ), \
	 \
				.InstructionPolled ( instruction_poll ) \
			);

	bu bu (
			.clk(clk),
			.rst(rst),

			.write1 ( rf.write1 ),
			.write2 ( rf.write2 ),
			.write1_enable ( rf.write1_enable ),
			.write2_enable ( rf.write2_enable ),
			.write1_value ( rf.write1_value ),
			.write2_value ( rf.write2_value ),

			.read1 ( rf.read1 ),
			.read2 ( rf.read2 ),
			.read1_enable ( rf.read1_enable ),
			.read2_enable ( rf.read2_enable ),
			.read1_value ( rf.read1_value ),
			.read2_value ( rf.read2_value ),

			.issue_bus ( issuer.issue_bus ),

			.Retire ( cdb.retiring_stations[BU] ),
			.result_valid ( cdb.fu_status[BU] ),
			.result ( cdb.fu_results[BU] ),

			.CDB_valid ( cdb_valid ),
			.CDB_rs_id ( cdb_rs_id ),
			.CDB_result ( cdb_result ),

			.InstructionPolled ( instruction_poll )
		);
endmodule : cpu