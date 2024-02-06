import uvm_pkg::*;

class synchronous_fifo_monitor extends uvm_monitor;
	`uvm_component_utils(synchronous_fifo_monitor)
	
	uvm_analysis_port #(synchronous_fifo_transaction) mon_ap;
	
	virtual synchronous_fifo_if #(
			.DATA_WIDTH ( DATA_WIDTH ),
			.QUEUE_DEPTH ( QUEUE_DEPTH ),
			.MULTI_POP ( MULTI_POP )
		) sfif;
	synchronous_fifo_transaction tx;
	
	covergroup synchronous_fifo_cg;
		rst_cp : coverpoint tx.rst;
		wr_cp  : coverpoint tx.push;
		poll_cp : coverpoint tx.poll_cnt;
		
		cross rst_cp, wr_cp, poll_cp;
	endgroup: synchronous_fifo_cg
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
		synchronous_fifo_cg = new;
		tx = new;
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual synchronous_fifo_if#(
			.DATA_WIDTH ( DATA_WIDTH ),
			.QUEUE_DEPTH ( QUEUE_DEPTH ),
			.MULTI_POP ( MULTI_POP )
		))
			::read_by_name(.scope("ifs"), .name("synchronous_fifo_if"), .val(sfif)));
		mon_ap= new(.name("mon_ap"), .parent(this));
	endfunction: build_phase

	virtual task run_phase (uvm_phase phase);
		super.run_phase(phase);
		@(posedge sfif.clk);
		
		forever begin
			tx.rst = sfif.rst;
			tx.push = sfif.push;
			tx.poll_cnt = sfif.poll_cnt;
			tx.data_in = sfif.data_in;
			
			@(posedge sfif.clk);
						
			tx.data_out = sfif.data_out;
			tx.ready_cnt = sfif.ready_cnt;
			
			mon_ap.write(tx);
		end
	endtask
endclass: synchronous_fifo_monitor
