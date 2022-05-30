`timescale 1ns/1ps
module back_propagation_node_from_output_layer
	#(	parameter DATA_WIDTH = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		o_data,
		o_valid
	);
	
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input		[DATA_WIDTH-1:0] 		i_data_expected;
	input		[DATA_WIDTH-1:0] 		i_data_node;
	output 		[DATA_WIDTH-1:0] 		o_data;
	output 	 							o_valid;
	//---------------------------------------------------//

	adder_floating_point32 sub_expected // 7 CLOCK
				(	.clk(clk),
					.rstn(rst_n), 
					.valid_in(i_valid),
					.inA(i_data_node), 
					.inB({(~i_data_expected[DATA_WIDTH-1]), i_data_expected[DATA_WIDTH-2:0]}),
					.valid_out(o_valid),
					.out_data(o_data));

endmodule
