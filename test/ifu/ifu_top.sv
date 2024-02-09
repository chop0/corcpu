`include "uvm_macros.svh"
`include "classes.v"

package ifu_tb;

import ifu_tb::*;
import uvm_pkg::*;

module ifu_top;

	localparam DATA_WIDTH = 64;
	localparam MULTI_ISSUE = 3;

	
	ifu_if #(
		.DATA_WIDTH ( DATA_WIDTH ),
		.MULTI_ISSUE ( MULTI_ISSUE )
	) ifu_if();
	
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
          	.name ( "ifu_if" ), 
          	.val ( sfi )
          );

          run_test();
     end
endmodule
endpackage