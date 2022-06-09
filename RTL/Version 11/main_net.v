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
		i_rw_weight_select,
		i_weight_layer,
		i_weight_addr,
		i_weight,
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
	input									i_rw_weight_select;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_weight;
	output reg								o_weight_valid;
	output reg	[LAYER_WIDTH-1:0]			o_weight_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr;
	output reg 	[DATA_WIDTH-1:0]			o_weight;
	output reg								o_arg_max_valid;
	output reg	[LAYER_WIDTH-1:0]			o_arg_max;
	output reg 								o_main_net_done;
	//----------------------------------------------------//
	
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
	reg 									bp_i_data_valid;
	reg 									bp_i_data_expected_valid;
	reg 		[DATA_COUNTER_WIDTH-1:0]	bp_i_data_expected_addr;
	reg 		[DATA_WIDTH-1:0]			bp_i_data_expected; 
	wire 									bp_o_weight_valid_request;
	wire 		[LAYER_WIDTH-1:0]			bp_o_weight_layer_request;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	bp_o_weight_addr_request;
	wire 									bp_o_error_valid;
	wire 		[LAYER_WIDTH-1:0]			bp_o_error_layer;
	wire 		[WEIGHT_COUNTER_WIDTH-1:0]	bp_o_error_addr;
	wire 		[DATA_WIDTH-1:0]			bp_o_error;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 									arg_max_valid_in;
	reg 		[ACTION_WIDTH-1:0]			arg_max_data_in_addr;
	reg 		[DATA_WIDTH-1:0]			arg_max_data_in;
	wire 									arg_max_valid_out;
	wire 		[ACTION_WIDTH-1:0]			arg_max_data_out;
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
	reg 		[2:0]						active_mode;
	reg 									update_mode;
	reg 									valid_bp;
	reg 									valid_fw;
	reg 									valid_upd;
	reg 									load_data_bp;
	reg 									load_expected;
	reg 									loss_value_active;
	reg 									train_action_active;
	reg 		[DATA_COUNTER_WIDTH-1:0] 	node_counter;
	reg 		[DATA_WIDTH-1:0] 			loss_value;
	reg 		[ACTION_WIDTH-1:0]			train_action;
	reg 		[LAYER_WIDTH-1:0]			data_layer;
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
			.i_data_valid			(bp_i_data_valid & mem_o_data_valid),
			.i_data_layer			(mem_o_data_layer),
			.i_data_addr			(mem_o_data_addr),
			.i_data					(mem_o_data),
			.i_data_expected_valid	(bp_i_data_expected_valid),
			.i_data_expected_addr	(bp_i_data_expected_addr),
			.i_data_expected		(bp_i_data_expected),
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
			.i_data_valid		(arg_max_valid_in),
			.i_data_addr		(arg_max_data_in_addr),
			.i_data				(arg_max_data_in),
			.o_arg_max			(arg_max_data_out), // addr of data
			.o_arg_max_valid	(arg_max_valid_out)
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
		active_mode <= 'd0;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			active_mode <= 3'b000; // initial mode
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
			
			if (i_weight_valid) begin
				active_mode <= 3'b000;
				mem_i_weight_valid 		<= i_weight_valid;
				mem_i_rw_weight_select 	<= i_rw_weight_select; // write weight
				mem_i_weight_layer 		<= i_weight_layer;
				mem_i_weight_addr		<= i_weight_addr;
				mem_i_weight 			<= i_weight;
				if (i_rw_weight_select) begin	
					o_weight_valid 	<= mem_o_weight_valid;
					o_weight_layer 	<= mem_o_weight_layer;
					o_weight_addr 	<= mem_o_weight_addr;
					o_weight 		<= mem_o_weight;
							
					if (mem_o_weight_valid & (mem_o_weight_layer == 2'b11)) begin
						if (mem_o_weight_addr == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
							update_mode	<= 0;
							active_mode <= 3'b001;
						end
					end
				end
				else begin
					o_weight_valid <= 0;
					if (i_weight_valid) begin
						if (i_weight_layer == 'b11) begin
							if (i_weight_addr == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
								active_mode <= 3'b001;
							end
						end
					end
				end
			end
			else begin
				if (i_data_valid) begin
					active_mode <= 3'b001;
				end
			end
			
			case(active_mode)
				3'b000: // weight initialization
					begin	
						o_main_net_done 		<= 0;
					end
					
				3'b001: // load state data
					begin
						o_main_net_done 		<= 0;
						mem_i_data_valid 		<= i_data_valid;
						mem_i_rw_data_select 	<= 1'b0; // write data
						mem_i_data_layer 		<= 2'b00;
						mem_i_data_addr			<= i_data_addr;
						mem_i_data 				<= i_data;			
						
						if (i_data_valid) begin
							if (i_data_addr == NUMBER_OF_INPUT_NODE-1) begin
								active_mode <= 3'b010;
							end
						end
					end

				3'b010: // feed forward mode
					begin
						valid_fw 			<= 1;
						valid_bp 			<= 0;
						valid_upd 			<= 0;
						
						mem_i_weight_valid 		<= fw_o_weight_valid_request;
						mem_i_rw_weight_select 	<= 1'b1; // read weight
						mem_i_weight_layer 		<= fw_o_weight_layer_request;
						mem_i_weight_addr		<= fw_o_weight_addr_request;
						
						mem_i_data_valid 		<= fw_o_data_valid;
						mem_i_rw_data_select 	<= 1'b0; // write data
						mem_i_data_layer 		<= fw_o_data_layer;
						mem_i_data_addr 		<= fw_o_data_addr;
						mem_i_data 				<= fw_o_data;
						
						if (fw_o_data_valid) begin
							if (fw_o_data_layer == 2'b11) begin
							
								arg_max_valid_in 		<= 1;
								arg_max_data_in_addr 	<= fw_o_data_addr;
								arg_max_data_in 		<= fw_o_data;
								
								if (fw_o_data_addr == NUMBER_OF_OUTPUT_NODE-1) begin
									active_mode <= 3'b011;
								end
							end
							else arg_max_valid_in <= 0;
						end
						else arg_max_valid_in <= 0;
					end

				3'b011: // load expected data for back propagation and load argument max data out
					begin
						valid_fw 			<= 0;
						valid_bp 			<= 0;
						valid_upd 			<= 0;
						arg_max_valid_in 	<= 0;
						
						if (arg_max_valid_out) begin
							o_arg_max_valid 	<= 1;
							o_arg_max 			<= arg_max_data_out;
							load_expected 		<= 1;
							node_counter 		<= 'd0;
						end
						else o_arg_max_valid <= 0;
						
						if (train_action_active & loss_value_active) begin
							if (load_expected) begin
								if (node_counter < NUMBER_OF_OUTPUT_NODE) begin
									mem_i_data_valid 		<= 1;
									mem_i_rw_data_select	<= 1'b1; // read data
									mem_i_data_layer 		<= 2'b11;
									mem_i_data_addr 		<= node_counter;
									node_counter 			<= node_counter + 1;
								end
								else begin
									node_counter 		<= 'd0;
									load_expected 		<= 0;
									mem_i_data_valid 	<= 0;
									data_layer		 	<= 2'b00;
								end
							end
							else mem_i_data_valid 		<= 0;
						end
						else mem_i_data_valid 		<= 0;
						
						if (mem_o_data_valid) begin
							if (mem_o_data_layer == 2'b11) begin
								bp_i_data_expected_valid 	<= 1;
								bp_i_data_expected_addr 	<= mem_o_data_addr;
								if (mem_o_data_addr == train_action) begin
									bp_i_data_expected 		<= loss_value;
								end
								else bp_i_data_expected 	<= mem_o_data;
								if (mem_o_data_addr == NUMBER_OF_OUTPUT_NODE-1) begin
									active_mode <= 3'b100;
									load_data_bp <= 1;
									train_action_active <= 0;
									loss_value_active <= 0;
								end
							end
							else bp_i_data_expected_valid 	<= 0;
						end
						else bp_i_data_expected_valid 	<= 0;
					end
				
				3'b100: // load data node for back propagation
					begin			
						valid_fw 			<= 0;
						valid_bp 			<= 0;
						valid_upd 			<= 0;
						bp_i_data_valid 	<= 1;
						bp_i_data_expected_valid <= 0;
						
						if (load_data_bp) begin
							mem_i_data_valid 		<= 1;
							mem_i_rw_data_select 	<= 1'b1; // read data
							mem_i_data_layer 		<= data_layer;
							mem_i_data_addr 		<= node_counter;
							
							case(data_layer)
								2'b00:
									begin
										if (node_counter < NUMBER_OF_INPUT_NODE-1) begin
											node_counter <= node_counter + 1;
										end
										else begin
											node_counter <= 'd0;
											data_layer <= 2'b01;
										end
									end
								2'b01:
									begin
										if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1-1) begin
											node_counter <= node_counter + 1;
										end
										else begin
											node_counter <= 'd0;
											data_layer <= 2'b10;
										end
									end
								2'b10:
									begin
										if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2-1) begin
											node_counter <= node_counter + 1;
										end
										else begin
											node_counter <= 'd0;
											data_layer <= 2'b11;
										end
									end
								2'b11:
									begin
										if (node_counter < NUMBER_OF_OUTPUT_NODE-1) begin
											node_counter <= node_counter + 1;
										end
										else begin
											node_counter <= 'd0;
											data_layer <= 2'b00;
											load_data_bp <= 0;
										end
									end
							endcase
						end 
						else mem_i_data_valid <= 0;
							
						if (mem_o_data_valid) begin
							if (mem_o_data_layer == 2'b11) begin
								if (mem_o_data_addr == NUMBER_OF_OUTPUT_NODE-1) begin
									active_mode <= 3'b101;
									bp_i_data_valid <= 0;
								end
							end
						end
					end
				
				3'b101: // back propagation mode
					begin
						valid_fw 			<= 0;
						valid_bp 			<= 1;
						valid_upd 			<= 0;
						arg_max_valid_in 	<= 0;
						bp_i_data_valid 	<= 0;
						bp_i_data_expected_valid <= 0;
						
						mem_i_weight_valid 		<= bp_o_weight_valid_request;
						mem_i_rw_weight_select 	<= 1'b1; // read weight
						mem_i_weight_layer 		<= bp_o_weight_layer_request;
						mem_i_weight_addr		<= bp_o_weight_addr_request;
						
						if (mem_o_weight_valid) begin
							if (mem_o_weight_layer == 2'b10) begin
								if (mem_o_weight_addr == NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin
									active_mode <= 3'b110;
								end
							end
						end
					end
				
				3'b110: // update weight mode 
					begin
						valid_fw 			<= 0;
						valid_bp 			<= 0;
						valid_upd			<= 1;
						arg_max_valid_in 	<= 0;
						bp_i_data_valid 	<= 0;
						bp_i_data_expected_valid <= 0;
						
						mem_i_weight_valid 		<= upd_o_weight_valid_request;
						mem_i_rw_weight_select 	<= 1'b1; // read
						mem_i_weight_layer 		<= upd_o_weight_layer_request;
						mem_i_weight_addr		<= upd_o_weight_addr_request;
						
						if (mem_o_weight_valid) begin
							if (mem_o_weight_layer == 2'b01) begin
								if (mem_o_weight_addr == NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin
									active_mode <= 3'b111;
								end
							end
						end
					end
				3'b111: // load new weight to memory_block	
					begin
						valid_fw 			<= 0;
						valid_bp 			<= 0;
						valid_upd			<= 0;
						arg_max_valid_in 	<= 0;
						bp_i_data_valid 	<= 0;
						bp_i_data_expected_valid <= 0;
						
						mem_i_weight_valid 		<= upd_o_new_weight_valid;
						mem_i_rw_weight_select 	<= 1'b0; // write
						mem_i_weight_layer 		<= upd_o_new_weight_layer;
						mem_i_weight_addr		<= upd_o_new_weight_addr;
						mem_i_weight			<= upd_o_new_weight;
						
						if (upd_o_new_weight_valid) begin
							if (upd_o_new_weight_layer == 2'b11) begin
								if (upd_o_new_weight_addr == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
									active_mode <= 3'b001;
									o_main_net_done <= 1;
								end
							end
						end
					end
			endcase	
		
		end
	end
			
		
endmodule
