`include "uvm_macros.svh"
import uvm_pkg::*;

class synchronous_fifo_agent extends uvm_agent;
	typedef uvm_sequencer#(synchronous_fifo_transaction) synchronous_fifo_sequencer;
	
     `uvm_component_utils(synchronous_fifo_agent)

     //Analysis ports to connect the monitors to the scoreboard
     uvm_analysis_port#(synchronous_fifo_transaction) agent_ap;

     synchronous_fifo_sequencer        sa_seqr;
     synchronous_fifo_driver        sa_drvr;
     synchronous_fifo_monitor    sa_mon;

     function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new

     function void build_phase(uvm_phase phase);
          super.build_phase(phase);

          agent_ap    = new(.name("agent_ap"), .parent(this));

          sa_seqr        = synchronous_fifo_sequencer::type_id::create("sequencer", this);
          sa_drvr        = synchronous_fifo_driver::type_id::create("driver", this);
          sa_mon    = synchronous_fifo_monitor::type_id::create("monitor", this);
     endfunction: build_phase

     function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          sa_drvr.seq_item_port.connect(sa_seqr.seq_item_export);
          sa_mon.mon_ap.connect(agent_ap);
     endfunction: connect_phase
endclass: synchronous_fifo_agent