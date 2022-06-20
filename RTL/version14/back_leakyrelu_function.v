module back_leakyrelu_function
	#(	parameter DATA_WIDTH = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_first_bit_select,
		i_data,
		o_data,
		o_valid
	);
	//-----------------input and output port-----------------//
	input 										clk;
	input 										rst_n;
	input 										i_valid;
	input 										i_first_bit_select;
	input 		[DATA_WIDTH-1:0] 				i_data;
	output 		[DATA_WIDTH-1:0] 				o_data;
	output 										o_valid;
	//-------------------------------------------------------//

	//---- Back leaky relu ----//
	// if value < 0
		// return 0.1 (3DCCCCCD)
	// else 
		// return 0.2 (3E4CCCCD)
	
	multiplier_floating_point32 mul // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(i_valid),
				.inA		(i_data), 
				.inB		((i_first_bit_select) ? ('h3DCCCCCD) : ('h3E4CCCCD)),
				.valid_out	(o_valid),
				.out_data	(o_data));
		
endmodule
	