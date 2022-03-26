//module feed_forward
//	#(	parameter DATA_WIDTH = 32,
//		parameter NUMBER_OF_INPUT_NODE = 2,
//		parameter NUMBER_OF_NODE_MAX =32,
//		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
//		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
//		parameter NUMBER_OF_OUTPUT_NODE = 3)
//	(	clk,
//		rst_n,
//		i_data,
//		i_weight,
//		i_valid,
//		i_bias,
//		o_data_addr,
//		o_data, 
//		o_valid
//	);
////-----------------input and output port--------------------------------------------//
//input 																						clk;
//input 																						rst_n;
//input 																						i_valid;
//input 		[DATA_WIDTH*NUMBER_OF_NODE_MAX-1:0] 								i_data;
//input 		[DATA_WIDTH*NUMBER_OF_NODE_MAX*NUMBER_OF_NODE_MAX-1:0] 		i_weight;
//input 		[DATA_WIDTH-1:0] 															i_bias;
//output 		[DATA_WIDTH*NUMBER_OF_NODE_MAX-1:0] 								o_data;
//output reg	[NUMBER_OF_HIDDEN_LAYER:0] 											o_data_addr;
//output reg 																					o_valid;
////----------------------------------------------------------------------------------//
//
//
////---------------------------------------------------------//
//wire valid_in_hidden_layer_1, valid_in_hidden_layer_2, valid_in_output_layer;
//wire valid_out_hidden_layer_1, valid_out_hidden_layer_2, valid_out_output_layer;
////---------------------------------------------------------//
//
//feed_forward_hidden_layer
//	#(	.DATA_WIDTH(DATA_WIDTH),
//		.NUMBER_OF_INPUT_NODE(NUMBER_OF_INPUT_NODE),
//		.NUMBER_OF_HIDDEN_NODE(NUMBER_OF_HIDDEN_NODE_LAYER_1))
//	feed_forward_hidden_layer_1
//	(	.clk		(clk),
//		.rst_n	(rst_n),
//		.i_data	(i_data[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0]),
//		.i_weight(i_weight[DATA_WIDTH*NUMBER_OF_INPUT_NODE*NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]),
//		.i_valid	(valid_in_hidden_layer_1),
//		.i_bias	(i_bias),
//		.o_data	(o_data[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]), 
//		.o_valid	(valid_out_hidden_layer_1)
//	);
//	
//feed_forward_hidden_layer
//	#(	.DATA_WIDTH(DATA_WIDTH),
//		.NUMBER_OF_INPUT_NODE(NUMBER_OF_HIDDEN_NODE_LAYER_1),
//		.NUMBER_OF_HIDDEN_NODE(NUMBER_OF_HIDDEN_NODE_LAYER_2))
//	feed_forward_hidden_layer_2
//	(	.clk		(clk),
//		.rst_n	(rst_n),
//		.i_data	(i_data[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]),
//		.i_weight(i_weight[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_1*NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0]),
//		.i_valid	(valid_in_hidden_layer_2),
//		.i_bias	(i_bias),
//		.o_data	(o_data[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0]), 
//		.o_valid	(valid_out_hidden_layer_2)
//	);
//
//feed_forward_hidden_layer
//	#(	.DATA_WIDTH(DATA_WIDTH),
//		.NUMBER_OF_INPUT_NODE(NUMBER_OF_HIDDEN_NODE_LAYER_2),
//		.NUMBER_OF_HIDDEN_NODE(NUMBER_OF_OUTPUT_NODE))
//	feed_forward_output_layer
//	(	.clk		(clk),
//		.rst_n	(rst_n),
//		.i_data	(i_data[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0]),
//		.i_weight(i_weight[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE_LAYER_2*NUMBER_OF_OUTPUT_NODE-1:0]),
//		.i_valid	(valid_in_output_layer),
//		.i_bias	(i_bias),
//		.o_data	(o_data[DATA_WIDTH*NUMBER_OF_OUTPUT_NODE-1:0]), 
//		.o_valid	(valid_out_output_layer)
//	);
//
//always @(posedge clk) begin	
//	if (i_valid) begin
//		o_data_addr <= 3'b100;
//		valid_in <= 1;
//	end
//	else valid_in <= 0;
//	if (valid_out_temp) begin
//		o_data <= data_out_temp;
//		o_valid <= 1;
//	end 
//	else begin
//		o_data <= 'dz;
//		o_valid <= 0;
//	end
//end
//
//endmodule
