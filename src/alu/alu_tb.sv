module alu_tb ( input logic clk, input logic rst, input logic en );
	localparam DATA_WIDTH = 64;

	logic [DATA_WIDTH-1:0] lhs ;
	logic [DATA_WIDTH-1:0] rhs ;
	
	logic lhs_valid ;
	logic rhs_valid ;
	
	logic uses_imm ;
	
	operation_specification op_spec;

	logic [DATA_WIDTH-1:0] result_rtl;
	logic [DATA_WIDTH-1:0] result_beh;
	
	logic result_valid_rtl;
	logic result_valid_beh;

	alu_behavioural #( DATA_WIDTH ) alu_beh(
		.lhs ( lhs ),
		.rhs ( rhs ),

		.lhs_valid ( lhs_valid ),
		.rhs_valid ( rhs_valid ),

		.op_spec ( op_spec ),

		.result ( result_beh ),
		.result_valid ( result_valid_beh )
	 );

	alu #( DATA_WIDTH ) alu_rtl(
		.lhs ( lhs ),
		.rhs ( rhs ),

		.lhs_valid ( lhs_valid ),
		.rhs_valid ( rhs_valid ),

		.op_spec ( op_spec ),

		.result ( result_rtl ),
		.result_valid ( result_valid_rtl )
	);
	
	always_ff @(posedge(clk)) begin
		lhs <= $random;
		rhs <= $random;
		
		if (1'($random) & 1'b1) begin
			lhs_valid <= 1'b1;
			rhs_valid <= 1'b1;
		end else begin
			lhs_valid <= 1'($random);
			rhs_valid <= 1'($random);
		end

		op_spec <= '{
			opcode: 1'($random) ? 7'b0110011 : 7'b0010011,
			rs1: 5'($random),
			funct3: 3'($random),
			rs2: 5'($random),
			rd: 5'($random),
			funct7: (1'($random) & 1'b1) ? 'h0 : 'h20,
			imm: 12'($random),
			encoding: 1'($random) ? R_FORMAT : I_FORMAT
		};

		if (en & !((result_valid_rtl == result_valid_beh) && (result_valid_rtl == 0 || (result_rtl == result_beh)))) begin
			$display("Mismatch between behavioural and RTL ALU",
					 "Behavioural result: {",
					 "	result: 0x%h,", result_beh,
					 "	result_valid: %b,", result_valid_beh,
					 "}",
					 "RTL result: {",
					 "	result: 0x%h,", result_rtl,
					 "	result_valid: %b,", result_valid_rtl,
					 "}"
					);
			$finish;
		end
	end
endmodule : alu_tb