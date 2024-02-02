`timescale 1ns / 1ps
module synchronous_fifo_tb(input logic clk, input logic rst, input logic en);
	parameter DEPTH=4, DATA_WIDTH=8, MULTI_POP = 3;

 	logic push;
	logic [$clog2(MULTI_POP):0] poll_cnt;
	
	logic [DATA_WIDTH-1:0] data_in;

	logic [DATA_WIDTH-1:0] data_out_dut [MULTI_POP];
	logic [$clog2(MULTI_POP):0] ready_cnt_dut;
	logic full_dut;

	logic [DATA_WIDTH-1:0] data_out_behav [MULTI_POP];
	logic [$clog2(MULTI_POP):0] ready_cnt_behav;
	logic full_behav;
	
	synchronous_fifo #(
		.DEPTH ( DEPTH ), 
		.DATA_WIDTH ( DATA_WIDTH ),
		.MULTI_POP ( MULTI_POP)
	) dut (
		.clk(clk),
		.rst(rst),
		
		.push(push),
		.poll_cnt ( poll_cnt ),
		.data_in(data_in),

		.data_out ( data_out_dut ),
		.ready_cnt ( ready_cnt_dut ),
		.full ( full_dut )
	);

	synchronous_fifo_behavioural #(
		.DEPTH ( DEPTH ), 
		.DATA_WIDTH ( DATA_WIDTH ),
		.MULTI_POP ( MULTI_POP)
	) behavioural (
		.clk(clk),
		.rst(rst),
		
		.push(push),
		.poll_cnt ( poll_cnt ),
		.data_in(data_in),

		.data_out ( data_out_behav ),
		.ready_cnt ( ready_cnt_behav ),
		.full ( full_behav )
	);
	
	logic mismatch;
	
	always_comb begin
		mismatch = 1'b0;
		mismatch |= ready_cnt_dut != ready_cnt_behav;
		mismatch |= full_dut != full_behav;
			
		for (int i = 0; i < ready_cnt_dut; i++) 
			mismatch |= data_out_dut[i] != data_out_behav[i];
	end
	
	always_ff @ (posedge(clk)) if (en) begin
		push <= $urandom_range(0, dut.full);
		poll_cnt <= $urandom_range(0, ready_cnt_dut);
		data_in <= $urandom;
		
		if (en && mismatch) begin
			$display("push = %p", push);
			$display("poll_cnt = %p", poll_cnt);
			$display("data_in = %p", data_in);
			
			$display("data_out_dut = %p", data_out_dut);
			$display("data_out_behavioural = %p", data_out_behav);
			
			$display("ready_cnt_dut = %p", ready_cnt_dut);
			$display("ready_cnt_behavioural = %p", ready_cnt_behav);
			
			$display("full_dut = %p", full_dut);
			$display("full_behavioural = %p", full_behav);
			
			$fatal(1, "Mismatch detected between behavioural and dut fifo");
		end
	end
	
	always_ff @ (posedge(clk)) if (rst) begin
		push <= 0;
		poll_cnt <= 0;
		data_in <= 0;
	end
endmodule
