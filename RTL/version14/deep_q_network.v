`timescale 1ns/1ps
module deep_q_network
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter MEMORY_WIDTH						= 10000,
		parameter TRAIN_START 						= 20,
		parameter BATCH_SIZE						= 2,
		parameter LAYER_WIDTH	 					= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3A83126F, 	//0.001
		parameter [DATA_WIDTH-1:0] GAMMA			= 'h3F4CCCCD, 	//0.8
		parameter [DATA_WIDTH-1:0] UPDATE_RATE		= 'h3F000000, 	//0.5
		parameter [DATA_WIDTH-1:0] EPSILON_DECAY	= 'h3F7F3B64, 	//0.997
		parameter [DATA_WIDTH-1:0] EPSILON_MIN		= 'h3C23D70A 	//0.01
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
		i_load_weight_done,
		o_action,
		o_action_valid,
		o_train_done,
		o_ready_for_train
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
	input 									i_load_weight_done;
	output		[ACTION_WIDTH-1:0]			o_action;
	output 									o_action_valid;
	output reg								o_train_done;
	output 									o_ready_for_train;
	//----------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[1:0]						finite_state_machine;
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
	wire 									ann_o_main_net_done;
	wire 									ann_o_update_done;
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
	reg 									rep_i_main_net_done;
	wire 									rep_o_valid;
	wire		[DATA_WIDTH-1:0]			rep_o_current_state_0;		
	wire		[DATA_WIDTH-1:0]			rep_o_current_state_1;
	wire 		[ACTION_WIDTH-1:0]			rep_o_action;
	wire		[DATA_WIDTH-1:0]			rep_o_reward;		
	wire		[DATA_WIDTH-1:0]			rep_o_next_state_0;		
	wire		[DATA_WIDTH-1:0]			rep_o_next_state_1;	
	wire 									rep_o_done;
	wire 									rep_o_train_mode;
	wire 									rep_o_update_request;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]			current_state_0_reg;
	reg 		[DATA_WIDTH-1:0]			current_state_1_reg;
	reg 		[ACTION_WIDTH-1:0]			action_reg;
	//---------------------------------------------------------//
	
	replay_memory
		#(	.DATA_WIDTH				(DATA_WIDTH),
			.MEMORY_WIDTH			(MEMORY_WIDTH),
			.TRAIN_START			(TRAIN_START),
			.BATCH_SIZE				(BATCH_SIZE),
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
			.i_main_net_done		(ann_o_main_net_done),
			.o_valid				(rep_o_valid),	
			.o_current_state_0		(rep_o_current_state_0),
			.o_current_state_1		(rep_o_current_state_1),
			.o_action				(rep_o_action),
			.o_reward				(rep_o_reward),
			.o_next_state_0			(rep_o_next_state_0),
			.o_next_state_1			(rep_o_next_state_1),
			.o_done					(rep_o_done),
			.o_train_mode			(rep_o_train_mode),
			.o_update_request		(rep_o_update_request),
			.o_ready_for_train		(o_ready_for_train)
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
			.i_load_weight_done	(i_load_weight_done),
			.i_train_mode		(rep_o_train_mode),
			.i_update_request	(rep_o_update_request),
			.o_update_done		(ann_o_update_done),
			.o_action			(ann_o_action),
			.o_action_valid		(ann_o_action_valid),
			.o_main_net_done	(ann_o_main_net_done)
		);
		
	epsilon_greedy 
		#(	.DATA_WIDTH 			(DATA_WIDTH),
			.EPSILON_DECAY			(EPSILON_DECAY), //0.997
			.EPSILON_MIN			(EPSILON_MIN) //0.01
		)
		epsilon_greedy_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(ann_o_action_valid),
			.i_action_predict	(ann_o_action),
			.i_train_mode		(rep_o_train_mode),
			.o_action			(o_action),
			.o_action_valid		(o_action_valid)
		);
	
	initial begin
		finite_state_machine <= 2'b00;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			action_reg 				<= 'd0;
			current_state_0_reg 	<= 'd0;
			current_state_1_reg 	<= 'd0;
			finite_state_machine 	<= 2'b00;
			o_train_done			<= 0;
		end
		else begin
		
			if (i_valid) begin
				current_state_0_reg <= i_state_0;
				current_state_1_reg <= i_state_1;
			end
			
			if (o_action_valid) begin
				action_reg <= o_action;
			end

			// FINITE STATE MACHINE
			case (finite_state_machine)
				2'b00: // weight initialization
					begin 
						if (i_load_weight_done) begin
							finite_state_machine <= 2'b01;
						end
					end
				2'b01: // state initialization
					begin
						rep_i_valid 			<= 0;
						o_train_done 			<= 0;

						if (i_valid) begin
							finite_state_machine 	<= 2'b10;
							ann_i_valid 			<= i_valid;
							ann_i_current_state_0 	<= i_state_0;
							ann_i_current_state_1 	<= i_state_1;
						end

						if (rep_o_train_mode) begin
							finite_state_machine <= 2'b11;
						end
					end
				2'b10: // interactive mode
					begin
						rep_i_valid 			<= i_valid;
						rep_i_current_state_0 	<= current_state_0_reg;
						rep_i_current_state_1 	<= current_state_1_reg;
						rep_i_reward			<= i_reward;
						rep_i_action			<= action_reg;
						rep_i_next_state_0		<= i_state_0;
						rep_i_next_state_1		<= i_state_1;
						rep_i_done				<= i_done;
						
						if(i_done) begin
							finite_state_machine 	<= 2'b01;
						end

						else begin
							ann_i_valid 			<= i_valid;
							ann_i_current_state_0 	<= i_state_0;
							ann_i_current_state_1 	<= i_state_1;
						end
						
					end
				2'b11: // training mode
					begin
						rep_i_valid 			<= 0;

						ann_i_valid 			<= rep_o_valid;
						ann_i_current_state_0 	<= rep_o_current_state_0;
						ann_i_current_state_1 	<= rep_o_current_state_1;
						ann_i_reward			<= rep_o_reward;
						ann_i_action			<= rep_o_action;
						ann_i_next_state_0		<= rep_o_next_state_0;
						ann_i_next_state_1		<= rep_o_next_state_1;
						ann_i_done				<= rep_o_done;
						
						if (ann_o_update_done) begin
							finite_state_machine	<= 2'b01;
							o_train_done 			<= 1;
						end
					end
				default: finite_state_machine <= 2'b00;
			endcase

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
	
	// `ifdef COCOTB_SIM
	// 	initial begin 
	// 		$dumpfile("waveform3.vcd");
	// 		$dumpvars(0, deep_q_network);
	// 		#1;
	// 	end
	// `endif 

endmodule
