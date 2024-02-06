`include "uvm_macros.svh"
import uvm_pkg::*;

class synchronous_fifo_driver extends uvm_driver #(synchronous_fifo_transaction);
  `uvm_component_utils(synchronous_fifo_driver)
  
	protected virtual synchronous_fifo_if #(
		.DATA_WIDTH ( DATA_WIDTH ),
		.QUEUE_DEPTH ( QUEUE_DEPTH ),
		.MULTI_POP ( MULTI_POP )
	) sfif;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		void'(uvm_resource_db #(virtual synchronous_fifo_if#(
		.DATA_WIDTH ( DATA_WIDTH ),
		.QUEUE_DEPTH ( QUEUE_DEPTH ),
		.MULTI_POP ( MULTI_POP )
	))
			::read_by_name(
				.scope ( "ifs" ),
				.name( "synchronous_fifo_if" ), 
				.val ( sfif )
			));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
          synchronous_fifo_transaction transaction;
          super.run_phase(phase);
          
          @(posedge sfif.clk);
          sfif.rst = 1;
          @(posedge sfif.clk);
          sfif.rst = 0;
          
          forever begin          	
          	seq_item_port.get_next_item(transaction);
          	drive(transaction);
          	seq_item_port.item_done();
          end
	endtask: run_phase

	virtual task drive ( synchronous_fifo_transaction transaction );
		integer counter = 0;
		
		@(negedge sfif.clk);
		sfif.rst = transaction.rst;
		sfif.push = transaction.push;
		sfif.poll_cnt = transaction.poll_cnt;
		sfif.data_in = transaction.data_in;
		
		@(posedge sfif.clk);
	endtask
endclass