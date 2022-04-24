module feed_forward_node
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_INPUT_NODE = 3,
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
	wire 	[DATA_WIDTH-1:0] 					data_out_add_33;
	wire 	[DATA_WIDTH-1:0] 					data_out_add_3;
	reg 	[DATA_WIDTH-1:0] 					data_out_add;
	//---------------------------------------------------------//
	//---------------------------------------------------------//
	wire 										valid_out_mul; 
	reg 						 				valid_add_3;
	reg 						 				valid_add_33;
	wire 										valid_out_add_3;
	wire 										valid_out_add_33;
	reg 						 				valid_leakyrelu;
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
	
	adder_33_input_pipeline_floating_point32 adder_33_node
		(	.clk		(clk),
			.rst_n		(rst_n), 
			.i_valid	(valid_add_33),
			.i_data		(data_out_mul_reg), 
			.o_data		(data_out_add_33),
			.o_valid	(valid_out_add_33)
		);
	
	adder_3_input_pipeline_floating_point32 adder_3_node
		(	.clk		(clk),
			.rst_n		(rst_n), 
			.i_valid	(valid_add_3),
			.i_data		(data_out_mul_reg), 
			.o_data		(data_out_add_3),
			.o_valid	(valid_out_add_3)
		);

	leakyrelu_function
		#(	.DATA_WIDTH			(DATA_WIDTH),
			.LEAKYRELU_ENABLE 	(LEAKYRELU_ENABLE),
			.ALPHA				(ALPHA)
		)
		leakyrelu_funct
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(valid_leakyrelu),
			.i_data		(data_out_add),
			.o_data		(o_data),
			.o_valid	(o_valid)
		);
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_out_mul_reg <= 'd0;
		end
		else begin
			if (valid_out_mul) begin
				data_out_mul_reg <= data_out_mul;
				if (NUMBER_OF_INPUT_NODE == 3) begin	
					valid_add_3 <= 1;
					valid_add_33 <= 0;
				end
				else begin
					valid_add_3 <= 0;
					valid_add_33 <= 1;
				end
			end
			else begin
				valid_add_3 <= 0;
				valid_add_33 <= 0;
			end
			
			if (valid_out_add_33 | valid_out_add_3) begin
				if (NUMBER_OF_INPUT_NODE == 3) begin
					data_out_add <= data_out_add_3;
					valid_leakyrelu <= 1;
				end
				else begin
					data_out_add <= data_out_add_33;
					valid_leakyrelu <= 1;
				end
			end
			else valid_leakyrelu <= 0;
		end
	end
	
endmodule



