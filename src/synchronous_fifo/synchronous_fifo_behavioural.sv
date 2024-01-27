module synchronous_fifo_behavioural #(parameter DEPTH=8, DATA_WIDTH=8)  (
	input logic clk, rst,
	input logic push, poll,
	input logic [DATA_WIDTH-1:0] data_in,

	output logic [DATA_WIDTH-1:0] head,
	output logic [DATA_WIDTH-1:0] tail,

	output logic full, empty
);
    localparam TRUE_DEPTH = DEPTH - 1;

    logic [DATA_WIDTH - 1:0] queue [$:TRUE_DEPTH - 1];

    always @(posedge (clk)) begin
        if (rst) begin
            head <= 'X;
            tail <= 'X;
            queue = {};
        end
        else begin
            if (poll && !empty)
                queue.pop_front();

             if (push && !full)
                queue.push_back(data_in);
         end

         full <= queue.size() == TRUE_DEPTH; empty <= queue.size() == 0;
         head <= queue[0];
         tail <= queue[queue.size() - 1];
    end
endmodule