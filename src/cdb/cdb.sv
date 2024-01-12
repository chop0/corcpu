`timescale 1ns / 1ps
import types::*;

module CDB_Arbiter #(parameter DATA_WIDTH = 64, FUNCTIONAL_UNIT_COUNT = 3) (
	input logic [FUNCTIONAL_UNIT_COUNT - 1:0] fu_status,
	input logic [DATA_WIDTH - 1 : 0] fu_results [FUNCTIONAL_UNIT_COUNT],
	output logic [FUNCTIONAL_UNIT_COUNT - 1:0] retiring_stations,

	input logic should_dispatch,
	input logic [$clog2(FUNCTIONAL_UNIT_COUNT) - 1:0] victim,

	output logic valid,
	output logic [2:0] rs_id,
	output logic [DATA_WIDTH - 1:0] result
);
	always_comb begin
		retiring_stations = should_dispatch ? (1 << victim) : 'b0;

		valid = should_dispatch;
		rs_id = should_dispatch ? victim : 'X;
		result = should_dispatch ? fu_results[victim] : 'X;
	end
endmodule : CDB_Arbiter