`timescale 1ns/1ps
module back_propagation_node_from_hidden_2_layer
	#(	parameter DATA_WIDTH = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_delta,
		i_weight,
		o_data,
		o_valid
	);
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input 		[DATA_WIDTH-1:0]		i_delta;
	input 		[DATA_WIDTH-1:0]		i_weight;
	output 		[DATA_WIDTH-1:0] 		o_data;
	output 	 							o_valid;
	//---------------------------------------------------//

	//---------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0] 					data_out_mul;
	wire 										valid_out_mul; 
	//---------------------------------------------------------//

	multiplier_floating_point32 mul // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(i_valid),
			.inA		(i_delta), 
			.inB		(i_weight),
			.valid_out	(valid_out_mul),
			.out_data	(data_out_mul)
		);
	
	adder_3_input_pipeline_floating_point32 adder_3_node
		(	.clk		(clk),
			.rst_n		(rst_n), 
			.i_valid	(valid_out_mul),
			.i_data		(data_out_mul), 
			.o_data		(o_data),
			.o_valid	(o_valid)
		);

endmodule
