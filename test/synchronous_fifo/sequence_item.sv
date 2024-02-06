`include "uvm_macros.svh"

import uvm_pkg::*;

class synchronous_fifo_transaction extends uvm_sequence_item;
        `uvm_object_utils_begin(synchronous_fifo_transaction)
                `uvm_field_int ( rst,   UVM_DEFAULT )
                `uvm_field_int ( data_in, UVM_DEFAULT )
                `uvm_field_int ( push   , UVM_DEFAULT )
                `uvm_field_int ( poll_cnt, UVM_DEFAULT )
                `uvm_field_sarray_int ( data_out, UVM_DEFAULT )
        `uvm_object_utils_end

        rand bit rst;

        rand bit [DATA_WIDTH - 1:0] data_in;
        rand bit                    push;

        rand bit [$clog2(MULTI_POP):0] poll_cnt;

        bit [DATA_WIDTH-1:0] data_out [MULTI_POP];
        bit [$clog2(MULTI_POP) - 1:0] ready_cnt;

        function new ( string name = "synchronous_fifo_transaction" );
                super.new(name);
        endfunction

        constraint poll_constraint { poll_cnt <= ready_cnt; }
        constraint push_constraint { ready_cnt == (QUEUE_DEPTH - 1) -> push == 0; }
        constraint reset_rarely { rst dist { 1'b0 := 99, 1'b1 := 1 }; }
endclass
