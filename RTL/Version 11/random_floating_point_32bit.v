`timescale 1ns/1ps
module random_floating_point_32bit
	(	clk,
		rst_n,
		i_enable,
		o_random_data
	);

	//-------------input and output port--------//
	input 						clk;
	input 						rst_n;
	input						i_enable;			
	output		[32-1:0] 		o_random_data;
	//----------------------------------------//
	
	wire [7:0]	D;
	wire [22:0]	random_mantise;
	wire configE6, configE7, configE8;
	
	random_galois_8bit random_8bit_block
	(	.clk			(clk),
		.rst_n			(rst_n),
		.i_enable		(i_enable),
		.o_random_data	(D)
	);
	
	// initial begin
		// random_exponent <= 'b000;
	// end
	
	random_galois_23bit random_23bit_block
	(	.clk			(clk),
		.rst_n			(rst_n),
		.i_enable		(i_enable),
		.o_random_data	(random_mantise)
	);
	
	// assign configE6 = (~D[7]) & ((~D[6]) & ((~D[5]) & (~D[4]) & D[3] | D[5]) | D[6]) | D[7];
	// assign configE7 = (~D[7]) & (~D[6]) & (~D[5]) & ((~D[4]) & (~D[3]) & D[2] | D[4]) | D[7];
	// assign configE8 = (~D[7]) & ((~D[6]) & (~D[5]) & ((~D[4]) & ((~D[3]) & (~D[2]) & D[1] | D[3]) | D[4]) | D[6]);
	
	assign configE6 = (~D[7]) & ((~D[6]) & (~D[5]) & D[4] | D[6]) | D[7];
	assign configE7 = (~D[7]) & (~D[6]) & ((~D[5]) & ((~D[4]) & D[3] | D[4]) | D[5]) | (D[7]);
	assign configE8 = (~D[7]) & ((~D[6]) & ((~D[5]) & (~D[4]) & (~D[3]) & D[2] | D[5]) | D[6]);
	
	assign o_random_data = (i_enable)	? {6'b001111, configE6, configE7, configE8, random_mantise} : 'dz;
	
	// always @(posedge clk) begin
		// if (i_enable) begin
			// if (random_exponent < 'b110) begin
				// random_exponent <= random_exponent + 1;
			// end
			// else random_exponent <= 'b000;
		// end
	// end
		
	
endmodule