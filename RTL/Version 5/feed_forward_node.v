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

	//-------------------------------buffer-------------------------------//
	reg 	[DATA_WIDTH-1:0] 	data_buffer		[NUMBER_OF_INPUT_NODE-1:0];
	//--------------------------------------------------------------------//
	//---------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0] 					data_out_mul;
	wire 	[DATA_WIDTH-1:0] 					data_out_add;
	reg 	[DATA_WIDTH-1:0] 					result_add_temp;
	reg 	[$clog2(NUMBER_OF_INPUT_NODE)-1:0] 	counter;
	//---------------------------------------------------------//
	//---------------------------------------------------------//
	wire 										valid_out_mul; 
	reg 						 				valid_add;
	wire 										valid_out_add;
	reg 										valid_leaky_relu;
	//---------------------------------------------------------//
	
	//-----counter initial------//
	initial begin
		counter <= 'd0;
	end
	//--------------------------//
	
	multiplier_floating_point32 mul // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(i_valid),
			.inA		(i_data), 
			.inB		(i_weight),
			.valid_out	(valid_out_mul),
			.out_data	(data_out_mul));
	
	adder_floating_point32 add // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(valid_add),
			.inA		(data_buffer[counter]), 
			.inB		(result_add_temp),
			.valid_out	(valid_out_add),
			.out_data	(data_out_add));
	
	leakyrelu_function
		#(	.DATA_WIDTH			(DATA_WIDTH),
			.LEAKYRELU_ENABLE 	(LEAKYRELU_ENABLE),
			.ALPHA				(ALPHA)
		)
		leakyrelu_funct
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(valid_leaky_relu),
			.i_data		(data_out_add),
			.o_data		(o_data),
			.o_valid	(o_valid)
		);
	
	

	integer i;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i=0; i < NUMBER_OF_INPUT_NODE; i=i+1) begin
				data_buffer[i] 	<= 'd0;
			end
			counter <= 'd0;
			result_add_temp <= 'd0;
		end
		else begin
			if (valid_out_mul) begin
				data_buffer[counter] <= data_out_mul;
				counter <= counter + 1;
			end
			else begin
				if (counter == NUMBER_OF_INPUT_NODE) begin
					counter <= counter - 1;
					valid_add <= 1;
				end
				else begin
					if (valid_out_add) begin
						result_add_temp <= data_out_add;
						valid_add <= 1;
						if (counter != 0)
							counter <= counter - 1;
					end
					else valid_add <= 0;
				end
			end
			if (counter == 0) begin
				if (valid_out_add)
					valid_leaky_relu <= 1;
				else valid_leaky_relu <= 0;
				result_add_temp <= 'd0;
			end
		end
	end
	
	// function for clog2
	function integer clog2;
	input integer value;
	begin
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	end
	endfunction
	
endmodule



