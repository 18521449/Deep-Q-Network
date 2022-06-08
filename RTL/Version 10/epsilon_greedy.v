module epsilon_greedy 
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter [DATA_WIDTH-1:0]	EPSILON_DECAY	= 'h3F7F3B64 //0.997
	)
	(	clk,
		rst_n,
		i_valid,
		o_action_random,
		o_action_select,
		o_valid
   );
    
   //-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	output reg	[ACTION_WIDTH-1:0] 		o_action_random;
	output reg							o_action_select;
	output reg 							o_valid;
	//---------------------------------------------------//
   
	//---------------------------------------------------//
	wire 								valid_out_mul;
	wire		[DATA_WIDTH-1:0]		data_out_mul;
	wire 								valid_out_compare;
	wire 		[DATA_WIDTH-1:0]		data_out_compare;
	wire 		[DATA_WIDTH-1:0]		random_data;
	reg 		[DATA_WIDTH-1:0]		random_reg;
	reg 		[ACTION_WIDTH-1:0]		action_reg;
	reg 		[DATA_WIDTH-1:0]		epsilon_reg;
	//---------------------------------------------------//
    
	
	random_floating_point_32bit random_block
		(	.clk			(clk),
			.rst_n			(rst_n),
			.i_enable		(i_valid),
			.o_random_data	(random_data)
		);
	
	multiplier_floating_point32 mul_epsilon // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(i_valid),
			.inA			(epsilon_reg), 
			.inB			(EPSILON_DECAY),
			.valid_out		(valid_out_mul),
			.out_data		(data_out_mul));
	
   adder_floating_point32 compare // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(valid_out_mul),
			.inA			(data_out_mul), 
			.inB			(random_reg),
			.valid_out		(valid_out_compare),
			.out_data		(data_out_compare));

	initial begin
		epsilon_reg <= 'h3F800000;
	end


	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin 
			epsilon_reg <= 'h3F800000;
		end 
		else begin 
			if (i_valid) begin
				random_reg <= random_data;
				if (random_data[1:0] == 'b11) begin
					action_reg <= 'b00;
				end
				else action_reg <= random_data[1:0];
			end
			
			if (valid_out_mul) begin
				epsilon_reg <= data_out_mul;
			end	
			
			if (valid_out_compare) begin
				o_valid <= 1;
				o_action_random <= action_reg;
				o_action_select <= data_out_compare[DATA_WIDTH-1];
			end
			else o_valid <= 0;
			
		end 
	end 

endmodule