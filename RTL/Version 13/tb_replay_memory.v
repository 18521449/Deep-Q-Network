`timescale 1ns/1ps
module tb_replay_memory();

parameter DATA_WIDTH 		= 32;
parameter MEMORY_WIDTH		= 10000;
parameter ACTION_WIDTH		= 2;
parameter k=5;

//------------------------input and output port-----------------------//
	reg										clk;
	reg 									rst_n;
	reg										i_valid;
	reg		[DATA_WIDTH-1:0]				i_current_state_0;
	reg		[DATA_WIDTH-1:0]				i_current_state_1;
	reg		[ACTION_WIDTH-1:0]				i_action;
	reg		[DATA_WIDTH-1:0]				i_reward;
	reg		[DATA_WIDTH-1:0]				i_next_state_0;
	reg		[DATA_WIDTH-1:0]				i_next_state_1;
	reg										i_done;
	wire  									o_valid;
	wire 	[DATA_WIDTH-1:0]				o_current_state_0;
	wire 	[DATA_WIDTH-1:0]				o_current_state_1;
	wire 	[ACTION_WIDTH-1:0]				o_action;
	wire  	[DATA_WIDTH-1:0]				o_reward;
	wire  	[DATA_WIDTH-1:0]				o_next_state_0;
	wire  	[DATA_WIDTH-1:0]				o_next_state_1;
	wire  									o_done;
	wire 									o_ready_for_train;
//--------------------------------------------------------------------//
	reg [14-1:0] counter;

integer i;
initial begin
	clk <= 0;
	rst_n <= 0;
	counter <= 0;
	#k#k rst_n <= 1;
	for (i=0; i<100; i=i+1) begin
		#(100*k) i_valid <= 1;
				i_current_state_0 <= 'd1;
				i_current_state_1 <= 'd2;
				i_reward <= 'd3;
				i_action <= 'd1;
				i_next_state_0 <= 'd5;
				i_next_state_1	<= 'd6;
				i_done <= 1;
		#k#k 	i_valid <= 0;
	end
	#(200*k)	$finish;
	
end

	
dqn_replay_memory
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.MEMORY_WIDTH			(MEMORY_WIDTH),
		.ACTION_WIDTH			(ACTION_WIDTH)
	)
	tb_replay_mem
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(i_valid),
		.i_current_state_0		(i_current_state_0),
		.i_current_state_1		(i_current_state_1),
		.i_action				(i_action),
		.i_reward				(i_reward),
		.i_next_state_0			(i_next_state_0),
		.i_next_state_1			(i_next_state_1),
		.i_done					(i_done),
		.o_valid				(o_valid),	
		.o_current_state_0		(o_current_state_0),
		.o_current_state_1		(o_current_state_1),
		.o_action				(o_action),
		.o_reward				(o_reward),
		.o_next_state_0			(o_next_state_0),
		.o_next_state_1			(o_next_state_1),
		.o_done					(o_done),
		.o_ready_for_train		(o_ready_for_train)
	);


always @(posedge clk) begin 
	$display("ready. %b", o_ready_for_train);
	$display("No. %d", counter);
end

always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
