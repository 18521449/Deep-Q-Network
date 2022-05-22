`timescale 1ns/1ps
module target_net
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD)
	(	clk,
		rst_n,
		i_data_valid,
		i_data,
		i_weight_valid,
		i_weight_layer,
		i_weight,
		o_data,
		o_valid
	);
	
	localparam BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	
	//-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_data_valid;
	input 		[DATA_WIDTH-1:0]			i_data;
	input 									i_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[DATA_WIDTH-1:0]			i_weight;
	output		[DATA_WIDTH-1:0]			o_data;
	output	 								o_valid;
	//----------------------------------------------------//
	
	//----------------------------------------//
	wire  	[LAYER_WIDTH-1:0]	out_current_layer;
	wire  	[LAYER_WIDTH-1:0]	weight_layer;
	//----------------------------------------//
	
	//-----------------------------------------//
	wire  	[BIGEST_WIDTH-1:0]	out_data_addr;
	//-----------------------------------------//
	
	//----------------------------------------//
	wire  	[DATA_WIDTH-1:0]	ram_weight;
	wire 	[DATA_WIDTH-1:0]	out_data;
	wire 	[DATA_WIDTH-1:0]	data_out;
	//----------------------------------------//
	
	//---------------------------------------------------------//
	wire 						out_data_valid;
	wire 						out_weight_valid;
	wire 						ram_weight_valid;
	wire 						rw_weight_select;
	wire 						weight_valid;
	wire 						valid_out;
	//---------------------------------------------------------//

	feed_forward	
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE),
			.ALPHA							(ALPHA)
		)
		feed_forward_block
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_data_valid		(i_data_valid),
			.i_data				(i_data),
			.i_weight_valid		(ram_weight_valid),
			.i_weight			(ram_weight),
			.o_current_layer	(out_current_layer), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
			.o_weight_valid		(out_weight_valid),
			.o_data_addr		(out_data_addr),
			.o_data				(out_data),
			.o_data_valid		(out_data_valid)
		);

	target_net_memory
		#(	.DATA_WIDTH						(DATA_WIDTH),
			.LAYER_WIDTH					(LAYER_WIDTH),
			.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
		)
		target_net_memory_block
		(	.clk				(clk),
			.i_ram_data_enable	(out_data_valid),
			.i_rw_data_select	(1'b0), // 1 for read, 0 for write
			.i_data_addr		(out_data_addr),
			.i_data_layer		(out_current_layer),
			.i_data				(out_data),
			.i_ram_weight_enable(weight_valid),
			.i_rw_weight_select	(rw_weight_select), // 1 for read, 0 for write
			.i_weight_layer		(weight_layer),
			.i_weight			(i_weight),
			.o_data				(data_out),	
			.o_data_valid		(valid_out),
			.o_weight			(ram_weight),
			.o_weight_valid		(ram_weight_valid)
		);
	assign weight_valid = (i_weight_valid) ? 1'b1 : out_weight_valid;
	assign weight_layer = (i_weight_valid) ? i_weight_layer : out_current_layer;
	assign rw_weight_select = (i_weight_valid) ? 1'b0 : 1'b1;

	target_net_max 
		#(	.DATA_WIDTH				(DATA_WIDTH),
			.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
		)
		target_net_max_block
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(valid_out),
			.i_data		(data_out),
			.o_data		(o_data),
			.o_valid	(o_valid)
		);

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
