`timescale 1ns/1ps
module update_weight
	#(	parameter DATA_WIDTH 						= 32,
		parameter ADDRESS_WIDTH 					= 11,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter DATA_HIDDEN_2_FILE 				= "main_ram_hidden_2_data.txt",
		parameter DATA_HIDDEN_1_FILE 				= "main_ram_hidden_1_data.txt",
		parameter DATA_INPUT_FILE 					= "main_ram_input_data.txt",
		parameter OLD_WEIGHT_OUTPUT_FILE 			= "main_ram_output_weight.txt",
		parameter OLD_WEIGHT_HIDDEN_2_FILE 			= "main_ram_hidden_2_weight.txt",
		parameter OLD_WEIGHT_HIDDEN_1_FILE 			= "main_ram_hidden_1_weight.txt",
		parameter NEW_WEIGHT_OUTPUT_FILE 			= "main_ram_output_weight_new.txt",
		parameter NEW_WEIGHT_HIDDEN_2_FILE 			= "main_ram_hidden_2_weight_new.txt",
		parameter NEW_WEIGHT_HIDDEN_1_FILE 			= "main_ram_hidden_1_weight_new.txt",
		parameter DELTA_OUTPUT_FILE 				= "main_ram_output_delta.txt",
		parameter DELTA_HIDDEN_2_FILE 				= "main_ram_hidden_2_delta.txt",
		parameter DELTA_HIDDEN_1_FILE 				= "main_ram_hidden_1_delta.txt",
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F	//0.002
	)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
output 	 							o_valid;
//---------------------------------------------------//

//--------------------------------------------------------------//
wire 								valid_out_output_layer;
wire 								valid_out_hidden_2_layer;
//--------------------------------------------------------------//

update_weight_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH			(ADDRESS_WIDTH),
		.WEIGHT_FILE 			(OLD_WEIGHT_OUTPUT_FILE),
		.DATA_POINT_FILE 		(DATA_HIDDEN_2_FILE),
		.DELTA_FILE 			(DELTA_OUTPUT_FILE),
		.NEW_WEIGHT_FILE		(NEW_WEIGHT_OUTPUT_FILE),
		.NUMBER_OF_FORWARD_NODE (NUMBER_OF_OUTPUT_NODE),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.LEARNING_RATE			(LEARNING_RATE)	//0.002
	)
	update_output_layer
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(i_valid),
		.o_valid				(valid_out_output_layer)
	);
	
update_weight_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH			(ADDRESS_WIDTH),
		.WEIGHT_FILE 			(OLD_WEIGHT_HIDDEN_2_FILE),
		.DATA_POINT_FILE 		(DATA_HIDDEN_1_FILE),
		.DELTA_FILE 			(DELTA_HIDDEN_2_FILE),
		.NEW_WEIGHT_FILE		(NEW_WEIGHT_HIDDEN_2_FILE),
		.NUMBER_OF_FORWARD_NODE (NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.LEARNING_RATE			(LEARNING_RATE)	//0.002
	)
	update_hidden_2_layer
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_out_output_layer),
		.o_valid				(valid_out_hidden_2_layer)
	);

update_weight_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH			(ADDRESS_WIDTH),
		.WEIGHT_FILE 			(OLD_WEIGHT_HIDDEN_1_FILE),
		.DATA_POINT_FILE 		(DATA_INPUT_FILE),
		.DELTA_FILE 			(DELTA_HIDDEN_1_FILE),
		.NEW_WEIGHT_FILE		(NEW_WEIGHT_HIDDEN_1_FILE),
		.NUMBER_OF_FORWARD_NODE (NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_INPUT_NODE),
		.LEARNING_RATE			(LEARNING_RATE)	//0.002
	)
	update_hidden_1_layer
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_out_hidden_2_layer),
		.o_valid				(o_valid)
	);

endmodule
