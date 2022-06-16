module feed_forward_node_from_input_layer
	#(	parameter DATA_WIDTH = 32
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
	input 										clk;
	input 										rst_n;
	input 										i_valid;
	input 		[DATA_WIDTH-1:0] 				i_weight;
	input		[DATA_WIDTH-1:0] 				i_data;
	output 		[DATA_WIDTH-1:0] 				o_data;
	output  									o_valid;
	//-------------------------------------------------------//

	//---------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0] 					data_out_mul;
	reg 	[DATA_WIDTH-1:0] 					data_out_mul_reg;
	wire 	[DATA_WIDTH-1:0] 					data_out_add;
	//---------------------------------------------------------//
	//---------------------------------------------------------//
	wire 										valid_out_mul; 
	wire 										valid_out_add;
	//---------------------------------------------------------//
	
	multiplier_floating_point32 mul // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(i_valid),
			.inA		(i_data), 
			.inB		(i_weight),
			.valid_out	(valid_out_mul),
			.out_data	(data_out_mul)
		);
	
	adder_3_input_pipeline_floating_point32 adder_3_node
		(	.clk		(clk),
			.rst_n		(rst_n), 
			.i_valid	(valid_out_mul),
			.i_data		(data_out_mul), 
			.o_data		(data_out_add),
			.o_valid	(valid_out_add)
		);

	feed_leakyrelu_function
		#(	.DATA_WIDTH			(DATA_WIDTH)
		)
		leakyrelu_funct
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(valid_out_add),
			.i_data		(data_out_add),
			.o_data		(o_data),
			.o_valid	(o_valid)
		);
	
endmodule



