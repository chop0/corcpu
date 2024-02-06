`include "uvm_macros.svh"

import uvm_pkg::*;

module synchronous_fifo_top;

	localparam DATA_WIDTH = 8;
	localparam QUEUE_DEPTH = 3;
	localparam MULTI_POP = 3;

	`include "sequence_item.sv"
	`include "scoreboard.sv"
	
	`include "monitor.sv"
	`include "driver.sv"
	`include "agent.sv"
	`include "env.sv"
	`include "sequence.sv"
	
	`include "test.sv"

	
	synchronous_fifo_if #(
		.DATA_WIDTH ( DATA_WIDTH ),
		.QUEUE_DEPTH ( QUEUE_DEPTH ),
		.MULTI_POP ( MULTI_POP )
	) sfi();
	
	synchronous_fifo #(
		.DATA_WIDTH ( DATA_WIDTH ),
		.DEPTH ( QUEUE_DEPTH ),
		.MULTI_POP ( MULTI_POP )
	) dut (
		.clk ( sfi.clk ),
		.rst ( sfi.rst ),
		
		.push ( sfi.push ),
		.poll_cnt ( sfi.poll_cnt ),
		
		.data_in ( sfi.data_in ),
		.data_out ( sfi.data_out ),
		
		.ready_cnt ( sfi.ready_cnt ),
		.full ( sfi.full )
	);
	
	initial sfi.clk = 1'b1;
	always #5 sfi.clk = !sfi.clk;
	
	initial begin
          uvm_resource_db #( virtual synchronous_fifo_if #(
			.DATA_WIDTH ( DATA_WIDTH ),
			.QUEUE_DEPTH ( QUEUE_DEPTH ),
			.MULTI_POP ( MULTI_POP )
		))::set(
          	.scope ( "ifs" ), 
          	.name ( "synchronous_fifo_if" ), 
          	.val ( sfi )
          );

          run_test("synchronous_fifo_test");
     end
endmodule
