`timescale 1ns / 1ps
import types::*;

module register_file #(parameter DATA_WIDTH = 64) (
		input logic clk,
		input logic rst,

		input logic issue_wr_en_i,
		input logic [4:0] issue_dst_i,
		input e_functional_unit issue_rs_i,

		input logic bcast_valid_i,
		input logic [DATA_WIDTH - 1:0] bcast_value_i,
		input e_functional_unit bcast_rs_i,

		input logic [4:0] read_reg1_i, read_reg2_i,

		output register read_value1_o, read_value2_o
	);

	register registers [32];

	assign read_value1_o = registers[read_reg1_i];
	assign read_value2_o = registers[read_reg2_i];

	always_ff @(posedge(clk)) begin
		if (rst)
			for (int i = 0; i < 32; i++) begin
				registers[i].is_virtual <= 1'b0;
				registers[i].data.value <= 0;
			end
		else begin
			if (bcast_valid_i) begin
				for (int i = 0; i < 32; i++) begin
					if (registers[i].is_virtual && registers[i].data.rs_id == bcast_rs_i) begin
						registers[i].is_virtual <= 1'b0;
						registers[i].data.value <= bcast_value_i;
					end
				end
			end

			if (issue_wr_en_i) begin
				registers[issue_dst_i].is_virtual <= 1'b1;
				registers[issue_dst_i].data.rs_id <= issue_rs_i;
			end
		end
	end

endmodule : register_file
