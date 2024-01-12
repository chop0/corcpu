`timescale 1ns / 1ps

module instruction_issuer_behavioural(
        input clk,
        input rst,
        
        input [4:0] rs,
        input [4:0] rt,
        
        e_functional_unit r,
        
        register_file register_file,
        reservation_station RS [ e_functional_unit ]
);

    wire current_qi = register_file.Qi[rs];

    always @(posedge(clk)) begin
        if (register_file.Qi[rs] != 0)
            RS[r].Qj = register_file.Qi[rs];
        else begin
            RS[r].Vj <= register_file.registers[rs];
            RS[r].Qj <= 0;
        end
        
        
    end
endmodule


module instruction_issuer_tb;



endmodule
