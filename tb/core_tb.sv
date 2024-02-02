`timescale 1ns / 1ps
`include "types.sv"

// verilator lint_off PINMISSING
module core_tb(input logic clk, input logic rst, input logic en);
	logic [15:0] max_instructions, dut_cnt;

	logic dut_done, behavioural_done;

	cache_behavioural dut_cache (
		.clk ( clk ),
		.rst ( rst )
	);
	
	cache_behavioural behavioural_cache (
    		.clk ( clk ),
    		.rst ( rst )
    );

	// verilator lint_off PINMISSING
	core #( .MULTI_ISSUE ( 3 ) ) dut (
		.clk ( clk ),
		.rst ( rst ),
		.max_instructions_i ( max_instructions ),
		.done_o ( dut_done )
	);
	
	assign dut_cnt = dut.issued_instruction_cnt;
	
	core_behavioural behavioural (
			.clk ( clk ),
			.rst ( rst ),
			.max_instructions_i ( dut_cnt ), // because we don't have a way to force the dut to serialize
			.done_o ( behavioural_done )
	);
	// verilator lint_on PINMISSING

	always_ff @(posedge clk) if (!rst && en) begin
		if (dut_done && behavioural_done) begin
			automatic bit mismatch = 0;
			for (int i = 0; i < 64'h10000; i++) begin
				if (dut_cache.dmem[i] != behavioural_cache.dmem[i]) begin
					$display("Mismatch at address %h", i);
					mismatch = 1;
				end
			end

			for (int i = 0; i < 32; i++) begin
				if (dut.rf.registers[i].is_virtual || dut.rf.registers[i].data.value != behavioural.registers[i]) begin
					$display("Mismatch at register %d", i);
					mismatch = 1;
				end
			end

			if (mismatch) $fatal(1, "Mismatch detected");

			max_instructions <= max_instructions + ($urandom_range(1, 1));
		end
	end

	always_ff @(posedge clk) if(rst) begin
		static bit [6:0] possible_opcodes[7] = {
			`OPC_ARITH,
			`OPC_ARITH_IMM,
			`OPC_LOAD,
			`OPC_STORE,
			`OPC_BRANCH,
			`OPC_JAL,
			`OPC_JALR
		};
		
		for (int j = 0; j < 64'h10000; j++) begin 
			dut_cache.dmem[j] = $random;
			behavioural_cache.dmem[j] = dut_cache.dmem[j];
		end

		for (int j = 0; j < 64'h10000 / 4; j++) begin
			automatic logic[31:0] instruction;
			automatic logic [6:0] opcode = possible_opcodes[$urandom_range(0, 6)];
			
			instruction = 'b0;
			instruction[6:0] = opcode;

			case (opcode)
				`OPC_ARITH : begin
					`RD(instruction) = $urandom;
					`FUNCT3(instruction) = $urandom_range(0, 7);
					`RS1(instruction) = $urandom;
					`RS2(instruction) = $urandom;
					instruction[31:25] = 0;
					if ((`FUNCT3(instruction) == 3'd0) || (`FUNCT3(instruction) == 3'd5))
						instruction[30] = 1'($urandom_range(0, 1));
				end

				`OPC_ARITH_IMM : begin
					`RD(instruction) = $urandom;
					`FUNCT3(instruction) = $urandom_range(0, 7);
					`RS1(instruction) = $urandom;
					instruction[31:20] = $urandom;

					if ((`FUNCT3(instruction) == 3'd1) || (`FUNCT3(instruction) == 3'd5))
						instruction[31:25] = 0;
				end

				`OPC_LOAD : begin
					`RD(instruction) = $urandom;
					case ($urandom_range(0, 4))
						0: `FUNCT3(instruction) = 3'h0;
						1: `FUNCT3(instruction) = 3'h1;
						2: `FUNCT3(instruction) = 3'h2;
						3: `FUNCT3(instruction) = 3'h4;
						4: `FUNCT3(instruction) = 3'h5;
					endcase
					`RS1(instruction) = $urandom;
					instruction[31:20] = $urandom;
				end

				`OPC_STORE : begin
					`RD(instruction) = $urandom;
					`FUNCT3(instruction) = $urandom_range(0, 2);
					`RS1(instruction) = $urandom;
					`RS2(instruction) = $urandom;
					instruction[31:25] = $urandom;
				end

				`OPC_BRANCH : begin
					automatic bit [11:0] imm = $urandom_range(1, 128) * 4;
					instruction[7] = imm[11];
					instruction[11:8] = imm[4:1];
					case ($urandom_range(0, 5))
						0: `FUNCT3(instruction) = 0;
						1: `FUNCT3(instruction) = 1;
						2: `FUNCT3(instruction) = 4;
						3: `FUNCT3(instruction) = 5;
						4: `FUNCT3(instruction) = 6;
						5: `FUNCT3(instruction) = 7;
					endcase
					`RS1(instruction) = $urandom;
					`RS2(instruction) = $urandom;
					instruction[30:25] = imm[10:5];
					instruction[31] = 0;
				end
				
				`OPC_JAL : begin
					instruction[31:7] = $urandom;
					instruction[21] = 1'b0;
				end
				
				`OPC_JALR : begin
					`RS1(instruction) = $urandom;
					instruction[31:22] = $urandom;
				end

				default: $fatal(1, "core: invalid insn");
			endcase

			dut_cache.imem[j*4] = instruction[31:24];
			dut_cache.imem[j*4+1] = instruction[23:16];
			dut_cache.imem[j*4+2] = instruction[15:8];
			dut_cache.imem[j*4+3] = instruction[7:0];

			behavioural_cache.imem[j*4] = instruction[31:24];
			behavioural_cache.imem[j*4+1] = instruction[23:16];
			behavioural_cache.imem[j*4+2] = instruction[15:8];
			behavioural_cache.imem[j*4+3] = instruction[7:0];
		end
		max_instructions <= 0;
	end

	// verilator lint_off ASSIGNIN
	assign dut_cache.dmem_rd_en_i = dut.dmem_rd_en_o;
	assign dut_cache.imem_rd_en_i = dut.imem_rd_en_o;
	assign dut_cache.dmem_wr_en_i = dut.dmem_wr_en_o;

	assign dut_cache.dmem_addr_i = dut.dmem_addr_o;
	assign dut_cache.imem_addr_i = dut.imem_addr_o;

	assign dut_cache.dmem_wr_size_i = dut.dmem_wr_size_o;
	assign dut_cache.dmem_wr_data_i = dut.dmem_wr_data_o;

	assign dut.dmem_busy_i = dut_cache.dmem_busy_o;
	assign dut.imem_busy_i = dut_cache.imem_busy_o;

	assign dut.dmem_rdy_i = dut_cache.dmem_rdy_o;
	assign dut.imem_rdy_i = dut_cache.imem_rdy_o;

	assign dut.dmem_rd_data_i = dut_cache.dmem_rd_data_o;
	assign dut.imem_rd_data_i = dut_cache.imem_rd_data_o;
	
	assign behavioural_cache.dmem_rd_en_i = behavioural.dmem_rd_en_o;
	assign behavioural_cache.imem_rd_en_i = behavioural.imem_rd_en_o;
	assign behavioural_cache.dmem_wr_en_i = behavioural.dmem_wr_en_o;

	assign behavioural_cache.dmem_addr_i = behavioural.dmem_addr_o;
	assign behavioural_cache.imem_addr_i = behavioural.imem_addr_o;

	assign behavioural_cache.dmem_wr_size_i = behavioural.dmem_wr_size_o;
	assign behavioural_cache.dmem_wr_data_i = behavioural.dmem_wr_data_o;

	assign behavioural.dmem_busy_i = behavioural_cache.dmem_busy_o;
	assign behavioural.imem_busy_i = behavioural_cache.imem_busy_o;

	assign behavioural.dmem_rdy_i = behavioural_cache.dmem_rdy_o;
	assign behavioural.imem_rdy_i = behavioural_cache.imem_rdy_o;

	assign behavioural.dmem_rd_data_i = behavioural_cache.dmem_rd_data_o;
	assign behavioural.imem_rd_data_i = behavioural_cache.imem_rd_data_o;
	// verilator lint_on ASSIGNIN
endmodule : core_tb
