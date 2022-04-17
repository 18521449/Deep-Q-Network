module feed_forward_node
	#(	parameter NUMBER_OF_INPUT_NODE = 2,
		parameter LEAKYRELU_ENABLE = 1'b1)
	(	clk,
		rst_n,
		i_load_weight_enable,
		i_load_data_enable,
		i_weight,
		i_data,
		o_load_weight_done,
		o_data,
		o_valid
	);
	`include "params.sv"
	
	//-----------------input and output port-----------------//
	input 							clk;
	input 							rst_n;
	input 							i_load_weight_enable;
	input 							i_load_data_enable;
	input 		[DATA_WIDTH-1:0] 	i_weight;
	input		[DATA_WIDTH-1:0] 	i_data;
	output reg					 	o_load_weight_done;
	output reg	[DATA_WIDTH-1:0] 	o_data;
	output reg 						o_valid;
	//-------------------------------------------------------//

	//-------------------------------buffer-------------------------------//
	reg 	[DATA_WIDTH-1:0] 	data_buffer		[NUMBER_OF_INPUT_NODE-1:0];
	reg 	[DATA_WIDTH-1:0] 	weight_buffer	[NUMBER_OF_INPUT_NODE-1:0];
	reg 	[DATA_WIDTH-1:0] 	bias_buffer;
	//--------------------------------------------------------------------//

	//-------------------------counter-------------------------//
	reg [$clog2(NUMBER_OF_INPUT_NODE+1)-1:0] 	weight_counter;
	reg [$clog2(NUMBER_OF_INPUT_NODE)-1:0] 		data_counter;
	reg 										valid_in;
	reg										 	load_data_done;
	//---------------------------------------------------------//
	
	//-----counter initial------//
	initial begin
		weight_counter <= 'd0;
		data_counter <= 'd0;
	end
	//--------------------------//
		
	//--------------------------------------------------------------//
	// Address i_load_data_enable and i_load_weight_enable signal //
	always @(posedge clk) begin
	
		//save weight in buffer
		if (i_load_weight_enable) begin
			if (weight_counter < NUMBER_OF_INPUT_NODE) begin
				weight_buffer[weight_counter] <= i_weight;
				o_load_weight_done <= 0;
			end
			else begin
				if (weight_counter == NUMBER_OF_INPUT_NODE) begin
					bias_buffer <= i_weight;
					o_load_weight_done <= 1;
				end
				else begin
					weight_counter <= 'd0;
				end
			end					
			weight_counter <= weight_counter + 1;
		end
		
		// save data in buffer
		if (i_load_data_enable) begin
			if (data_counter < NUMBER_OF_INPUT_NODE-1) begin
				data_buffer[data_counter] <= i_data;
				load_data_done <= 0;
			end
			else begin
				if (data_counter == NUMBER_OF_INPUT_NODE-1) begin
					data_buffer[data_counter] <= i_data;
					load_data_done <= 1;
				end
				else begin
					data_counter <= 'd0;
				end
			end
			data_counter <= data_counter + 1;
		end	
		
		if (load_data_done & o_load_weight_done) begin
			valid_in <= 1;
			load_data_done <= 0;
		end
		else valid_in <= 0;
	end
	//--------------------------------------------------------------//

	//--------------------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0] 	data_out_mul 	[NUMBER_OF_INPUT_NODE-1:0];
	reg 	[DATA_WIDTH-1:0] 	result_mul_temp	[NUMBER_OF_INPUT_NODE-1:0];
	wire 	[DATA_WIDTH-1:0] 	result_add_temp	[NUMBER_OF_INPUT_NODE:0];
	wire 	[DATA_WIDTH-1:0] 	data_out_bias;
	wire 	[DATA_WIDTH-1:0] 	data_out_temp;
	//--------------------------------------------------------------------//

	//---------------------------------------------------------//
	wire [NUMBER_OF_INPUT_NODE-1:0] 	valid_out_mul; 
	wire [NUMBER_OF_INPUT_NODE:0] 		valid_add;
	wire 								valid_out_bias;
	wire 								valid_out_temp;
	reg  								valid_in_add;
	wire [NUMBER_OF_INPUT_NODE-1:0]		valid_out_ram_data; 
	wire [NUMBER_OF_INPUT_NODE-1:0]		valid_out_ram_weight;
	//---------------------------------------------------------//

	//-------------------------------------------------------//
	assign result_add_temp[0] = 'd0;
	//-------------------------------------------------------//

	genvar i;
	generate
		for (i=0; i<NUMBER_OF_INPUT_NODE; i=i+1) begin: mul_generate
			multiplier_floating_point32 mul // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(load_data_done & o_load_weight_done),
					.inA		(data_buffer[i]), 
					.inB		(weight_buffer[i]),
					.valid_out	(valid_out_mul[i]),
					.out_data	(data_out_mul[i]));
		end
	endgenerate

	assign valid_add[0] = valid_in_add;

	genvar j;
	generate
		for (j=0; j<NUMBER_OF_INPUT_NODE; j=j+1) begin: add_generate
			adder_floating_point32 add // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(valid_add[j]),
					.inA		(result_mul_temp[j]), 
					.inB		(result_add_temp[j]),
					.valid_out	(valid_add[j+1]),
					.out_data	(result_add_temp[j+1]));
		end
	endgenerate

	adder_floating_point32 add_bias // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(valid_add[NUMBER_OF_INPUT_NODE]),
			.inA		(result_add_temp[NUMBER_OF_INPUT_NODE]), 
			.inB		(bias_buffer),
			.valid_out	(valid_out_bias),
			.out_data	(data_out_bias)
		);

	leakyrelu_function
		#(	.LEAKYRELU_ENABLE 	(LEAKYRELU_ENABLE)
		)
		leakyrelu_funct
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(valid_out_bias),
			.i_data		(data_out_bias),
			.o_data		(data_out_temp),
			.o_valid	(valid_out_temp)
		);


	integer g;
	always @(posedge clk) begin

		if (&valid_out_mul)
			valid_in_add = 1;
		else valid_in_add = 0;
		for (g=0; g<NUMBER_OF_INPUT_NODE; g=g+1) begin
			if (valid_out_mul[g]) begin
				result_mul_temp[g] <= data_out_mul[g];
			end
		end

		if (valid_out_temp) begin
			o_data <= data_out_temp;
			o_valid <= 1;
		end 
		else begin
			o_data <= 'dz;
			o_valid <= 0;
		end
	end
	
	//----------------------reset signal---------------------//
	integer k;
	always @(negedge rst_n) begin
		if (!rst_n) begin
			for (k=0; k < NUMBER_OF_INPUT_NODE; k=k+1) begin	
				weight_buffer[k] 	<= 'd0;
				data_buffer[k] 		<= 'd0;
			end
			bias_buffer 	<= 'd0;
			weight_counter 	<= 'd0;
			data_counter 	<= 'd0;
		end
	end
	//------------------------------------------------------//
endmodule
