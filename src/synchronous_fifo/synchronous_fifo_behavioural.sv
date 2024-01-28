module synchronous_fifo_behavioural #(parameter DEPTH=8, DATA_WIDTH=8, MULTI_POP = 1) (
	input logic clk, rst,
	
	input logic push,
	input logic [$clog2(MULTI_POP) - 1:0] poll_cnt,
	
	input logic [DATA_WIDTH-1:0] data_in,

	output logic [DATA_WIDTH-1:0] data_out [MULTI_POP],
	output logic [$clog2(MULTI_POP) - 1:0] ready_cnt,
	output logic full
);

    localparam TRUE_DEPTH = DEPTH - 1;

    logic [DATA_WIDTH - 1:0] queue [$:TRUE_DEPTH - 1];

    always @(posedge (clk)) if (rst) begin
    	for (int i = 0; i < MULTI_POP; i++)
    		data_out[i] <= 'X;
    	ready_cnt <= 0;
        queue = {};
    end
    
    always @(posedge (clk)) if (!rst) begin
    	assert (!push || queue.size() < TRUE_DEPTH);
    	assert (queue.size() >= poll_cnt);
    
		for (int i = 0; i < poll_cnt; i++)
			queue.pop_front();

		 if (push)
			queue.push_back(data_in);

		 ready_cnt <= queue.size();
         
         for (int i = 0; i < MULTI_POP; i++)
         	data_out[i] <= queue[i];
    end
    
    assign full = ready_cnt == TRUE_DEPTH;
endmodule