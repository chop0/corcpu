`timescale 1ns / 1ps
import types::*;

module CDB_Arbiter_Behavioural #(parameter DATA_WIDTH = 64, FUNCTIONAL_UNIT_COUNT = 3) (
	input logic fu_status [FUNCTIONAL_UNIT_COUNT - 1:0] ,
	input logic [DATA_WIDTH - 1 : 0] fu_results [FUNCTIONAL_UNIT_COUNT],
	output logic [FUNCTIONAL_UNIT_COUNT - 1:0] retiring_stations,

	output logic valid,
	output logic [2:0] rs_id,
	output logic [DATA_WIDTH - 1:0] result
);
	int tmp[$];

	always_comb begin
		tmp = (fu_status.find_first_index with (item == 1'b1));
		valid = tmp.size() > 0;
		rs_id = valid ? tmp[0] : 'bx;
		result = valid ? fu_results[rs_id] : 'bx;
		retiring_stations = valid ? (1 << rs_id) : 'bx;
	end
endmodule : CDB_Arbiter_Behavioural