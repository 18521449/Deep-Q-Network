`timescale 1ns/1ps
module back_propagation
	#(	parameter DATA_WIDTH 						= 32,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0]  ALPHA 			= 32'h3DCCCCCD)
	(	clk,
		rst_n,
		i_data_valid,
		i_data_expected,
		i_data_node,
		i_weight_valid,
		i_weight,
		o_current_layer, // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		o_weight_valid,
		o_delta_addr,
		o_delta,
		o_delta_valid
	);
	
	localparam DATA_BUFFER_WIDTH = NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;
	localparam BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam LAYER_WIDTH = 2;
	
	//-----------------input and output port-----------------//
	input 										clk;
	input 										rst_n;
	input 										i_data_valid;
	input		[DATA_WIDTH-1:0]				i_data_expected;
	input		[DATA_WIDTH-1:0]				i_data_node;
	input 										i_weight_valid;
	input		[DATA_WIDTH-1:0]				i_weight;
	output reg 	[LAYER_WIDTH-1:0]				o_current_layer;
	output reg									o_weight_valid;
	output reg	[DATA_WIDTH-1:0]				o_delta;
	output reg 	[BIGEST_WIDTH-1:0]				o_delta_addr;
	output reg									o_delta_valid;
	//-------------------------------------------------------//

	//--------------------------------------------------------------------------------//
	
	wire 	[DATA_WIDTH-1:0]	data_out_outlayer;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_2;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_1;
	wire 	[DATA_WIDTH-1:0]	data_out_leaky;
	
	//---------------------------------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg 	[DATA_WIDTH-1:0]	weight;
	reg 	[DATA_WIDTH-1:0]	data_in_leaky;
	reg		[DATA_WIDTH-1:0] 	data_expected		[NUMBER_OF_OUTPUT_NODE-1:0];
	reg		[DATA_WIDTH-1:0] 	data_node_outlayer	[NUMBER_OF_OUTPUT_NODE-1:0];
	reg		[DATA_WIDTH-1:0] 	delta_outlayer		[NUMBER_OF_OUTPUT_NODE-1:0];
	reg		[DATA_WIDTH-1:0] 	delta_hidden_2		[NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0];
	reg		[DATA_WIDTH-1:0] 	delta_hidden_1		[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0];
	//---------------------------------------------------------------------------------//
	
	//-------------------------------------------------------------//
	reg											first_bit_select;
	reg 	[NUMBER_OF_OUTPUT_NODE-1:0] 		first_bit_outlayer;
	reg 	[NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0]	first_bit_hidden_2;
	reg 	[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]	first_bit_hidden_1;
	//-------------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 						valid_in;
	reg 						valid_in_leaky;
	reg  						valid_in_outlayer;
	reg  						valid_in_hidden_2;
	reg  						valid_in_hidden_1;
	wire 						valid_out_outlayer;
	wire 						valid_out_hidden_2;
	wire 						valid_out_hidden_1;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [NUMBER_OF_INPUT_NODE-1:0] 		expected_counter;
	reg [BIGEST_WIDTH:0] 				weight_counter;
	reg [BIGEST_WIDTH+1:0] 				data_in_counter;
	reg [BIGEST_WIDTH:0] 				data_node_counter;
	reg [BIGEST_WIDTH:0] 				delta_node_counter;
	//---------------------------------------------------------//

	back_propagation_node_from_output_layer
		#(	.DATA_WIDTH				(DATA_WIDTH)
		)
		bp_output_layer_node
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_in & valid_in_outlayer),
			.i_data_expected	(data_expected[expected_counter-1]),
			.i_data_node		(data_node_outlayer[expected_counter-1]),
			.o_data				(data_out_outlayer),
			.o_valid			(valid_out_outlayer)
		);

	back_propagation_node_from_hidden_2_layer
		#(	.DATA_WIDTH			(DATA_WIDTH)
		)
		bp_hidden_2_layer_node
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_in & valid_in_hidden_2),
			.i_delta			(delta_outlayer[weight_counter]),
			.i_weight			(weight),
			.o_data				(data_out_hidden_2),
			.o_valid			(valid_out_hidden_2)
		);

	back_propagation_node_from_hidden_1_layer
		#(	.DATA_WIDTH			(DATA_WIDTH)
		)
		bp_hidden_1_layer_node
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_in & valid_in_hidden_1),
			.i_delta			(delta_hidden_2[weight_counter]),
			.i_weight			(weight),
			.o_data				(data_out_hidden_1),
			.o_valid			(valid_out_hidden_1)
		);

	back_leakyrelu_function
		#(	.DATA_WIDTH 		(DATA_WIDTH),
			.ALPHA				(ALPHA)
		)
		bp_leaky_funct
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_in_leaky),
			.i_first_bit_select	(first_bit_select),
			.i_data				(data_in_leaky),
			.o_data				(data_out_leaky),
			.o_valid			(valid_out_leaky)
		);
		
	initial begin
		o_current_layer 		<= 'b00;
		weight_counter 			<= 'd0;
		expected_counter		<= 'd0;
		data_in_counter 		<= 'd0;
		data_node_counter 		<= 'd0;
		delta_node_counter 		<= 'd0;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_in_counter 		<= 'd0;
			weight_counter 			<= 'd0;
			expected_counter		<= 'd0;
			data_node_counter		<= 'd0;
			delta_node_counter 		<= 'd0;
		end
		else begin
		
			case(o_current_layer)
				2'b00: // INPUT STEP
					begin
						if (i_data_valid) begin
							if (data_in_counter < NUMBER_OF_OUTPUT_NODE) begin
								data_expected[data_in_counter] <= i_data_expected;
								data_node_outlayer[data_in_counter] <= i_data_node;
								first_bit_outlayer[data_in_counter] <= i_data_node[DATA_WIDTH-1];
								data_in_counter <= data_in_counter + 1;
							end
							else begin
								if (data_in_counter < NUMBER_OF_OUTPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
									first_bit_hidden_2[data_in_counter-NUMBER_OF_OUTPUT_NODE] <= i_data_node[DATA_WIDTH-1];
								end
								else begin
									if (data_in_counter < NUMBER_OF_OUTPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
										first_bit_hidden_1[data_in_counter-NUMBER_OF_OUTPUT_NODE-NUMBER_OF_HIDDEN_NODE_LAYER_2] <= i_data_node[DATA_WIDTH-1];
									end
								end
							end
							data_in_counter <= data_in_counter + 1;
							o_weight_valid <= 0;
						end 
						else begin
							if (data_in_counter == DATA_BUFFER_WIDTH) begin
								data_in_counter 	<= 'd0;
								weight_counter 		<= 'd0;
								expected_counter	<= 'd0;
								data_node_counter	<= 'd0;
								delta_node_counter 	<= 'd0;
								o_current_layer 	<= 2'b11;
								o_weight_valid 		<= 0;
							end
						end
					end
					
				2'b11: // OUTPUT LAYER
					begin
						valid_in_outlayer 	<= 1;
						valid_in_hidden_2 	<= 0;
						valid_in_hidden_1	<= 0;
						
						if (expected_counter < NUMBER_OF_OUTPUT_NODE) begin
							valid_in <= 1;
							expected_counter <= expected_counter + 1;
						end
						else valid_in <= 0;
						
						if (data_node_counter < NUMBER_OF_OUTPUT_NODE) begin
							if (valid_out_outlayer) begin
								data_in_leaky <= data_out_outlayer;
								first_bit_select <= first_bit_outlayer[data_node_counter];
								valid_in_leaky <= 1;
								data_node_counter <= data_node_counter + 1;
							end
							o_weight_valid <= 0;
						end
						else valid_in_leaky <= 0;
						
						if (delta_node_counter < NUMBER_OF_OUTPUT_NODE) begin	
							if (valid_out_leaky) begin	
								delta_outlayer[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							data_in_counter 	<= 'd0;
							data_node_counter	<= 'd0;
							delta_node_counter 	<= 'd0;
							o_current_layer 	<= 2'b10;
							o_weight_valid 		<= 1;
						end

					end
				
				2'b10: // HIDDEN LAYER 2
					begin
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 1;
						valid_in_outlayer	 	<= 0;
						
						if (i_weight_valid) begin
							weight <= i_weight;
							valid_in <= 1;
						end
						else valid_in <= 0;
						
						if (valid_in) begin
							if (weight_counter < NUMBER_OF_OUTPUT_NODE-1)
								weight_counter <= weight_counter + 1;
							else weight_counter <= 'd0;
						end
						
						if (data_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
							if (valid_out_hidden_2) begin
								data_in_leaky <= data_out_hidden_2;
								first_bit_select <= first_bit_hidden_2[data_node_counter];
								valid_in_leaky <= 1;
								data_node_counter <= data_node_counter + 1;
							end
							else valid_in_leaky <= 0;
							o_weight_valid <= 0;
						end
						else valid_in_leaky <= 0;
						
						if (delta_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin	
							if (valid_out_leaky) begin	
								delta_hidden_2[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							data_in_counter 	<= 'd0;
							data_node_counter	<= 'd0;
							delta_node_counter 	<= 'd0;
							o_current_layer 	<= 2'b01;
							o_weight_valid 		<= 1;
						end
					end
				
				2'b01: // HIDDEN LAYER 1
					begin
						valid_in_hidden_1 		<= 1;
						valid_in_hidden_2 		<= 0;
						valid_in_outlayer	 	<= 0;
						
						if (i_weight_valid) begin
							weight <= i_weight;
							valid_in <= 1;
						end
						else valid_in <= 0;
						
						if (valid_in) begin
							if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2-1)
								weight_counter <= weight_counter + 1;
							else weight_counter <= 'd0;
						end
						
						if (data_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
							if (valid_out_hidden_1) begin
								data_in_leaky <= data_out_hidden_1;
								first_bit_select <= first_bit_hidden_1[data_node_counter];
								valid_in_leaky <= 1;
								data_node_counter <= data_node_counter + 1;
							end
							else valid_in_leaky <= 0;
							o_weight_valid <= 0;
						end
						else valid_in_leaky <= 0;
						
						if (delta_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin	
							if (valid_out_leaky) begin	
								delta_hidden_1[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							data_in_counter 	<= 'd0;
							data_node_counter	<= 'd0;
							delta_node_counter 	<= 'd0;
							o_current_layer 	<= 2'b00;
							o_weight_valid 		<= 0;
						end
					end
			endcase
			
			if (valid_out_leaky) begin
				o_delta_addr <= delta_node_counter;
				o_delta <= data_out_leaky;
				o_delta_valid <= 1;
			end
			else o_delta_valid <= 0;
			
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
