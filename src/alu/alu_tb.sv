module alu_tb ();
	localparam DATA_WIDTH = 64;

	logic [DATA_WIDTH-1:0] lhs ;
	logic [DATA_WIDTH-1:0] rhs ;
	
	logic lhs_valid ;
	logic rhs_valid ;
	
	logic uses_imm ;
	
	logic [2:0] funct3 ;
	logic [6:0] funct7 ;

	logic [DATA_WIDTH-1:0] result_rtl;
	logic [DATA_WIDTH-1:0] result_beh;
	
	logic result_valid_rtl;
	logic result_valid_beh;
	
	logic clk;
	
	alu_behavioural #( DATA_WIDTH ) alu_beh(
		.lhs ( lhs ),
		.rhs ( rhs ),

		.lhs_valid ( lhs_valid ),
		.rhs_valid ( rhs_valid ),

		.uses_imm ( uses_imm ),
		.funct3 ( funct3 ),
		.funct7 ( funct7 ),

		.result ( result_beh ),
		.result_valid ( result_valid_beh )
	 );

	alu #( DATA_WIDTH ) alu_rtl(
		.lhs ( lhs ),
		.rhs ( rhs ),

		.lhs_valid ( lhs_valid ),
		.rhs_valid ( rhs_valid ),

		.uses_imm ( uses_imm ),
		.funct3 ( funct3 ),
		.funct7 ( funct7 ),

		.result ( result_rtl ),
		.result_valid ( result_valid_rtl )
	);

	initial begin 
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	always_ff @(posedge(clk)) begin
		lhs <= $random;
		rhs <= $random;
		
		if ($random & 1'b1) begin
			lhs_valid <= 1'b1;
			rhs_valid <= 1'b1;
		end else begin
			lhs_valid <= $random;
			rhs_valid <= $random;
		end
		
		uses_imm <= $random;
		
		funct3 <= $random & 4'hf;
		if ($random & 1'b1)
			funct7 <= 0;
		else if ($random & 1'b1)
			funct7 <= 'h20;
		else
			funct7 <= $random;

		if (!((result_valid_rtl == result_valid_beh) && (result_valid_rtl == 0 || (result_rtl == result_beh)))) begin
			$display("Mismatch between behavioural and RTL ALU",
					 "Input: {",
					 "	lhs: 0x%h,", lhs,
					 "	rhs: 0x%h,", rhs,
					 "	lhs_valid: %b,", lhs_valid,
					 "	rhs_valid: %b,", rhs_valid,
					 "	uses_imm: %b,", uses_imm,
					 "	funct3: 0x%h,", funct3,
					 "	funct7: 0x%h,", funct7,
					 "}",
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