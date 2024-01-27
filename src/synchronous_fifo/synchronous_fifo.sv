`timescale 1ns / 1ps

module synchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
	input logic clk, rst,
	input logic push, poll,
	input logic [DATA_WIDTH-1:0] data_in,

	output logic [DATA_WIDTH-1:0] head,
	output logic [DATA_WIDTH-1:0] tail,

	output logic full, empty
);
	
	reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
	reg [DATA_WIDTH-1:0] fifo[DEPTH];
	
	always_ff @(posedge clk) begin
	    if(rst) begin
            w_ptr <= 0; r_ptr <= 0;
	    end

		if(!rst && push & !full)begin
			fifo[w_ptr] <= data_in;
			w_ptr <= w_ptr + 1;
		end

		if(!rst && poll && !empty) begin
			r_ptr <= r_ptr + 1;
		end
	end

	assign head = fifo[r_ptr];
	assign tail = fifo[w_ptr == 0 ? DEPTH - 1 : w_ptr - 1];
	
	assign full = ((w_ptr+1'b1) == r_ptr);
	assign empty = (w_ptr == r_ptr);
endmodule
