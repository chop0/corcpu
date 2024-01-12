`timescale 1ns / 1ps

import types::*;

	module reservation_station
	#(parameter int DATA_WIDTH, int RS_ID)
	(
		input logic clk,
		input logic rst,
		
		// selected when DoIssue
		output logic poll_write_enable,
		output logic [4:0] poll_write,
		output register poll_write_value,
		
		// selected when DoIssue
		output logic read1_enable, read2_enable,
		output logic [4:0] read1, read2,
		input register read1_value, read2_value,
		
		// selected when DoRetire
		output logic retire_write_enable,
		output logic [4:0] retire_write,
		output register retire_write_value,

		output logic Busy, // us->ifu
		output logic ResolvedOp1, // us->unit
		output logic ResolvedOp2, // us->unit

		input logic UnitDone, // unit->us

		input operation_specification issue_op, // ifu->us

		input logic CDB_valid, // cdb arbiter->us
		input logic [DATA_WIDTH-1:0] CDB_result, // cdb arbiter->us
		input logic [2:0] CDB_rs_id, // cdb arbiter->us

		input logic DoIssue,
		input logic DoRetire,
		input logic IsCancelled
	);
	enum {
		ISSUE,
		WAITING
	} state;


	assign ReadyToRetire = state == WAITING && UnitDone;
	assign Busy = DoIssue || state != ISSUE;

	logic op_has_rd;
	logic [4:0] op_rd;

	register j, k;

	always_comb begin
		assert (!DoRetire || state == WAITING);
		assert (!DoIssue || state == ISSUE);
		assert (!IsCancelled || state == WAITING);
	
		// if instruction I_r computing register R is retired at the same time another instruction I_i computing R is issued, the
		// RS retiring I_r still broadcasts to the CDB, so any units (whose instructions must've been issued before I_i)
		// get the old value of R they needed.  I_r's value of R never gets written back to the register file;  I_i should be able
		// to mark R as virtual.  Therefore, poll_write must take precedence over retire_write.
		unique casex ({ state, DoIssue, DoRetire })
			{ISSUE, 1'b1, 1'bx} : begin
				poll_write_enable = issue_op.has_rd;
				poll_write = issue_op.rd;
				poll_write_value.is_virtual = 1;
				poll_write_value.data.rs_id = RS_ID;

				retire_write_enable = 'X;
				retire_write = 'X;
				retire_write_value = '{ default: 'X };

				read1_enable = issue_op.has_rs1;
				read2_enable = issue_op.has_rs2;
				read1 = issue_op.rs1;
				read2 = issue_op.rs2;
			end

			{WAITING, 1'bx, 1'b1} : begin
				assert (ReadyToRetire);
				
				poll_write_enable = 'X;
				poll_write = 'X;
				poll_write_value = '{ default: 'X };

				assert (op_has_rd == (CDB_valid && CDB_rs_id == RS_ID));
				// race:  instruction cancelled on the same cycle that the instruction was selected to be retired.  do not write back.
				retire_write_enable = IsCancelled ? 1'b0 : op_has_rd;
				retire_write = op_rd;
				retire_write_value.is_virtual = 1'b0;
				retire_write_value.data.value = CDB_result;

				read1_enable = 'X;
				read2_enable = 'X;
				read1 = 'X;
				read2 = 'X;
			end
			
			default : begin
				poll_write_enable = 'X;
				poll_write = 'X;
				poll_write_value = '{ default: 'X };

				retire_write_enable = 'X;
				retire_write = 'X;
				retire_write_value = '{ default: 'X };

				read1_enable = 'X;
				read2_enable = 'X;
				read1 = 'X;
				read2 = 'X;
			end		
		endcase
	end

	always_ff @(posedge clk) begin
		if (rst)
			state <= ISSUE;
		else case (state)
			ISSUE : if (DoIssue) begin
				// if an instruction computing one of our operands is currently being retired, we need to catch that now, since it'll be gone by
				// the next cycle
				if (issue_op.has_rs1) begin
					if (read1_value.is_virtual && CDB_valid && read1_value.data.rs_id == CDB_rs_id) begin
						j.is_virtual <= 1'b0;
						j.data.value <= CDB_result;
					end else begin
						j <= read1_value;
					end
				end else j.is_virtual <= 1'b0;

				if (issue_op.has_rs2) begin
					if (read2_value.is_virtual && CDB_valid && read2_value.data.rs_id == CDB_rs_id) begin
						k.is_virtual <= 1'b0;
						k.data.value <= CDB_result;
					end else begin
						k <= read2_value;
					end
				end else k.is_virtual <= 1'b0;
				
				ResolvedOp1 <= !issue_op.has_rs1 || !read1_value.is_virtual || (CDB_valid && read1_value.data.rs_id == CDB_rs_id);
				ResolvedOp2 <= !issue_op.has_rs2 || !read2_value.is_virtual || (CDB_valid && read2_value.data.rs_id == CDB_rs_id);

				op_has_rd = issue_op.has_rd;
				op_rd = issue_op.rd;

				state <= WAITING;
			end
		
			WAITING : begin
				if (CDB_valid) begin
					if (j.is_virtual && j.data.rs_id == CDB_rs_id) begin
						assert (!ResolvedOp1);
					
						j.is_virtual <= 1'b0;
						j.data.value <= CDB_result;
						ResolvedOp1 <= 1'b1;
					end

					if (k.is_virtual && k.data.rs_id == CDB_rs_id) begin
						assert (!ResolvedOp2);
					
						k.is_virtual <= 1'b0;
						k.data.value <= CDB_result;
						ResolvedOp2 <= 1'b1;
					end
				end
				
				if (DoRetire || IsCancelled) begin // sometimes, BOTH of these may be true -- this doesn't need special handling here, but it is explicitly dealt with in the combinational logic
					state <= ISSUE;
					ResolvedOp1 <= 1'b0;
					ResolvedOp2 <= 1'b0;
				end
			end
		endcase
	end
endmodule
