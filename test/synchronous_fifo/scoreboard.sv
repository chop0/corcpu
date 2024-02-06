`include "uvm_macros.svh"
import uvm_pkg::*;

class synchronous_fifo_scoreboard extends uvm_scoreboard;
	`uvm_component_utils ( synchronous_fifo_scoreboard );

	uvm_analysis_export #(synchronous_fifo_transaction) sb_export;
	uvm_tlm_analysis_fifo #(synchronous_fifo_transaction) fifo;

	synchronous_fifo_transaction tx;
	logic [DATA_WIDTH - 1:0] queue [$:QUEUE_DEPTH - 1];

     function new(string name, uvm_component parent);
          super.new(name, parent);
          tx    = new("transaction");
     endfunction: new

     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          sb_export    = new("sb_export", this);
          fifo        = new("fifo", this);
     endfunction: build_phase

     function void connect_phase(uvm_phase phase);
          sb_export.connect(fifo.analysis_export);
     endfunction: connect_phase

	virtual task run_phase(uvm_phase phase);
		forever begin
				fifo.get(tx);
				if (!check_matches())
					`uvm_error("check_mathces", $sformatf("Test: Fail! tx: %p", tx));
				apply_tx();
		end
	endtask: run_phase

	virtual function void apply_tx();
		bit ok = 1;
		
		if (tx.rst) begin
          	queue = {};          	
		end else begin
			for (int i = 0; i < tx.poll_cnt; i++)
				queue.pop_front();
					
				if (tx.push && queue.size() < QUEUE_DEPTH)
					queue.push_back(tx.data_in);
          end
     endfunction: apply_tx

	virtual function bit check_matches();
		bit ok = 1;
		ok &= queue.size() == tx.ready_cnt;
		if (!ok)
			$display("dut size %p, q size %p", tx.ready_cnt, queue.size());
		
		for (int i = 0; i < MULTI_POP; i++) begin
			if (i >= tx.ready_cnt)
				break;
				
			ok &= queue[i] == tx.data_out[i];
		end
		
		return ok;
	endfunction : check_matches

endclass : synchronous_fifo_scoreboard