`timescale 1ns/1ps
module target_net_memory
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(
	clk,
	i_ram_data_enable,
	i_rw_data_select,
	i_data_addr,
	i_data_layer,
	i_data,
	i_ram_weight_enable,
	i_rw_weight_select,
	i_weight_layer,
	i_weight,
	o_data,
	o_data_valid,
	o_weight,
	o_weight_valid
	);

	localparam BIGEST_WEIGHT_WIDTH = $clog2((NUMBER_OF_HIDDEN_NODE_LAYER_1+1)*NUMBER_OF_HIDDEN_NODE_LAYER_2);
	localparam BIGEST_DATA_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	
	input									clk;
	
	input									i_ram_data_enable;
	input									i_rw_data_select; // 1 for read, 0 for write
	input 		[BIGEST_DATA_WIDTH-1:0]		i_data_addr;
	input		[LAYER_WIDTH-1:0]			i_data_layer;
	input 		[DATA_WIDTH-1:0] 			i_data;
	
	input									i_ram_weight_enable;
	input									i_rw_weight_select; // 1 for read, 0 for write
	input		[LAYER_WIDTH-1:0]			i_weight_layer;
	input 		[DATA_WIDTH-1:0] 			i_weight;
	
	output  	[DATA_WIDTH-1:0] 			o_data;
	output  								o_data_valid;
	
	output  	[DATA_WIDTH-1:0] 			o_weight;
	output  								o_weight_valid;
	
	ram_data	
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
	)
	data_ram
	(	.clk			(clk),
		.i_ram_enable	(i_ram_data_enable),
		.i_rw_select	(i_rw_data_select), // 1 for read, 0 for write
		.i_data_addr	(i_data_addr),
		.i_layer		(i_data_layer),
		.i_data			(i_data),
		.o_data			(o_data),
		.o_valid		(o_data_valid)
	);
	
	ram_weight	
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
	)
	weight_ram
	(	.clk			(clk),
		.i_ram_enable	(i_ram_weight_enable),
		.i_rw_select	(i_rw_weight_select), // 1 for read, 0 for write
		.i_layer		(i_weight_layer),
		.i_weight		(i_weight),
		.o_weight		(o_weight),
		.o_valid		(o_weight_valid)
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