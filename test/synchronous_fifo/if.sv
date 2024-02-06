`timescale 1ns / 1ps


interface synchronous_fifo_if #(
	parameter int DATA_WIDTH = 8,
	parameter int QUEUE_DEPTH = 4,
	parameter int MULTI_POP = 2
);
	bit clk;
	logic rst;

	logic push;
	logic [$clog2(MULTI_POP):0] poll_cnt;
	
	logic [DATA_WIDTH-1:0] data_in;

	logic [DATA_WIDTH-1:0] data_out [MULTI_POP];
	logic [$clog2(MULTI_POP):0] ready_cnt;
	
	logic full;
endinterface
