// -------------------------------------------------------------------
// @author alec
// @copyright (C) 2023, <COMPANY>
//
// Created : 31. Dec 2023 12:55 AM
//-------------------------------------------------------------------
module memory (
    input logic clk,
    input logic rst,

    input logic write,

    input logic [63:0] addr,
    input logic [63:0] data_in,
    output logic [63:0] data_out
);
    logic [7:0] mem [1024];
    initial begin
        $display("Loading ROM");
        $readmemh("rom.txt", mem);
    end

    assign data_out = {mem[addr], mem[addr + 1], mem[addr + 2], mem[addr + 3], mem[addr + 4], mem[addr + 4], mem[addr + 6], mem[addr + 7]};
    always_ff @(posedge clk) begin
        if (!rst && write) begin
            mem[addr] <= data_in[7:0];
            mem[addr + 1] <= data_in[15:8];
            mem[addr + 2] <= data_in[23:16];
            mem[addr + 3] <= data_in[31:24];
            mem[addr + 4] <= data_in[39:32];
            mem[addr + 5] <= data_in[47:40];
            mem[addr + 6] <= data_in[55:48];
            mem[addr + 7] <= data_in[63:56];
        end
    end
endmodule : memory