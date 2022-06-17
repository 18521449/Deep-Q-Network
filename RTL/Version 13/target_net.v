`timescale 1ns/1ps
module target_net
	#(	parameter DATA_WIDTH 						= 32,
		parameter LAYER_WIDTH 						= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3
	)
	(	clk,
		rst_n,
		i_data_valid,
		i_data_addr,
		i_data,
		
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		i_load_weight_done,
		
		i_update_request,
		o_weight_valid,
		o_weight_layer,
		o_weight_addr,
		o_weight,
		
		o_q_max,
		o_q_max_valid
	);
	
	
	localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_data_valid;
	input		[DATA_COUNTER_WIDTH-1:0]	i_data_addr;
	input 		[DATA_WIDTH-1:0]			i_data;
	input 									i_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_weight;
	input 									i_load_weight_done;
	input									i_update_request;
	output reg								o_weight_valid;
	output reg	[LAYER_WIDTH-1:0]			o_weight_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr;
	output reg 	[DATA_WIDTH-1:0]			o_weight;
	output	 								o_q_max_valid;
	output		[DATA_WIDTH-1:0]			o_q_max;
	//----------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[1:0]						finite_state_machine;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//	
	wire 								mem_o_weight_valid;
	wire	[LAYER_WIDTH-1:0]			mem_o_weight_layer; 
	wire 	[WEIGHT_COUNTER_WIDTH-1:0]	mem_o_weight_addr; 
	wire 	[DATA_WIDTH-1:0]			mem_o_weight;
	
	wire								fw_weight_valid_request;
	wire	[LAYER_WIDTH-1:0]			fw_weight_layer_request;
	wire 	[WEIGHT_COUNTER_WIDTH-1:0]	fw_weight_addr_request;
	
	wire								fw_data_valid;
	wire	[LAYER_WIDTH-1:0]			fw_data_layer;
	wire 	[DATA_COUNTER_WIDTH-1:0]	fw_data_addr;
	wire	[DATA_WIDTH-1:0]			fw_data;
	reg 								fw_valid;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 								mem_i_weight_valid;
	reg									mem_i_rw_weight_select;
	reg		[LAYER_WIDTH-1:0]			mem_i_weight_layer; 
	reg 	[WEIGHT_COUNTER_WIDTH-1:0]	mem_i_weight_addr; 
	reg 	[DATA_WIDTH-1:0]			mem_i_weight;
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
			.i_weight_valid			(fw_valid & mem_o_weight_valid),
			.i_weight_layer			(mem_o_weight_layer),
			.i_weight_addr			(mem_o_weight_addr),
			.i_weight				(mem_o_weight),
			.o_weight_valid_request	(fw_weight_valid_request),
			.o_weight_layer_request	(fw_weight_layer_request), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
			.o_weight_addr_request	(fw_weight_addr_request),
			.o_data_valid			(fw_data_valid),
			.o_data_layer			(fw_data_layer),
			.o_data_addr			(fw_data_addr),
			.o_data					(fw_data)
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
			.i_ram_data_enable		(1'b0),
			.i_rw_data_select		(), // 1 for read, 0 for write
			.i_data_layer			(),
			.i_data_addr			(),
			.i_data					(),
			.i_ram_weight_enable	(mem_i_weight_valid),
			.i_rw_weight_select		(mem_i_rw_weight_select), // 1 for read, 0 for write
			.i_weight_layer			(mem_i_weight_layer),
			.i_weight_addr			(mem_i_weight_addr),
			.i_weight				(mem_i_weight),
			.o_data_valid			(),
			.o_data_layer			(),
			.o_data_addr			(),
			.o_data					(),	
			.o_weight_valid			(mem_o_weight_valid),
			.o_weight_layer			(mem_o_weight_layer),
			.o_weight_addr			(mem_o_weight_addr),
			.o_weight				(mem_o_weight)
		);

	target_net_max 
		#(	.DATA_WIDTH				(DATA_WIDTH),
			.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
		)
		target_net_max_block
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(fw_data_valid & (fw_data_layer == 2'b11)),
			.i_data		(fw_data),
			.o_data		(o_q_max),
			.o_valid	(o_q_max_valid)
		);
		
	initial begin
		finite_state_machine <= 2'b00;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			finite_state_machine 	<= 2'b00;
		end
		else begin
			
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
				2'b01: // training mode
					begin
						fw_valid <= 1;
						
						mem_i_weight_valid 		<= fw_weight_valid_request;
						mem_i_rw_weight_select 	<= 1'b1; // read weight
						mem_i_weight_layer 		<= fw_weight_layer_request;
						mem_i_weight_addr		<= fw_weight_addr_request;
						
						if (i_update_request) begin
							finite_state_machine <= 2'b10;
						end
					end
				2'b10: // soft update request
					begin
						fw_valid <= 0;
						
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
								finite_state_machine <= 2'b00;
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