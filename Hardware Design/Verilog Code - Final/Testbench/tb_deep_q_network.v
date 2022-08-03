`timescale 1ns/1ps
module tb_deep_q_network();

parameter DATA_WIDTH 						= 32;
parameter ACTION_WIDTH						= 2;
parameter LAYER_WIDTH	 					= 2;
parameter MEMORY_WIDTH						= 20;
parameter TRAIN_START 						= 10;
parameter BATCH_SIZE						= 4;
parameter NUMBER_OF_INPUT_NODE 				= 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 24;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 24;
parameter NUMBER_OF_OUTPUT_NODE 			= 3;
parameter [DATA_WIDTH-1:0] EPSILON_DECAY	= 'h3F7F3B64; 	//0.997
parameter [DATA_WIDTH-1:0] EPSILON_MIN		= 'h3C23D70A; 	//0.01
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3A83126F; 	//0.001
parameter [DATA_WIDTH-1:0] GAMMA			= 'h3F4CCCCD; 	//0.8
parameter [DATA_WIDTH-1:0] UPDATE_RATE		= 'h3F000000; 	//0.5
parameter DATA_INPUT_FILE 					= "main_ram_input_data.txt";
parameter WEIGHT_HIDDEN_1_FILE 				= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE 				= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE 				= "main_ram_output_weight.txt";
parameter REWARD_FILE						= "file_reward.txt";
parameter DONE_FILE							= "file_done.txt";
parameter STATE_FILE						= "file_state.txt";
parameter k=5;

parameter DATA_COUNTER_WIDTH 	= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter WEIGHT_COUNTER_WIDTH 	= 11;
localparam MEMORY_ADDR_WIDTH	= $clog2(MEMORY_WIDTH);


//-----------------input and output port-------------//
	reg										clk;
	reg 									rst_n;
	reg 									i_valid;
	reg 		[DATA_WIDTH-1:0]			i_state_0;
	reg 		[DATA_WIDTH-1:0]			i_state_1;
	reg 		[DATA_WIDTH-1:0]			i_reward;
	reg 									i_done;
	reg 									i_weight_valid;
	reg 		[LAYER_WIDTH-1:0]			i_weight_layer;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	reg 		[DATA_WIDTH-1:0]			i_weight;
	reg 									i_load_weight_done;
	wire  									o_action_valid;
	wire  		[ACTION_WIDTH-1:0]			o_action;
	wire									o_train_done;
	wire 									o_ready_for_train;
//----------------------------------------------------//

reg 		[DATA_WIDTH-1:0]			ram_data_in			[NUMBER_OF_INPUT_NODE-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_1	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_2	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_output	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];

reg 		[DATA_WIDTH*2-1:0]			ram_state	[100-1:0];
reg 		[DATA_WIDTH-1:0]			ram_reward	[100-1:0];
reg 		[1-1:0]						ram_done 	[100-1:0];

reg 		[5:0]						node_counter;
reg 		[11:0]						weight_counter;
reg										weight_valid;
reg										load_data;
reg 		[MEMORY_ADDR_WIDTH:0]		state_counter;

initial begin
	$readmemh(DATA_INPUT_FILE, 		ram_data_in);
	$readmemh(WEIGHT_HIDDEN_1_FILE, ram_weight_hidden_1);
	$readmemh(WEIGHT_HIDDEN_2_FILE, ram_weight_hidden_2);
	$readmemh(WEIGHT_OUTPUT_FILE, 	ram_weight_output);
	
	$readmemh(STATE_FILE, 	ram_state);
	$readmemh(REWARD_FILE, 	ram_reward);
	$readmemh(DONE_FILE, 	ram_done);
	
	clk 			<= 0;
	rst_n 			<= 0;
	node_counter 	<= 'd0;
	weight_counter 	<= 'd0;
	weight_valid 	<= 0;
	load_data 		<= 0;
	i_weight_layer 	<= 2'b00;
	
	state_counter	<= 'd1;
	
	
	#k#k 	rst_n <= 1;
			weight_valid <= 1;
			i_load_weight_done <= 0;
	#(1000*2*k)	i_valid <= 1;
				i_state_0 <= ram_state[0][DATA_WIDTH-1:0];
				i_state_1 <= ram_state[0][DATA_WIDTH*2-1:DATA_WIDTH];
	#k#k		i_valid <= 0;
end

deep_q_network
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ACTION_WIDTH					(ACTION_WIDTH),
		.MEMORY_WIDTH					(MEMORY_WIDTH),
		.TRAIN_START					(TRAIN_START),
		.BATCH_SIZE						(BATCH_SIZE),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.EPSILON_DECAY					(EPSILON_DECAY),
		.EPSILON_MIN					(EPSILON_MIN),
		.LEARNING_RATE					(LEARNING_RATE),
		.GAMMA							(GAMMA),
		.UPDATE_RATE					(UPDATE_RATE)
	)
	dqn_tb
	(	.clk				(clk),
		.rst_n				(rst_n),
		.i_valid			(i_valid),
		.i_state_0			(i_state_0),
		.i_state_1			(i_state_1),
		.i_reward			(i_reward),
		.i_done				(i_done),
		.i_weight_valid		(i_weight_valid),
		.i_weight_layer		(i_weight_layer),
		.i_weight_addr		(i_weight_addr),
		.i_weight			(i_weight),
		.i_load_weight_done	(i_load_weight_done),
		.o_action			(o_action),
		.o_action_valid		(o_action_valid),
		.o_train_done		(o_train_done),
		.o_ready_for_train	(o_ready_for_train)
	);

always @(posedge clk) begin
	case(i_weight_layer)
		2'b00:
			begin
				if (weight_valid) begin
					i_weight_layer <= 2'b01;
					node_counter <= 'd0;
					weight_counter <= 'd0;
				end
			end
		2'b01:
			begin
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
					if (weight_counter < NUMBER_OF_INPUT_NODE) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight_addr <=  (node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter;
							i_weight <= ram_weight_hidden_1[(node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter;
						i_weight <= ram_weight_hidden_1[(node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b10;
				end
			end
		2'b10:
			begin
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
					if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter;
							i_weight <= ram_weight_hidden_2[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter;
						i_weight <= ram_weight_hidden_2[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b11;
				end
			end
		2'b11:
			begin
				if (node_counter < NUMBER_OF_OUTPUT_NODE) begin
					if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter;
							i_weight <= ram_weight_output[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter;
						i_weight <= ram_weight_output[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b00;
					weight_valid <= 0;
					i_load_weight_done <= 1;
				end
			end
	endcase
end

always @(posedge clk) begin
	if (i_load_weight_done) begin
		i_load_weight_done <= 0;
	end
	if (o_train_done | o_action_valid) begin
		if (state_counter < 'd30) begin
			#(4*k) i_valid 	<= 1;
			i_state_0 	<= ram_state[state_counter][DATA_WIDTH-1:0];
			i_state_1 	<= ram_state[state_counter][DATA_WIDTH*2-1:DATA_WIDTH];
			i_reward	<= ram_reward[state_counter];
			i_done		<= ram_done[state_counter];
			state_counter <= state_counter + 1;
			#k#k i_valid <= 0;
		end
		else begin
			state_counter <= 'd0;
			#(10*k) $finish;
		end
	end
	
	if (!o_ready_for_train & i_done) begin
		i_valid 	<= 1;
		i_state_0 	<= ram_state[state_counter][DATA_WIDTH-1:0];
		i_state_1 	<= ram_state[state_counter][DATA_WIDTH*2-1:DATA_WIDTH];
		i_reward	<= ram_reward[state_counter];
		i_done		<= ram_done[state_counter];
		state_counter <= state_counter + 1;
		#k#k i_valid <= 0;
	end
	
end


// function for clog2
	function integer clog2;
	input integer value;
	begin
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	end
	endfunction
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
