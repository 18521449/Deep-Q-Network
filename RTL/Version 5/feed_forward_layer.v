`timescale 1ns/1ps
module feed_forward_layer
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_INPUT_NODE = 3,
		parameter NUMBER_OF_OUTPUT_NODE = 32,
		parameter LEAKYRELU_ENABLE = 1'b1,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD
	)
	(	clk,
		rst_n,
		i_valid,
		i_weight,
		i_data,
		o_data,
		o_valid
	);
	
	//-----------------input and output port-----------------//
	input 									clk;
	input 									rst_n;
	input 									i_valid;
	input 		[DATA_WIDTH-1:0] 			i_weight;
	input		[DATA_WIDTH-1:0] 			i_data;
	output reg	[DATA_WIDTH-1:0] 			o_data;
	output reg 								o_valid;
	//-------------------------------------------------------//

	feed_forward_node 
		#( 	.DATA_WIDTH				(DATA_WIDTH),
			.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
			.LEAKYRELU_ENABLE		(LEAKYRELU_ENABLE),
			.ALPHA					(ALPHA)
		)
		node
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_valid				(i_valid),
			.i_weight				(i_weight),
			.i_data					(i_data),
			.o_data 				(o_data),
			.o_valid				(o_valid)
		);

endmodule
