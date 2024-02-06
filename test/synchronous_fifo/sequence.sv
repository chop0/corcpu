`include "uvm_macros.svh"

class synchronous_fifo_sequence extends uvm_sequence #(synchronous_fifo_transaction);
     `uvm_object_utils(synchronous_fifo_sequence)

     function new(string name = "synchronous_fifo_sequence");
          super.new(name);
     endfunction: new

          synchronous_fifo_transaction sa_tx;
     task body();

          repeat(1000) begin
               sa_tx = synchronous_fifo_transaction::type_id::create("synchronous_fifo_transaction", null);

               start_item(sa_tx);
                    assert(sa_tx.randomize());
               finish_item(sa_tx);
          end
     endtask: body
endclass: synchronous_fifo_sequence