`timescale 1ns / 1ps


module core_behavioural #(parameter DATA_WIDTH = 64, FETCH_WIDTH = 64) (
	input logic clk,
	input logic rst,

	input logic [15:0] max_instructions_i,

	input logic dmem_busy_i,
	input logic imem_busy_i,

	input logic dmem_rdy_i,
	input logic imem_rdy_i,

	input logic [FETCH_WIDTH - 1:0] dmem_rd_data_i,
	input logic [31:0] imem_rd_data_i,

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

	enum { POLL, READ_WAIT, WRITE_WAIT } state;
	logic [2:0] read_size;
	logic [4:0] read_reg;

	assign imem_rd_en_o = !imem_busy_i && (state == POLL);
	assign imem_addr_o = pc;

	assign done_o = (instruction_cnt == max_instructions_i) && state == POLL;

	logic [31:0] insn;
	logic [DATA_WIDTH - 1:0] result, result2;
	
	always_comb begin
		insn = 'X;
		result = 'X;
		
		dmem_rd_en_o = 1'b0;
		dmem_wr_en_o = 1'b0;
		
		dmem_addr_o = 'X;
		
		dmem_wr_size_o = 'X;
		dmem_wr_data_o = 'X;

		if (state == POLL && imem_rdy_i && instruction_cnt < max_instructions_i) begin
			insn = imem_rd_data_i[31:0];

			case (`OPC(insn))
				`OPC_ARITH	: begin
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
				`OPC_ARITH_IMM	: begin
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
						{ 3'h2, 7'h?? } : result = ($signed(lhs) < $signed(64'(insn[31:20]))) ? 1 : 0;
						{ 3'h3, 7'h?? } : result = (lhs < rhs) ? 1 : 0;
						default 		: $fatal("alu: invalid instruction");
					endcase
				end
				
				`OPC_LOAD	: begin
					dmem_addr_o = 64'(registers[insn[19:15]]) + $signed(insn[31:20]);
					dmem_rd_en_o = 1;
				end
				`OPC_STORE	: begin
					dmem_addr_o = registers[insn[19:15]] + { insn[31:25], insn[11:7] };
					dmem_wr_size_o = insn[14:12];
					dmem_wr_data_o = registers[insn[24:20]];
					dmem_wr_en_o = 1;
				end
				
				`OPC_BRANCH	: begin
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
				
				`OPC_JAL : begin
					bit [31:0] imm = { 12'b0, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0 };
					result = pc + 4;
					result2 = pc + imm;
				end
				
				`OPC_JALR : begin
					bit [31:0] imm = { insn[31:20] };
					result = pc + 4;
					result2 = registers[insn[19:15]] + imm;
				end
				
				`OPC_LUI : begin
					result = insn[31:12] << 12;
				end
				
				`OPC_AUIPC : begin
					result = pc + insn[31:12] << 12;
				end

				default: $fatal(0);
			endcase

		end
	end
	
	always_ff @(posedge clk) if (!rst) begin
		if (state == POLL && imem_rdy_i && instruction_cnt < max_instructions_i) begin
			pc <= pc + 4;
			instruction_cnt <= instruction_cnt + 1;
			
			case (`OPC(insn))
				`OPC_ARITH, `OPC_ARITH_IMM, `OPC_LUI, `OPC_AUIPC	: registers[insn[11:7]] <= result;
				`OPC_LOAD	: begin
					state <= READ_WAIT;
					read_size <= insn[14:12];
					read_reg <= insn[11:7];
				end
				
				`OPC_STORE	: state <= WRITE_WAIT;
				`OPC_BRANCH	: pc <= result;
				`OPC_JAL, `OPC_JALR : begin
					registers[insn[11:7]] <= result;
					pc <= result2;
				end
				default		: $fatal("invalid insn");
			endcase
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
		
		registers[0] <= 0; // make sure this is always 0
	end
	
	always @(posedge clk) if (rst) begin
		read_size <= 0;
		state <= POLL;
		pc <= 0;
		instruction_cnt <= 0;
		for (int i = 0; i < 32; i++) registers[i] <= 0;
		registers[2] <= 'h1000; // stack
	end
endmodule : core_behavioural
