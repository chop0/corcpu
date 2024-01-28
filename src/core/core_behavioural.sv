`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2024 12:34:13 PM
// Design Name: 
// Module Name: core_behavioural
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module core_behavioural #(parameter DATA_WIDTH = 64, FETCH_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic [15:0] max_instructions_i,

	input logic dmem_busy_i,
	input logic imem_busy_i,

	input logic dmem_rdy_i,
	input logic imem_rdy_i,

	input logic [FETCH_WIDTH - 1:0] dmem_rd_data_i,
	input logic [FETCH_WIDTH - 1:0] imem_rd_data_i,

	output logic dmem_rd_en_o,
	output logic imem_rd_en_o,
	output logic dmem_wr_en_o,

	output logic [DATA_WIDTH - 1:0] dmem_addr_o,
	output logic [DATA_WIDTH - 1:0] imem_addr_o,

	output logic [$clog2(FETCH_WIDTH / 8) - 1:0] dmem_wr_size_o,
	output logic [FETCH_WIDTH - 1:0] dmem_wr_data_o,

	output logic done_o
);
	logic [63:0] instruction_cnt;

	logic [DATA_WIDTH - 1:0] registers [32];
	logic [DATA_WIDTH - 1:0] pc;

	enum {
		POLL,
		READ_WAIT,
		WRITE_WAIT
	} state;
	logic [2:0] read_size;
	logic [4:0] read_reg;

	assign imem_rd_en_o = !imem_busy_i && (state == POLL);
	assign imem_addr_o = pc;

	assign done_o = (instruction_cnt == max_instructions_i) && state == POLL;

	always @(posedge clk) if (rst) begin
		read_size <= 0;
		state <= POLL;
		pc <= 0;
		instruction_cnt <= 0;
		for (int i = 0; i < 32; i++) registers[i] <= 0;
	end

	logic [31:0] insn;
	logic [DATA_WIDTH - 1:0] result;
	
	always_comb begin
		insn = 'X;
		result = 'X;
		
		dmem_rd_en_o = 1'b0;
		dmem_wr_en_o = 1'b0;
		
		dmem_addr_o = 'X;
		
		dmem_wr_size_o = 'X;
		dmem_wr_data_o = 'X;

		if (state == POLL && imem_rdy_i && instruction_cnt < max_instructions_i) begin
			insn = imem_rd_data_i[63:32];

			case (insn[6:0])
				7'b0110011	: begin
					bit [DATA_WIDTH - 1:0] lhs = registers[insn[19:15]];
					bit [DATA_WIDTH - 1:0] rhs = registers[insn[24:20]];

					case ({ insn[14:12], insn[31:25] })
						{ 3'h0, 7'h00 } : result = lhs + rhs;
						{ 3'h0, 7'h20 } : result = lhs - rhs;
						{ 3'h4, 7'h00 } : result = lhs ^ rhs;
						{ 3'h6, 7'h00 } : result = lhs | rhs;
						{ 3'h7, 7'h00 } : result = lhs & rhs;
						{ 3'h1, 7'h00 } : result = lhs << rhs;
						{ 3'h5, 7'h00 } : result = lhs >> rhs;
						{ 3'h5, 7'h20 } : result = $signed(lhs) >>> rhs;
						{ 3'h2, 7'h00 } : result = ($signed(lhs) < $signed(rhs)) ? 1 : 0;
						{ 3'h3, 7'h00 } : result = (lhs < rhs) ? 1 : 0;
						default 		: $fatal("alu: invalid instruction");
					endcase
				end
				7'b0010011	: begin
					bit [DATA_WIDTH - 1:0] lhs = registers[insn[19:15]];
					bit [DATA_WIDTH - 1:0] rhs = insn[31:20];

					casez ({ insn[14:12], insn[31:25] })
						{ 3'h0, 7'h?? } : result = lhs + rhs;
						{ 3'h4, 7'h?? } : result = lhs ^ rhs;
						{ 3'h6, 7'h?? } : result = lhs | rhs;
						{ 3'h7, 7'h?? } : result = lhs & rhs;
						{ 3'h1, 7'h00 } : result = lhs << rhs[4:0];
						{ 3'h5, 7'h00 } : result = lhs >> rhs[4:0];
						{ 3'h5, 7'h20 } : result = $signed(lhs) >>> rhs[4:0];
						{ 3'h2, 7'h?? } : result = ($signed(lhs) < $signed(insn[31:20])) ? 1 : 0;
						{ 3'h3, 7'h?? } : result = (lhs < rhs) ? 1 : 0;
						default 		: $fatal("alu: invalid instruction");
					endcase
				end
				
				7'b0000011	: begin
					dmem_addr_o = 64'(registers[insn[19:15]]) + $signed(insn[31:20]);
					dmem_rd_en_o = 1;
				end
				7'b0100011	: begin
					dmem_addr_o = registers[insn[19:15]] + { insn[31:25], insn[11:7] };
					dmem_wr_size_o = insn[14:12];
					dmem_wr_data_o = registers[insn[24:20]];
					dmem_wr_en_o = 1;
				end
				
				7'b1100011	: begin
					bit [11:0] imm = { insn[31], insn[7], insn[30:25], insn[11:8], 1'b0 };
					bit [DATA_WIDTH - 1:0] lhs = registers[insn[19:15]];
					bit [DATA_WIDTH - 1:0] rhs = registers[insn[24:20]];

					case (insn[14:12])
						3'h0 : if (lhs == rhs) result = pc + imm; else result = pc + 4;
						3'h1 : if (lhs != rhs) result = pc + imm; else result = pc + 4;
						3'h4 : if ($signed(lhs) < $signed(rhs)) result = pc + imm; else result = pc + 4;
						3'h5 : if ($signed(lhs) >= $signed(rhs)) result = pc + imm; else result = pc + 4;
						3'h6 : if (lhs < rhs) result = pc + imm; else result = pc + 4;
						3'h7 : if (lhs >= rhs) result = pc + imm; else result = pc + 4;
						default : $fatal("core: invalid instruction");
					endcase
				end

				default: $fatal(0);
			endcase

		end
	end
	
	always_ff @(posedge clk) begin
		if (state == POLL && imem_rdy_i && instruction_cnt < max_instructions_i) begin
			case (insn[6:0])
				7'b0110011	: registers[insn[11:7]] <= result;
				7'b0010011	: registers[insn[11:7]] <= result;
				7'b0000011	: begin
					state <= READ_WAIT;
					read_size <= insn[14:12];
					read_reg <= insn[11:7];
				end
				
				7'b0100011	: state <= WRITE_WAIT;
				7'b1100011	: pc <= result;
				default		: $fatal("invalid insn");
			endcase

			instruction_cnt <= instruction_cnt + 1;
			if (insn[6:0] != 7'b1100011) pc <= pc + 4;
		end else if (state == READ_WAIT && dmem_rdy_i) begin
			case (read_size)
				3'h0 : registers[read_reg] <= $signed(dmem_rd_data_i[7:0]);
				3'h1 : registers[read_reg] <= $signed(dmem_rd_data_i[15:0]);
				3'h2 : registers[read_reg] <= $signed(dmem_rd_data_i[31:0]);
				3'h4 : registers[read_reg] <= dmem_rd_data_i[7:0];
				3'h5 : registers[read_reg] <= dmem_rd_data_i[15:0];
				default: $fatal(1, "unexpected read_size", read_size);
			endcase
			state <= POLL;
		end else if (state == WRITE_WAIT && dmem_rdy_i) state <= POLL;
	end
endmodule : core_behavioural
