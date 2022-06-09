module feed_leakyrelu_function
	#(	parameter DATA_WIDTH = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);
	//-----------------input and output port-----------------//
	input 									clk;
	input 									rst_n;
	input 									i_valid;
	input 		[DATA_WIDTH-1:0] 			i_data;
	output		[DATA_WIDTH-1:0] 			o_data;
	output 									o_valid;
	//-------------------------------------------------------//	

	//------- Leaky relu -------//
	// if value < 0
		// return 0.25 (3E800000)
	// else 
		// return 0.5 (3F000000)

	multiplier_floating_point32 mul // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(i_valid),
				.inA		(i_data), 
				.inB		((i_data[DATA_WIDTH-1]) ? ('h3E800000) : ('h3F000000)),
				.valid_out	(o_valid),
				.out_data	(o_data)
			);

endmodule
	