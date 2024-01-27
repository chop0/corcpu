`timescale 1ns / 1ps
module synchronous_fifo_tb(input logic clk, input logic rst, input logic en);
	parameter DEPTH=4, DATA_WIDTH=2;
	parameter BEGIN_VECTOR = 0, END_VECTOR = 0;

	reg push, poll;
	reg [DATA_WIDTH-1:0] data_in;

	synchronous_fifo #(DEPTH, DATA_WIDTH) dut (
		.clk(clk),
		.rst(rst),
		.push(push),
		.poll(poll),
		.data_in(data_in),

		.head ( ),
		.tail ( ),

		.full ( ),
		.empty ( )
	);

	synchronous_fifo_behavioural #(DEPTH, DATA_WIDTH) behavioural (
		.clk(clk),
		.rst(rst),
		.push(push),
		.poll(poll),
		.data_in(data_in),

		.head ( ),
		.tail ( ),
		.full ( ),
		.empty ( )
	);

	always_ff @ (posedge(clk)) if (rst) begin
		push <= 0;
		poll <= 0;
		data_in <= 0;
	end

	always_ff @ (posedge(clk)) if (!rst) begin
		push <= $urandom;
		poll <= $urandom;
		data_in <= $urandom;
	end

	always_ff @ (posedge(clk)) if (en) begin
		if ((!dut.empty & (dut.head !== behavioural.head)) || (!dut.empty & (dut.tail !== behavioural.tail)) || (dut.full !== behavioural.full) || (dut.empty !== behavioural.empty)) begin
		  $display("--- Mismatch found ---");

		  $display("DUT       : head=%h, tail=%h, full=%b, empty=%b", dut.head, dut.tail, dut.full, dut.empty);
		  $display("Behavioral: head=%h, tail=%h, full=%b, empty=%b", behavioural.head, behavioural.tail, behavioural.full, behavioural.empty);
		  $finish();
		end
	end
endmodule
