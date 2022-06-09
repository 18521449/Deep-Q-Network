`timescale 1ns/1ps
module back_error_calculation
	#(	parameter DATA_WIDTH 						= 32,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F	//0.002
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_point,
		i_delta,
		o_error,
		o_valid
	);
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input 		[DATA_WIDTH-1:0]		i_data_point;
	input 		[DATA_WIDTH-1:0]		i_delta;
	output 		[DATA_WIDTH-1:0] 		o_error;
	output 	 							o_valid;
	//---------------------------------------------------//


	//---------------------------------------------------//
	wire 		[DATA_WIDTH-1:0]		error;
	wire 								valid_out_error;
	//---------------------------------------------------//

	multiplier_floating_point32 mul_node // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(i_valid),
			.inA		(i_delta), 
			.inB		(i_data_point),
			.valid_out	(valid_out_error),
			.out_data	(error));

	multiplier_floating_point32 mul_lr // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(valid_out_error),
			.inA		(error), 
			.inB		(LEARNING_RATE),
			.valid_out	(o_valid),
			.out_data	(o_error));

endmodule
