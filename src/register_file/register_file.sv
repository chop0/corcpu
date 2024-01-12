`timescale 1ns / 1ps
import types::*;

// on contention, write1 wins
module register_file #(parameter DATA_WIDTH = 64) (
		wire clk,
		wire rst,
		
		input logic [4:0] write1,
		input logic [4:0] write2,
		input logic [4:0] read1,
		input logic [4:0] read2,
		input logic write1_enable, write2_enable, read1_enable, read2_enable,
		
		input register write1_value,
		input register write2_value,
		output register read1_value,
		output register read2_value
	);

	register registers [31:0];

	assign read1_value = registers[read1];
	assign read2_value = registers[read2];

	always_ff @(posedge(clk)) begin
		if (rst)
			for (int i = 0; i < 32; i++) begin
				registers[i].is_virtual <= 1'b0;
				registers[i].data.value <= 0;
			end
		else begin
			if (write1_enable)
				registers[write1] <= write1_value;
			if (write2_enable && (!write1_enable || write1 != write2))
				registers[write2] <= write2_value;
		end
	end

endmodule : register_file
