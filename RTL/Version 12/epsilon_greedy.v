module epsilon_greedy 
	#(	parameter DATA_WIDTH 						= 32,
		parameter ACTION_WIDTH						= 2,
		parameter [DATA_WIDTH-1:0] EPSILON_DECAY	= 'h3F7F3B64, //0.997
		parameter [DATA_WIDTH-1:0] EPSILON_MIN		= 'h3C23D70A //0.01
		
	)
	(	clk,
		rst_n,
		i_valid,
		i_action_predict,
		i_train_mode,
		o_action,
		o_action_valid
   );
    
   //-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input 		[ACTION_WIDTH-1:0]		i_action_predict;
	input 								i_train_mode;
	output reg 	[ACTION_WIDTH-1:0]		o_action;
	output reg 							o_action_valid;
	//---------------------------------------------------//
   
	//---------------------------------------------------//
	wire 								valid_out_mul;
	wire		[DATA_WIDTH-1:0]		data_out_mul;
	wire 								valid_compare_1;
	wire 								valid_compare_2;
	wire 		[DATA_WIDTH-1:0]		data_compare_1;
	wire 		[DATA_WIDTH-1:0]		data_compare_2;
	wire 		[DATA_WIDTH-1:0]		random_data;
	reg 		[DATA_WIDTH-1:0]		random_reg;
	reg 		[ACTION_WIDTH-1:0]		action_predict;
	reg 		[ACTION_WIDTH-1:0]		action_random;
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
	
   adder_floating_point32 compare_random_data // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(valid_out_mul),
			.inA			(data_out_mul), 
			.inB			({~random_reg[DATA_WIDTH-1], random_reg[DATA_WIDTH-2:0]}),
			.valid_out		(valid_compare_1),
			.out_data		(data_compare_1));
	
	adder_floating_point32 compare_epsilon_min // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(valid_out_mul),
			.inA			(data_out_mul), 
			.inB			({~EPSILON_MIN[DATA_WIDTH-1], EPSILON_MIN[DATA_WIDTH-2:0]}),
			.valid_out		(valid_compare_2),
			.out_data		(data_compare_2));
	
	initial begin
		epsilon_reg <= 'h3F800000; // epsilon initialization = 1
	end


	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin 
			epsilon_reg <= 'h3F800000; // epsilon initialization = 1
		end 
		else begin 
			if (i_valid) begin
			
				action_predict 	<= i_action_predict;
				random_reg 		<= random_data;
				
				if (random_data[1:0] == 'b11) begin
					action_random <= 'b00;
				end
				else action_random <= random_data[1:0];
				
			end
			
			if (valid_compare_1 & valid_compare_2) begin
				if (!data_compare_2[DATA_WIDTH-1]) begin	// if (epsilon > EPSILON_MIN)
					epsilon_reg <= data_out_mul;
				end
			end
			
			if (!i_train_mode) begin  // if (without Train mode) or if (in interactive mode)
				if (valid_compare_1) begin
					o_action_valid 	<= 1;
					
					if (data_compare_1[DATA_WIDTH-1]) // if ()
						o_action <= action_predict;
					else o_action <= action_random;
					
				end
				else o_action_valid <= 1;
			end
			
		end 
	end 

endmodule