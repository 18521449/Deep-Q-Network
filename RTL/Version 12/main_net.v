`timescale 1ns/1ps
module main_net
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter LAYER_WIDTH	 					= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F //0.002
	)
	(	clk,
		rst_n,
		
		i_data_valid,
		i_data_addr,
		i_data,
		
		i_loss_value_valid,
		i_loss_value,
		
		i_train_action_valid,
		i_train_action,
		
		i_weight_valid, // load weight valid
		i_weight_layer,
		i_weight_addr,
		i_weight,
		i_load_weight_done,
		
		i_train_mode,
		
		i_update_request,
		o_weight_valid,
		o_weight_layer,
		o_weight_addr,
		o_weight,
		
		o_arg_max_valid,
		o_arg_max,
		
		o_main_net_done
	);
	localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_data_valid;
	input 		[DATA_COUNTER_WIDTH-1:0]	i_data_addr;
	input 		[DATA_WIDTH-1:0]			i_data;
	input 									i_loss_value_valid;
	input 		[DATA_WIDTH-1:0]			i_loss_value;
	input 									i_train_action_valid;
	input 		[ACTION_WIDTH-1:0]			i_train_action;
	input 									i_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_weight;
	input 									i_load_weight_done;
	input 									i_train_mode;
	input									i_update_request;
	output reg								o_weight_valid;
	output reg	[LAYER_WIDTH-1:0]			o_weight_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr;
	output reg 	[DATA_WIDTH-1:0]			o_weight;
	output     								o_arg_max_valid;
	output 	   [LAYER_WIDTH-1:0]			o_arg_max;
	output reg 								o_main_net_done;
	//----------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[1:0]						finite_state_machine;
	reg 		[1:0]						active_mode;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									mem_i_data_valid;
	reg 									mem_i_rw_data_select;
	reg 		[LAYER_WIDTH-1:0]			mem_i_data_layer;
	reg 		[DATA_COUNTER_WIDTH-1:0]	mem_i_data_addr;
	reg 		[DATA_WIDTH-1:0]			mem_i_data;
	reg 									mem_i_weight_valid;
	reg 									mem_i_rw_weight_select;
	reg 		[LAYER_WIDTH-1:0]			mem_i_weight_layer;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	mem_i_weight_addr;
	reg 		[DATA_WIDTH-1:0]			mem_i_weight;
	wire 									mem_o_data_valid;
	wire 		[LAYER_WIDTH-1:0]			mem_o_data_layer;
	wire 		[DATA_COUNTER_WIDTH-1:0]	mem_o_data_addr;
	wire 		[DATA_WIDTH-1:0]			mem_o_data;
	wire 									mem_o_weight_valid;
	wire 		[LAYER_WIDTH-1:0]			mem_o_weight_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	mem_o_weight_addr;
	wire 		[DATA_WIDTH-1:0]			mem_o_weight;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 									fw_o_weight_valid_request;
	wire 		[LAYER_WIDTH-1:0]			fw_o_weight_layer_request;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	fw_o_weight_addr_request;
	wire 									fw_o_data_valid;
	wire 		[LAYER_WIDTH-1:0]			fw_o_data_layer;
	wire 		[DATA_COUNTER_WIDTH-1:0]	fw_o_data_addr;
	wire 		[DATA_WIDTH-1:0]			fw_o_data;
	wire 									bp_o_weight_valid_request;
	wire 		[LAYER_WIDTH-1:0]			bp_o_weight_layer_request;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	bp_o_weight_addr_request;
	wire 									bp_o_error_valid;
	wire 		[LAYER_WIDTH-1:0]			bp_o_error_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	bp_o_error_addr;
	wire 		[DATA_WIDTH-1:0]			bp_o_error;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 									upd_o_weight_valid_request;
	wire 		[LAYER_WIDTH-1:0]			upd_o_weight_layer_request;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	upd_o_weight_addr_request;
	wire 									upd_o_new_weight_valid;
	wire 		[LAYER_WIDTH-1:0]			upd_o_new_weight_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	upd_o_new_weight_addr;
	wire 		[DATA_WIDTH-1:0]			upd_o_new_weight;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									valid_bp;
	reg 									valid_fw;
	reg 									valid_upd;
	reg 									valid_arg;
	reg 									loss_value_active;
	reg 									train_action_active;
	reg 		[DATA_WIDTH-1:0] 			loss_value;
	reg 		[ACTION_WIDTH-1:0]			train_action;
	//---------------------------------------------------------//

	feed_forward	
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
		)
		feed_forward_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_data_valid			(i_data_valid),
			.i_data_layer			(2'b00),
			.i_data_addr			(i_data_addr),
			.i_data					(i_data),
			.i_weight_valid			(valid_fw & mem_o_weight_valid),
			.i_weight_layer			(mem_o_weight_layer),
			.i_weight_addr			(mem_o_weight_addr),
			.i_weight				(mem_o_weight),
			.o_weight_valid_request	(fw_o_weight_valid_request),
			.o_weight_layer_request	(fw_o_weight_layer_request), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
			.o_weight_addr_request	(fw_o_weight_addr_request),
			.o_data_valid			(fw_o_data_valid),
			.o_data_layer			(fw_o_data_layer),
			.o_data_addr			(fw_o_data_addr),
			.o_data					(fw_o_data)
		);
		
	ann_memory
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
		)
		memory_block
		(	.clk					(clk),
			.i_ram_data_enable		(mem_i_data_valid),
			.i_rw_data_select		(mem_i_rw_data_select), // 1 for read, 0 for write
			.i_data_layer			(mem_i_data_layer),
			.i_data_addr			(mem_i_data_addr),
			.i_data					(mem_i_data),
			.i_ram_weight_enable	(mem_i_weight_valid),
			.i_rw_weight_select		(mem_i_rw_weight_select), // 1 for read, 0 for write
			.i_weight_layer			(mem_i_weight_layer),
			.i_weight_addr			(mem_i_weight_addr),
			.i_weight				(mem_i_weight),
			.o_data_valid			(mem_o_data_valid),
			.o_data_layer			(mem_o_data_layer),
			.o_data_addr			(mem_o_data_addr),
			.o_data					(mem_o_data),	
			.o_weight_valid			(mem_o_weight_valid),
			.o_weight_layer			(mem_o_weight_layer),
			.o_weight_addr			(mem_o_weight_addr),
			.o_weight				(mem_o_weight)
		);
		
	back_propagation	
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE),
			.LEARNING_RATE					(LEARNING_RATE)
		)
		back_propagation_block
		(	.clk					(clk),
			.rst_n					(rst_n),	
			.i_data_valid			(fw_o_data_valid),
			.i_data_layer			(fw_o_data_layer),
			.i_data_addr			(fw_o_data_addr),
			.i_data					(fw_o_data),
			.i_data_expected_valid	(fw_o_data_valid & (fw_o_data_layer == 2'b11)),
			.i_data_expected_addr	(fw_o_data_addr),
			.i_data_expected		((fw_o_data_addr == train_action) ? loss_value : fw_o_data),
			.i_weight_valid			(valid_bp & mem_o_weight_valid),
			.i_weight_layer			(mem_o_weight_layer),
			.i_weight_addr			(mem_o_weight_addr),
			.i_weight				(mem_o_weight),
			.o_weight_valid_request	(bp_o_weight_valid_request),
			.o_weight_layer_request	(bp_o_weight_layer_request), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
			.o_weight_addr_request	(bp_o_weight_addr_request),
			.o_error_valid			(bp_o_error_valid),
			.o_error_layer			(bp_o_error_layer),
			.o_error_addr			(bp_o_error_addr),
			.o_error				(bp_o_error)	
		);
		
	main_net_argument_max
		#(	.DATA_WIDTH 				(DATA_WIDTH),
			.NUMBER_OF_OUTPUT_NODE		(NUMBER_OF_OUTPUT_NODE)
		)
		argument_max_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_data_valid		(valid_arg & fw_o_data_valid & (fw_o_data_layer == 2'b11)),
			.i_data_addr		(fw_o_data_addr),
			.i_data				(fw_o_data),
			.o_arg_max			(o_arg_max),
			.o_arg_max_valid	(o_arg_max_valid)
		);

	main_net_update_weight	
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),	
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
		)
		update_weight_block
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_weight_valid			(valid_upd & mem_o_weight_valid),
			.i_weight_layer			(mem_o_weight_layer),
			.i_weight_addr			(mem_o_weight_addr),
			.i_weight				(mem_o_weight),
			.i_error_valid			(bp_o_error_valid),
			.i_error_layer			(bp_o_error_layer),
			.i_error_addr			(bp_o_error_addr),
			.i_error				(bp_o_error),
			.o_weight_valid_request	(upd_o_weight_valid_request),
			.o_weight_layer_request	(upd_o_weight_layer_request), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
			.o_weight_addr_request	(upd_o_weight_addr_request),
			.o_new_weight_valid		(upd_o_new_weight_valid),
			.o_new_weight_layer		(upd_o_new_weight_layer),
			.o_new_weight_addr		(upd_o_new_weight_addr),
			.o_new_weight			(upd_o_new_weight)	
		);
	
	initial begin
		finite_state_machine <= 2'b00;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			finite_state_machine 	<= 2'b00;
			loss_value_active		<= 0;
			train_action_active 	<= 0;
		end
		else begin
			
			if (i_loss_value_valid) begin
				loss_value <= i_loss_value;
				loss_value_active <= 1;
			end
			
			if (i_train_action_valid) begin
				train_action <= i_train_action;
				train_action_active <= 1;
			end
			
			
			if (i_update_request) begin
				finite_state_machine <= 2'b11;
			end
			
			case (finite_state_machine)
				2'b00: // weight initialization
					begin	
						mem_i_weight_valid 		<= i_weight_valid;
						mem_i_rw_weight_select 	<= 1'b0; // write weight
						mem_i_weight_layer 		<= i_weight_layer;
						mem_i_weight_addr		<= i_weight_addr;
						mem_i_weight 			<= i_weight;
						
						if (i_load_weight_done) begin
							finite_state_machine <= 2'b01;
						end
					end
				2'b01: // interactive mode
					begin
						valid_fw 	<= 1;
						valid_arg	<= 1;
						valid_bp 	<= 0;
						valid_upd 	<= 0;
						o_main_net_done <= 0;
						
						mem_i_weight_valid 		<= fw_o_weight_valid_request;
						mem_i_rw_weight_select 	<= 1'b1; // read weight
						mem_i_weight_layer 		<= fw_o_weight_layer_request;
						mem_i_weight_addr		<= fw_o_weight_addr_request;
						
						if (i_train_mode) begin
							finite_state_machine <= 2'b10;
							active_mode	<= 2'b00;
						end
					end
				2'b10: // training mode
					begin
						valid_arg	<= 0;
						case (active_mode)
							2'b00: // feed forward mode
								begin
									valid_fw 	<= 1;
									valid_bp 	<= 0;
									valid_upd 	<= 0;
									
									mem_i_weight_valid 		<= fw_o_weight_valid_request;
									mem_i_rw_weight_select 	<= 1'b1; // read weight
									mem_i_weight_layer 		<= fw_o_weight_layer_request;
									mem_i_weight_addr		<= fw_o_weight_addr_request;
									
									mem_i_data_valid 		<= fw_o_data_valid;
									mem_i_rw_data_select 	<= 1'b0; // write data
									mem_i_data_layer 		<= fw_o_data_layer;
									mem_i_data_addr 		<= fw_o_data_addr;
									mem_i_data 				<= fw_o_data;
									
									if (fw_o_data_valid & (fw_o_data_layer == 2'b11)) begin
										if (fw_o_data_addr == NUMBER_OF_OUTPUT_NODE-1) begin
											active_mode	<= 2'b01;
										end
									end
								end
							2'b01: // back propagation mode
								begin
									valid_fw 	<= 0;
									valid_bp 	<= 1;
									valid_upd 	<= 0;
								
									mem_i_weight_valid 		<= bp_o_weight_valid_request;
									mem_i_rw_weight_select 	<= 1'b1; // read weight
									mem_i_weight_layer 		<= bp_o_weight_layer_request;
									mem_i_weight_addr		<= bp_o_weight_addr_request;
									
									if (mem_o_weight_valid & (mem_o_weight_layer == 2'b10)) begin
										if (mem_o_weight_addr == NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin
											active_mode <= 2'b10;
										end
									end
								end
							2'b10: // update weight mode
								begin
									valid_fw 	<= 0;
									valid_bp 	<= 0;
									valid_upd 	<= 1;
									
									mem_i_weight_valid 		<= upd_o_weight_valid_request;
									mem_i_rw_weight_select 	<= 1'b1; // read weight
									mem_i_weight_layer 		<= upd_o_weight_layer_request;
									mem_i_weight_addr		<= upd_o_weight_addr_request;
									
									if (mem_o_weight_valid & (mem_o_weight_layer == 2'b01)) begin
										if (mem_o_weight_addr == NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin
											active_mode <= 2'b11;
										end
									end
								end
							2'b11: // load new weight
								begin
									valid_fw 	<= 0;
									valid_bp 	<= 0;
									valid_upd 	<= 0;
									
									mem_i_weight_valid 		<= upd_o_new_weight_valid;
									mem_i_rw_weight_select 	<= 1'b0; // write
									mem_i_weight_layer 		<= upd_o_new_weight_layer;
									mem_i_weight_addr		<= upd_o_new_weight_addr;
									mem_i_weight			<= upd_o_new_weight;
									
									if (upd_o_new_weight_valid && (upd_o_new_weight_layer == 2'b11)) begin
										if (upd_o_new_weight_addr == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
											o_main_net_done <= 1;
											active_mode <= 2'b00;
											finite_state_machine <= 2'b01;
										end
									end
								end
							default: active_mode <= 2'b00;
						endcase
						
					end
				
				2'b11: // soft update request
					begin
						valid_fw 	<= 0;
						valid_arg	<= 0;
						valid_bp 	<= 0;
						valid_upd 	<= 0;
						o_main_net_done <= 0;
						
						mem_i_weight_valid 		<= i_weight_valid;
						mem_i_rw_weight_select 	<= 1'b1; // read weight
						mem_i_weight_layer 		<= i_weight_layer;
						mem_i_weight_addr		<= i_weight_addr;
						mem_i_weight 			<= i_weight;
						
						o_weight_valid 			<= mem_o_weight_valid;
						o_weight_layer 			<= mem_o_weight_layer;
						o_weight_addr 			<= mem_o_weight_addr;
						o_weight 				<= mem_o_weight;
						
						if (o_weight_valid && (o_weight_layer == 2'b11)) begin
							if (o_weight_addr == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
								finite_state_machine <= 2'b01;
							end
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
	
endmodule
