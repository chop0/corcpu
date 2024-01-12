`timescale 1ns / 1ps

module synchronous_fifo_behavioural #(parameter DEPTH=8, DATA_WIDTH=8) (
  input clk, rst,
  input push, poll,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output reg full, empty
);
    localparam TRUE_DEPTH = DEPTH - 1;
    
    bit [DATA_WIDTH - 1:0] queue [$:TRUE_DEPTH - 1];
    
    always @(posedge (clk)) begin            
        if (rst) begin
            data_out = 0;
            queue = {};
        end
    
        else begin
            if (poll && !empty)
                data_out = queue.pop_front();
                      
             if (push && !full)
                queue.push_back(data_in);
         end
         
         full = queue.size() == TRUE_DEPTH; empty = queue.size() == 0;
    end  
endmodule

module synchronous_fifo_tb();

  parameter DEPTH=4, DATA_WIDTH=2;
  
  
  localparam CYCLES_PER_TEST = DEPTH;
  localparam INPUTS_PER_CYCLE = DATA_WIDTH + 2;
  localparam TEST_VECTOR_WIDTH = CYCLES_PER_TEST * INPUTS_PER_CYCLE; 
  
  parameter BEGIN_VECTOR = 0, END_VECTOR = 0;

  reg clk, rst;
  reg push, poll;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  
  synchronous_fifo #(DEPTH, DATA_WIDTH) dut (
    .clk(clk),
    .rst(rst),
    .push(push),
    .poll(poll),
    .data_in(data_in),
    
    .head ( ),
    .tail ( ),
    
    .full ( ),
    .empty ( )
  );

  synchronous_fifo_behavioural #(DEPTH, DATA_WIDTH) behavioural (
    .clk(clk),
    .rst(rst),
    .push(push),
    .poll(poll),
    .data_in(data_in),
    
    .data_out ( ),
    .full ( ),
    .empty ( )
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  reg [TEST_VECTOR_WIDTH - 1:0] test_vector = BEGIN_VECTOR;
  int cycle = 0;
  
  wire [INPUTS_PER_CYCLE - 1:0] cycle_inputs = test_vector[cycle*INPUTS_PER_CYCLE +: INPUTS_PER_CYCLE];
  
  assign push = cycle_inputs[0];
  assign poll = cycle_inputs[1];
  assign data_in = cycle_inputs[2 +: DATA_WIDTH - 1];
  
  reg started = 0;
  initial begin 
    rst = 0;
    @(posedge(clk));
    rst = 1;
    @(posedge(clk));
    rst = 0;
    started = 1;
 end
  
  always @ (posedge(clk)) begin
    if (started)
        if (rst)
            rst <= 0;
        
        else begin        
            if ((dut.head !== behavioural.data_out) || (dut.full !== behavioural.full) || (dut.empty !== behavioural.empty)) begin
              $display("--- Mismatch found on test vector %d at cycle %d ---", test_vector, cycle);
              
              for (int i = 0; i < cycle; i++) begin
                bit [INPUTS_PER_CYCLE - 1:0] ins = test_vector[i*INPUTS_PER_CYCLE +: INPUTS_PER_CYCLE];
                $display("Cycle %d: push = %d, poll = %d, data_in = %d", i, ins[0], ins[1], ins[2 +: DATA_WIDTH - 1]);
              end
              
              $display("DUT       : data_out=%b, full=%b, empty=%b", dut.head, dut.full, dut.empty);
              $display("Behavioral: data_out=%b, full=%b, empty=%b", behavioural.data_out, behavioural.full, behavioural.empty);
              $finish();
            end
            
            if (cycle == CYCLES_PER_TEST - 1) begin
                automatic bit [TEST_VECTOR_WIDTH - 1:0] next = test_vector + 1;
                if (next == END_VECTOR)
                    $finish();
                    
                test_vector <= next;
                cycle <= 0;
                rst <= 1;
            end
            else
                cycle <= cycle + 1;
        end
  end
endmodule
