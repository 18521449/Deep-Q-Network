`timescale 1ns/1ps
module deep_q_network
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter LAYER_WIDTH	 					= 2,
		parameter MEMORY_WIDTH						= 10000,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter NUMBER_OF_TRAIN_TIMES				= 1000,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F, 	//0.002
		parameter [DATA_WIDTH-1:0] GAMMA			= 'h3F4CCCCD, 	//0.8
		parameter [DATA_WIDTH-1:0] UPDATE_RATE		= 'h3F000000, 	//0.5
		parameter [DATA_WIDTH-1:0] EPSILON_DECAY	= 'h3F7F3B64 //0.997
	)
	(	clk,
		rst_n,
		i_valid,
		i_state_0,
		i_state_1,
		i_reward,
		i_done,
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		o_action,
		o_action_valid
	);
	
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	localparam MEMORY_ADDR_WIDTH		= $clog2(MEMORY_WIDTH);
	
	//-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_valid;
	input 		[DATA_WIDTH-1:0]			i_state_0;
	input 		[DATA_WIDTH-1:0]			i_state_1;
	input 		[DATA_WIDTH-1:0]			i_reward;
	input									i_done;
	input 									i_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_weight;
	output		[ACTION_WIDTH-1:0]			o_action;
	output 									o_action_valid;
	//----------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 									eps_o_action_select;
	wire 		[ACTION_WIDTH-1:0]			eps_o_action_random;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									ann_i_valid;
	reg			[DATA_WIDTH-1:0]			ann_i_current_state_0;		
	reg			[DATA_WIDTH-1:0]			ann_i_current_state_1;
	reg 		[ACTION_WIDTH-1:0]			ann_i_action;
	reg			[DATA_WIDTH-1:0]			ann_i_reward;		
	reg			[DATA_WIDTH-1:0]			ann_i_next_state_0;		
	reg			[DATA_WIDTH-1:0]			ann_i_next_state_1;	
	reg 									ann_i_done;
	reg 									ann_i_update_request;
	wire 		[ACTION_WIDTH-1:0]			ann_o_action;
	wire 									ann_o_action_valid;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									rep_i_valid;
	reg			[DATA_WIDTH-1:0]			rep_i_current_state_0;		
	reg			[DATA_WIDTH-1:0]			rep_i_current_state_1;
	reg 		[ACTION_WIDTH-1:0]			rep_i_action;
	reg			[DATA_WIDTH-1:0]			rep_i_reward;		
	reg			[DATA_WIDTH-1:0]			rep_i_next_state_0;		
	reg			[DATA_WIDTH-1:0]			rep_i_next_state_1;	
	reg 									rep_i_done;
	wire 									rep_o_valid;
	wire		[DATA_WIDTH-1:0]			rep_o_current_state_0;		
	wire		[DATA_WIDTH-1:0]			rep_o_current_state_1;
	wire 		[ACTION_WIDTH-1:0]			rep_o_action;
	wire		[DATA_WIDTH-1:0]			rep_o_reward;		
	wire		[DATA_WIDTH-1:0]			rep_o_next_state_0;		
	wire		[DATA_WIDTH-1:0]			rep_o_next_state_1;	
	wire 									rep_o_done;
	wire 									rep_o_ready_for_train;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]			current_state_0_reg;
	reg 		[DATA_WIDTH-1:0]			current_state_1_reg;
	reg 		[ACTION_WIDTH-1:0]			action_predict;
	reg 		[ACTION_WIDTH-1:0]			action_reg;
	reg 		[10-1:0]					update_counter;
	//---------------------------------------------------------//
	
	replay_memory
		#(	.DATA_WIDTH				(DATA_WIDTH),
			.MEMORY_WIDTH			(MEMORY_WIDTH),
			.ACTION_WIDTH			(ACTION_WIDTH)
		)
		replay_memory_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_valid				(rep_i_valid),
			.i_current_state_0		(rep_i_current_state_0),
			.i_current_state_1		(rep_i_current_state_1),
			.i_action				(rep_i_action),
			.i_reward				(rep_i_reward),
			.i_next_state_0			(rep_i_next_state_0),
			.i_next_state_1			(rep_i_next_state_1),
			.i_done					(rep_i_done),
			.o_valid				(rep_o_valid),	
			.o_current_state_0		(rep_o_current_state_0),
			.o_current_state_1		(rep_o_current_state_1),
			.o_action				(rep_o_action),
			.o_reward				(rep_o_reward),
			.o_next_state_0			(rep_o_next_state_0),
			.o_next_state_1			(rep_o_next_state_1),
			.o_done					(rep_o_done),
			.o_ready_for_train		(rep_o_ready_for_train)
		);
	
	ann
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.ACTION_WIDTH					(ACTION_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
			.LEARNING_RATE					(LEARNING_RATE),
			.GAMMA							(GAMMA),
			.UPDATE_RATE					(UPDATE_RATE)
		)
		ann_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(ann_i_valid),
			.i_current_state_0	(ann_i_current_state_0),
			.i_current_state_1	(ann_i_current_state_1),
			.i_reward			(ann_i_reward),
			.i_action			(ann_i_action),
			.i_next_state_0		(ann_i_next_state_0),
			.i_next_state_1		(ann_i_next_state_1),
			.i_done				(ann_i_done),
			.i_weight_valid		(i_weight_valid),
			.i_weight_layer		(i_weight_layer),
			.i_weight_addr		(i_weight_addr),
			.i_weight			(i_weight),
			.i_update_request	(ann_i_update_request),
			.o_action			(ann_o_action),
			.o_action_valid		(ann_o_action_valid)
		);
		
	epsilon_greedy 
		#(	.DATA_WIDTH 			(DATA_WIDTH),
			.EPSILON_DECAY			(EPSILON_DECAY) //0.997
		)
		epsilon_greedy_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(ann_o_action_valid),
			.o_action_random	(eps_o_action_random),
			.o_action_select	(eps_o_action_select),
			.o_valid			(o_action_valid)
		);

	assign o_action = (eps_o_action_select) ? eps_o_action_random : action_predict;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			action_reg <= 'd0;
			current_state_0_reg <= 'd0;
			current_state_1_reg <= 'd0;
			update_counter	<= 'd0;
		end
		else begin
			if (rep_o_ready_for_train) begin
				ann_i_valid 			<= rep_o_valid;
				ann_i_current_state_0 	<= rep_o_current_state_0;
				ann_i_current_state_1 	<= rep_o_current_state_1;
				ann_i_reward			<= rep_o_reward;
				ann_i_action			<= rep_o_action;
				ann_i_next_state_0		<= rep_o_next_state_0;
				ann_i_next_state_1		<= rep_o_next_state_1;
				ann_i_done				<= rep_o_done;
			end
			else begin
				ann_i_valid 			<= i_valid;
				ann_i_current_state_0 	<= current_state_0_reg;
				ann_i_current_state_1 	<= current_state_1_reg;
				ann_i_reward			<= i_reward;
				ann_i_action			<= action_reg;
				ann_i_next_state_0		<= i_state_0;
				ann_i_next_state_1		<= i_state_1;
				ann_i_done				<= i_done;
			end
			
			if (i_valid) begin
				rep_i_valid 			<= 1;
				rep_i_current_state_0 	<= current_state_0_reg;
				rep_i_current_state_1 	<= current_state_1_reg;
				rep_i_reward			<= i_reward;
				rep_i_action			<= action_reg;
				rep_i_next_state_0		<= i_state_0;
				rep_i_next_state_1		<= i_state_1;
				rep_i_done				<= i_done;
			end
			else rep_i_valid 			<= 0;
			
			if (update_counter == NUMBER_OF_TRAIN_TIMES) begin
				ann_i_update_request 	<= 1;
				update_counter 		<= 'd0;
			end
			else begin
				ann_i_update_request 	<= 0;
				if (i_valid) 
					update_counter		<= update_counter + 1;
			end
			
			if (i_valid) begin
				current_state_0_reg <= i_state_0;
				current_state_1_reg <= i_state_1;
			end
			
			if (o_action_valid) begin
				action_reg <= o_action;
			end
			
			if (ann_o_action_valid) begin
				action_predict <= ann_o_action;
			end
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
	
endmodule
