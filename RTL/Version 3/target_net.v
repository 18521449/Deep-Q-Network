`timescale 1ns/1ps
module target_net
#(	parameter DATA_WIDTH = 32,
	parameter ADDRESS_WIDTH = 5,
	parameter NUMBER_OF_INPUT_NODE = 2,
	parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 5,
	parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 5,
	parameter NUMBER_OF_OUTPUT_NODE = 3,
	parameter DATA_INPUT_FILE = "target_ram_input_data.txt",
	parameter DATA_HIDDEN_1_FILE = "target_ram_hidden_1_data.txt",
	parameter DATA_HIDDEN_2_FILE = "target_ram_hidden_1_data.txt",
	parameter DATA_OUTPUT_FILE = "target_ram_output_data.txt",
	parameter WEIGHT_HIDDEN_1_FILE = "target_ram_hidden_1_weight.txt",
	parameter WEIGHT_HIDDEN_2_FILE = "target_ram_hidden_2_weight.txt",
	parameter WEIGHT_OUTPUT_FILE = "target_ram_output_weight.txt",
	parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD)
(	clk,
	rst_n,
	i_valid,
	o_data,
	o_valid
);
//-----------------input and output port-------------//
input 											clk;
input 											rst_n;
input 											i_valid;
output	[DATA_WIDTH-1:0]						o_data;
output	 										o_valid;
//----------------------------------------------------//

//---------------------------------------------------------//
wire valid_out;
//---------------------------------------------------------//

feed_forward
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ADDRESS_WIDTH					(ADDRESS_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.DATA_INPUT_FILE 				(DATA_INPUT_FILE),
		.DATA_HIDDEN_1_FILE 			(DATA_HIDDEN_1_FILE),
		.DATA_HIDDEN_2_FILE				(DATA_HIDDEN_2_FILE),
		.DATA_OUTPUT_FILE 				(DATA_OUTPUT_FILE),
		.WEIGHT_HIDDEN_1_FILE 			(WEIGHT_HIDDEN_1_FILE),
		.WEIGHT_HIDDEN_2_FILE 			(WEIGHT_HIDDEN_2_FILE),
		.WEIGHT_OUTPUT_FILE 			(WEIGHT_OUTPUT_FILE),
		.ALPHA							(ALPHA)
		)
	feed_forward
	(	.clk		(clk),
		.rst_n		(rst_n),
		.i_valid	(i_valid),
		.o_valid	(valid_out)
	);
	
target_net_max 
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.DATA_OUTPUT_FILE		(DATA_OUTPUT_FILE),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
	)
	max
	(	.clk		(clk),
		.rst_n		(rst_n),
		.i_valid	(valid_out),
		.o_data		(o_data),
		.o_valid	(o_valid)
	);

endmodule
