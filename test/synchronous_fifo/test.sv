`include "uvm_macros.svh"
import uvm_pkg::*;

class synchronous_fifo_test extends uvm_test;
     `uvm_component_utils(synchronous_fifo_test)

     synchronous_fifo_env #(
		.DATA_WIDTH ( DATA_WIDTH ),
		.QUEUE_DEPTH ( QUEUE_DEPTH ),
		.MULTI_POP ( MULTI_POP )
	) sa_env;

     function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new

     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          sa_env = synchronous_fifo_env::type_id::create("env", this);
     endfunction: build_phase

     task run_phase(uvm_phase phase);
          synchronous_fifo_sequence sa_seq;

          phase.raise_objection(.obj(this));
               sa_seq = synchronous_fifo_sequence::type_id::create("seq", this);
               assert(sa_seq.randomize());
               sa_seq.start(sa_env.sa_agent.sa_seqr);
          phase.drop_objection(.obj(this));
     endtask: run_phase
endclass: synchronous_fifo_test
