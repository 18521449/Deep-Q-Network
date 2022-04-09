`timescale 1ns/1ps
module main_net
	#(	parameter DATA_WIDTH 						= 32,
		parameter ADDRESS_WIDTH 					= 11,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter DATA_EXPECTED_FILE				= "main_ram_expected.txt",
		parameter DATA_OUTPUT_FILE 					= "main_ram_output_data.txt",
		parameter DATA_HIDDEN_2_FILE 				= "main_ram_hidden_2_data.txt",
		parameter DATA_HIDDEN_1_FILE 				= "main_ram_hidden_1_data.txt",
		parameter DATA_INPUT_FILE 					= "main_ram_input_data.txt",
		parameter WEIGHT_OUTPUT_FILE 				= "main_ram_output_weight.txt",
		parameter WEIGHT_HIDDEN_2_FILE 				= "main_ram_hidden_2_weight.txt",
		parameter WEIGHT_HIDDEN_1_FILE 				= "main_ram_hidden_1_weight.txt",
		parameter DELTA_OUTPUT_FILE 				= "main_ram_output_delta.txt",
		parameter NEW_WEIGHT_OUTPUT_FILE 			= "main_ram_output_weight_new.txt",
		parameter NEW_WEIGHT_HIDDEN_2_FILE 			= "main_ram_hidden_2_weight_new.txt",
		parameter NEW_WEIGHT_HIDDEN_1_FILE 			= "main_ram_hidden_1_weight_new.txt",
		parameter DELTA_HIDDEN_2_FILE 				= "main_ram_hidden_2_delta.txt",
		parameter DELTA_HIDDEN_1_FILE 				= "main_ram_hidden_1_delta.txt",
		parameter [DATA_WIDTH-1:0]  ALPHA 			= 32'h3DCCCCCD,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F //0.002
	)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
//-----------------input and output port-------------//
input 											clk;
input 											rst_n;
input 											i_valid;
output	 										o_valid;
//----------------------------------------------------//


//---------------------------------------------------------//
wire valid_out_fw;
wire valid_out_bp;
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
	feed_forward_step
	(	.clk							(clk),
		.rst_n							(rst_n),
		.i_valid						(i_valid),
		.o_valid						(valid_out_fw)
	);

back_propagation
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ADDRESS_WIDTH 					(ADDRESS_WIDTH),
		.NUMBER_OF_INPUT_NODE 			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1 	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.DATA_EXPECTED_FILE				(DATA_EXPECTED_FILE),
		.DATA_OUTPUT_FILE 				(DATA_OUTPUT_FILE),
		.DATA_HIDDEN_2_FILE 			(DATA_HIDDEN_2_FILE),
		.DATA_HIDDEN_1_FILE 			(DATA_HIDDEN_1_FILE),
		.DATA_INPUT_FILE 				(DATA_INPUT_FILE),
		.WEIGHT_OUTPUT_FILE 			(WEIGHT_OUTPUT_FILE),
		.WEIGHT_HIDDEN_2_FILE 			(WEIGHT_HIDDEN_2_FILE),
		.WEIGHT_HIDDEN_1_FILE 			(WEIGHT_HIDDEN_1_FILE),
		.DELTA_OUTPUT_FILE 				(DELTA_OUTPUT_FILE),
		.DELTA_HIDDEN_2_FILE 			(DELTA_HIDDEN_2_FILE),
		.DELTA_HIDDEN_1_FILE 			(DELTA_HIDDEN_1_FILE),
		.ALPHA							(ALPHA)
	)
	back_propagation_step
	(	.clk							(clk),
		.rst_n							(rst_n),
		.i_valid						(valid_out_fw),
		.o_valid						(valid_out_bp)
	);

update_weight
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ADDRESS_WIDTH					(ADDRESS_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1 	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.DATA_HIDDEN_2_FILE 			(DATA_HIDDEN_2_FILE),
		.DATA_HIDDEN_1_FILE 			(DATA_HIDDEN_1_FILE),
		.DATA_INPUT_FILE 				(DATA_INPUT_FILE),
		.OLD_WEIGHT_OUTPUT_FILE 		(WEIGHT_OUTPUT_FILE),
		.OLD_WEIGHT_HIDDEN_2_FILE 		(WEIGHT_HIDDEN_2_FILE),
		.OLD_WEIGHT_HIDDEN_1_FILE 		(WEIGHT_HIDDEN_1_FILE),
		.NEW_WEIGHT_OUTPUT_FILE 		(NEW_WEIGHT_OUTPUT_FILE),
		.NEW_WEIGHT_HIDDEN_2_FILE 		(NEW_WEIGHT_HIDDEN_2_FILE),
		.NEW_WEIGHT_HIDDEN_1_FILE 		(NEW_WEIGHT_HIDDEN_1_FILE),
		.DELTA_OUTPUT_FILE 				(DELTA_OUTPUT_FILE),
		.DELTA_HIDDEN_2_FILE 			(DELTA_HIDDEN_2_FILE),
		.DELTA_HIDDEN_1_FILE			(DELTA_HIDDEN_1_FILE),
		.LEARNING_RATE					(LEARNING_RATE)	//0.002
	)
	update_weight_step
	(	.clk							(clk),
		.rst_n							(rst_n),
		.i_valid						(valid_out_bp),
		.o_valid						(o_valid)
	);
endmodule
