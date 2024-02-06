`include "uvm_macros.svh"

import uvm_pkg::*;

class synchronous_fifo_env extends uvm_env;
     `uvm_component_utils(synchronous_fifo_env)

     synchronous_fifo_agent sa_agent;
     synchronous_fifo_scoreboard sa_sb;

     function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new

     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          sa_agent    = synchronous_fifo_agent::type_id::create("agent", this);
          sa_sb        = synchronous_fifo_scoreboard::type_id::create("scoreboard", this);
     endfunction: build_phase

     function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          sa_agent.agent_ap.connect(sa_sb.sb_export);
     endfunction: connect_phase
endclass: synchronous_fifo_env