module cdb_tb ();
	localparam DATA_WIDTH = 64;
	localparam FUNCTIONAL_UNIT_COUNT = 5;

	logic fu_status [FUNCTIONAL_UNIT_COUNT - 1:0];
	logic [DATA_WIDTH - 1 : 0] fu_results [FUNCTIONAL_UNIT_COUNT];

	logic valid_rtl;
	logic valid_beh;

	logic [2:0] rs_id_rtl;
	logic [2:0] rs_id_beh;
	
	logic [DATA_WIDTH - 1 : 0] result_rtl;
	logic [DATA_WIDTH - 1 : 0] result_beh;
	logic [FUNCTIONAL_UNIT_COUNT - 1:0] retiring_beh, retiring_rtl;

	logic clk;
	
	CDB_Arbiter_Behavioural #(DATA_WIDTH, FUNCTIONAL_UNIT_COUNT) arbiter_beh (
		.fu_status ( fu_status ),
		.fu_results ( fu_results ),
		.valid ( valid_beh ),
		.rs_id ( rs_id_beh ),
		.result ( result_beh ),
		.retiring_stations ( retiring_beh )
	);

	CDB_Arbiter #(DATA_WIDTH, FUNCTIONAL_UNIT_COUNT) arbiter_rtl (
		.fu_status ( { << { fu_status }} ),
		.fu_results ( fu_results ),
		.valid ( valid_rtl ),
		.rs_id ( rs_id_rtl ),
		.result ( result_rtl ),
		.retiring_stations ( retiring_rtl )
	);

	initial begin 
	for (int i = 0; i < FUNCTIONAL_UNIT_COUNT; i++) begin
			fu_status[i] = $random;
			fu_results[i] = $random;
		end
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	always_ff @(posedge(clk)) begin
		for (int i = 0; i < FUNCTIONAL_UNIT_COUNT; i++) begin
			fu_status[i] <= $random;
			fu_results[i] <= $random;
		end

		if (!((valid_rtl == valid_beh) && (valid_rtl == 0 || (result_rtl == result_beh && retiring_rtl == retiring_beh)))) begin
			$display("Mismatch between behavioural and RTL CDB.");
			foreach(fu_status[i]) $display("fu_status[%d]: %b", i, fu_status[i]);
			foreach(fu_results[i]) $display("fu_results[%d]: %p", i, fu_results[i]);
			$display("valid_rtl: %b", valid_rtl);
			$display("valid_beh: %b", valid_beh);
			$display("rs_id_rtl: %b", rs_id_rtl);
			$display("rs_id_beh: %b", rs_id_beh);
			$display("result_rtl: %p", result_rtl);
			$display("result_beh: %p", result_beh);
			$display("retiring_rtl: %p", retiring_rtl);
			$display("retiring_beh: %p", retiring_beh);
			$finish;
		end
	end
endmodule : cdb_tb