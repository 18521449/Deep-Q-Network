`timescale 1ns/1ps
module ann
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter LAYER_WIDTH	 					= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F, 	//0.002
		parameter [DATA_WIDTH-1:0] GAMMA			= 'h3F4CCCCD, 	//0.8
		parameter [DATA_WIDTH-1:0] UPDATE_RATE		= 'h3F000000 	//0.5
	)
	(	clk,
		rst_n,
		i_valid,
		i_current_state_0,
		i_current_state_1,
		i_reward,
		i_action,
		i_next_state_0,
		i_next_state_1,
		i_done,
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		i_load_weight_done,
		i_train_mode,
		i_update_request,
		o_update_done,
		o_action,
		o_action_valid,
		o_main_net_done
	);
	
	localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_valid;
	input 		[DATA_WIDTH-1:0]			i_current_state_0;
	input 		[DATA_WIDTH-1:0]			i_current_state_1;
	input 		[DATA_WIDTH-1:0]			i_reward;
	input 		[ACTION_WIDTH-1:0]			i_action;
	input 		[DATA_WIDTH-1:0]			i_next_state_0;
	input 		[DATA_WIDTH-1:0]			i_next_state_1;
	input 									i_done;
	input 									i_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_weight;
	input 									i_load_weight_done;
	input 									i_train_mode;
	input 									i_update_request;
	output 									o_update_done;
	output 	       							o_action_valid;
	output     	[ACTION_WIDTH-1:0]			o_action;
	output     								o_main_net_done;
	//----------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[1:0]						finite_state_machine;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									main_i_data_valid;
	reg 		[DATA_COUNTER_WIDTH-1:0]	main_i_data_addr;
	reg 		[DATA_WIDTH-1:0]			main_i_data;
	reg 									main_i_weight_valid;
	reg 		[LAYER_WIDTH-1:0]			main_i_weight_layer;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	main_i_weight_addr;
	reg			[DATA_WIDTH-1:0]			main_i_weight;
	reg 									main_i_load_weight_done;
	wire 									main_o_weight_valid;
	wire 		[LAYER_WIDTH-1:0]			main_o_weight_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	main_o_weight_addr;
	wire 		[DATA_WIDTH-1:0]			main_o_weight;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									target_i_data_valid;
	reg 		[DATA_COUNTER_WIDTH-1:0]	target_i_data_addr;
	reg 		[DATA_WIDTH-1:0]			target_i_data;
	reg 									target_i_weight_valid;
	reg 		[LAYER_WIDTH-1:0]			target_i_weight_layer;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	target_i_weight_addr;
	reg			[DATA_WIDTH-1:0]			target_i_weight;
	reg 									target_i_load_weight_done;
	wire 									target_o_weight_valid;
	wire 		[LAYER_WIDTH-1:0]			target_o_weight_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	target_o_weight_addr;
	wire 		[DATA_WIDTH-1:0]			target_o_weight;
	wire 									target_o_q_max_valid;
	wire		[DATA_WIDTH-1:0]			target_o_q_max;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 									soft_weight_valid_request;
	wire 		[LAYER_WIDTH-1:0]			soft_weight_layer_request;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	soft_weight_addr_request;
	wire 									soft_update_weight_valid;
	wire 		[LAYER_WIDTH-1:0]			soft_update_weight_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	soft_update_weight_addr;
	wire		[DATA_WIDTH-1:0]			soft_update_weight;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 									loss_value_valid;
	wire		[DATA_WIDTH-1:0]			loss_value;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]			current_state_1_reg;
	reg			[DATA_WIDTH-1:0]			next_state_1_reg;
	reg 									delay_reg;
	//---------------------------------------------------------//
	
	main_net
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.ACTION_WIDTH					(ACTION_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
			.LEARNING_RATE					(LEARNING_RATE)
		)
		main_net_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_data_valid			(main_i_data_valid),
			.i_data_addr			(main_i_data_addr),
			.i_data					(main_i_data),
			.i_loss_value_valid		(loss_value_valid),
			.i_loss_value			(loss_value),
			.i_train_action_valid	(i_valid),
			.i_train_action			(i_action),
			.i_weight_valid			(main_i_weight_valid),
			.i_weight_layer			(main_i_weight_layer),
			.i_weight_addr			(main_i_weight_addr),
			.i_weight				(main_i_weight),
			.i_load_weight_done		(main_i_load_weight_done),
			.i_train_mode			(i_train_mode),
			.i_update_request		(i_update_request),
			.o_weight_valid			(main_o_weight_valid),
			.o_weight_layer			(main_o_weight_layer),
			.o_weight_addr			(main_o_weight_addr),
			.o_weight				(main_o_weight),
			.o_arg_max_valid		(o_action_valid),
			.o_arg_max				(o_action),
			.o_main_net_done		(o_main_net_done)
		);
		
	ann_soft_update 
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
			.UPDATE_RATE					(UPDATE_RATE)
		)
		soft_update_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_update_request		(i_update_request),
			.i_target_weight_valid	(target_o_weight_valid),
			.i_target_weight_layer	(target_o_weight_layer),
			.i_target_weight_addr	(target_o_weight_addr),
			.i_target_weight		(target_o_weight),
			.i_main_weight_valid	(main_o_weight_valid),
			.i_main_weight_layer	(main_o_weight_layer),
			.i_main_weight_addr		(main_o_weight_addr),
			.i_main_weight			(main_o_weight),
			.o_weight_valid_request	(soft_weight_valid_request),
			.o_weight_layer_request	(soft_weight_layer_request),
			.o_weight_addr_request	(soft_weight_addr_request),
			.o_update_weight_done	(o_update_done),
			.o_update_weight_valid	(soft_update_weight_valid),
			.o_update_weight_layer	(soft_update_weight_layer),
			.o_update_weight_addr	(soft_update_weight_addr),
			.o_update_weight		(soft_update_weight)
	   );	
		
	target_net
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE)
			)
		target_net_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_data_valid			(target_i_data_valid),
			.i_data_addr			(target_i_data_addr),
			.i_data					(target_i_data),
			.i_weight_valid			(target_i_weight_valid),
			.i_weight_layer			(target_i_weight_layer),
			.i_weight_addr			(target_i_weight_addr),
			.i_weight				(target_i_weight),
			.i_load_weight_done		(target_i_load_weight_done),
			.i_update_request		(i_update_request),
			.o_weight_valid			(target_o_weight_valid),
			.o_weight_layer			(target_o_weight_layer),
			.o_weight_addr			(target_o_weight_addr),
			.o_weight				(target_o_weight),
			.o_q_max				(target_o_q_max),
			.o_q_max_valid			(target_o_q_max_valid)
		);
	
	ann_loss_function 
		#(	.DATA_WIDTH		(DATA_WIDTH),
			.GAMMA			(GAMMA)
		)
		loss_function_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_q_max_valid		(target_o_q_max_valid),
			.i_q_max			(target_o_q_max),
			.i_reward_valid		(i_valid),
			.i_reward			(i_reward),
			.i_done				(i_done),
			.o_loss_value		(loss_value),
			.o_loss_value_valid	(loss_value_valid)
	   );
	
	initial begin
		finite_state_machine 	<= 2'b00;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			target_i_weight_valid 	<= 0;
			main_i_weight_valid		<= 0;
			current_state_1_reg		<= 'd0;
			next_state_1_reg		<= 'd0;
			finite_state_machine 	<= 2'b00;
		end
		else begin
		
			case (finite_state_machine)
				2'b00: // weight initialization
					begin
						target_i_weight_valid 		<= i_weight_valid;
						target_i_weight_layer		<= i_weight_layer;
						target_i_weight_addr		<= i_weight_addr;
						target_i_weight				<= i_weight;
						target_i_load_weight_done	<= i_load_weight_done;
						
						main_i_weight_valid 		<= i_weight_valid;
						main_i_weight_layer			<= i_weight_layer;
						main_i_weight_addr			<= i_weight_addr;
						main_i_weight				<= i_weight;
						main_i_load_weight_done		<= i_load_weight_done;
						
						if (i_load_weight_done) begin
							finite_state_machine <= 2'b01;
						end
					end
				2'b01: // interactive mode
					begin
						if (i_valid) begin
							target_i_data_valid 		<= 0;
							target_i_load_weight_done 	<= 0;
							main_i_load_weight_done		<= 0;
							
							main_i_data_valid 			<= 1;
							main_i_data_addr 			<= 'd0;
							main_i_data 				<= i_current_state_0;
							current_state_1_reg 		<= i_current_state_1;
							
							delay_reg <= 1;
						end
						else begin
							if (delay_reg) begin
								delay_reg <= 0;
								
								main_i_data_valid 		<= 1;
								main_i_data_addr 		<= 'd1;
								main_i_data 			<= current_state_1_reg;
							end
							else begin
								main_i_data_valid 		<= 0;
							end
						end
						
						if (i_train_mode) begin
							finite_state_machine <= 2'b10;
						end
					end
				2'b10: // training mode
					begin
						if (i_valid) begin
							target_i_data_valid 	<= 1;
							target_i_data_addr 		<= 'd0;
							target_i_data 			<= i_next_state_0;
							next_state_1_reg		<= i_next_state_1;
							
							main_i_data_valid 		<= 1;
							main_i_data_addr 		<= 'd0;
							main_i_data 			<= i_current_state_0;
							current_state_1_reg 	<= i_current_state_1;
							
							delay_reg <= 1;
						end
						else begin
							if (delay_reg) begin
								delay_reg <= 0;
								
								target_i_data_valid 	<= 1;
								target_i_data_addr 		<= 'd1;
								target_i_data 			<= next_state_1_reg;
								
								main_i_data_valid 		<= 1;
								main_i_data_addr 		<= 'd1;
								main_i_data 			<= current_state_1_reg;
							end
							else begin
								target_i_data_valid 	<= 0;
								main_i_data_valid 		<= 0;
							end
						end
						
						if (i_update_request) begin
							finite_state_machine <= 2'b11;
						end
						
					end
				2'b11: // weight synchronization
					begin
						if (!soft_update_weight_valid) begin
							target_i_weight_valid 		<= soft_weight_valid_request;
							target_i_weight_layer		<= soft_weight_layer_request;
							target_i_weight_addr		<= soft_weight_addr_request;
							
							main_i_weight_valid 		<= soft_weight_valid_request;
							main_i_weight_layer			<= soft_weight_layer_request;
							main_i_weight_addr			<= soft_weight_addr_request;
						end
						else begin
							main_i_weight_valid			<= 0;
							
							target_i_weight_valid 		<= soft_update_weight_valid;
							target_i_weight_layer		<= soft_update_weight_layer;
							target_i_weight_addr		<= soft_update_weight_addr;
							target_i_weight				<= soft_update_weight;
							target_i_load_weight_done	<= o_update_done;
							
						end
						
						if (target_i_load_weight_done) begin
							target_i_load_weight_done 	<= 0;
							finite_state_machine 		<= 2'b01;
						end
					end
				default: finite_state_machine <= 2'b00;
			endcase
		
		end
	end	
	
endmodule
