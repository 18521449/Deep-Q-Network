`timescale 1ns/1ps
module back_propagation
	#(	parameter DATA_WIDTH 						= 32,
		parameter LAYER_WIDTH 						= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F	//0.002
	)
	(	clk,
		rst_n,
		i_data_valid,
		i_data_layer,
		i_data_addr,
		i_data,
		i_data_expected_valid,
		i_data_expected_addr,
		i_data_expected,
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		o_weight_valid_request,
		o_weight_layer_request, // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		o_weight_addr_request,
		o_error_valid,
		o_error_layer,
		o_error_addr,
		o_error
	);
	
	localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//-----------------input and output port-----------------//
	input 										clk;
	input 										rst_n;
	input 										i_data_valid;
	input 		[LAYER_WIDTH-1:0]				i_data_layer;
	input 		[DATA_COUNTER_WIDTH-1:0]		i_data_addr;
	input		[DATA_WIDTH-1:0]				i_data;
	input 										i_data_expected_valid;
	input 		[DATA_COUNTER_WIDTH-1:0]		i_data_expected_addr;
	input		[DATA_WIDTH-1:0]				i_data_expected;
	input 										i_weight_valid;
	input 		[LAYER_WIDTH-1:0]				i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_weight_addr;
	input		[DATA_WIDTH-1:0]				i_weight;
	output reg									o_weight_valid_request;
	output reg 	[LAYER_WIDTH-1:0]				o_weight_layer_request;
	output reg	[WEIGHT_COUNTER_WIDTH-1:0]		o_weight_addr_request;
	output reg									o_error_valid;
	output reg	[LAYER_WIDTH-1:0]				o_error_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]		o_error_addr;
	output reg	[DATA_WIDTH-1:0]				o_error;
	//-------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [DATA_COUNTER_WIDTH:0] 		INPUT_NODE_CONFIG;
	//---------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0]	data_out_outlayer;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_2;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_1;
	wire 	[DATA_WIDTH-1:0]	data_out_leaky;
	wire 	[DATA_WIDTH-1:0]	error;
	//---------------------------------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg 	[LAYER_WIDTH-1:0]	current_delta_layer;
	reg 	[DATA_WIDTH-1:0]	weight;
	reg 	[DATA_WIDTH-1:0]	data_in_leaky;
	reg 	[DATA_WIDTH-1:0]	data_point;
	reg 	[DATA_WIDTH-1:0]	delta;
	reg 	[DATA_WIDTH-1:0]	expected;
	reg 	[DATA_WIDTH-1:0]	data_node;
	//--------------------------------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg		[DATA_WIDTH-1:0] 	data_expected		[NUMBER_OF_OUTPUT_NODE-1:0];
	reg		[DATA_WIDTH-1:0] 	data_node_inlayer	[NUMBER_OF_INPUT_NODE-1:0];
	reg		[DATA_WIDTH-1:0] 	data_node_hidden_1	[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0];
	reg		[DATA_WIDTH-1:0] 	data_node_hidden_2	[NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0];
	reg		[DATA_WIDTH-1:0] 	data_node_outlayer	[NUMBER_OF_OUTPUT_NODE-1:0];
	
	reg		[DATA_WIDTH-1:0] 	delta_node_hidden_1	[NUMBER_OF_HIDDEN_NODE_LAYER_1:0];
	reg		[DATA_WIDTH-1:0] 	delta_node_hidden_2	[NUMBER_OF_HIDDEN_NODE_LAYER_2:0];
	reg		[DATA_WIDTH-1:0] 	delta_node_outlayer	[NUMBER_OF_OUTPUT_NODE:0];
	//---------------------------------------------------------------------------------//
	
	//-------------------------------------------------------------//
	reg							first_bit_select;
	reg 						valid_in;
	reg 						valid_in_leaky;
	reg 						valid_in_error;
	reg  						valid_in_hidden_1;
	reg  						valid_in_hidden_2;
	reg  						valid_in_outlayer;
	
	wire 						valid_out_error;
	wire 						valid_out_outlayer;
	wire 						valid_out_hidden_2;
	wire 						valid_out_hidden_1;
	wire 						valid_out_leaky;
	//-------------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 						expected_active;
	reg							inlayer_active;
	reg 						hidden_1_active;
	reg							hidden_2_active;
	reg							outlayer_active;
	reg 						weight_request;
	reg							error_calculation_active;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [NUMBER_OF_OUTPUT_NODE-1:0] 	expected_counter;
	reg [WEIGHT_COUNTER_WIDTH-1:0] 		weight_counter;
	reg [DATA_COUNTER_WIDTH:0] 			delta_node_counter;
	reg [DATA_COUNTER_WIDTH:0] 			data_point_counter;
	reg [DATA_COUNTER_WIDTH:0] 			delta_counter;
	reg [WEIGHT_COUNTER_WIDTH-1:0]     error_counter;
	reg [DATA_COUNTER_WIDTH:0]			node_in_counter;
	reg [DATA_COUNTER_WIDTH:0]			node_out_counter;
	reg [DATA_COUNTER_WIDTH:0]			node_counter;
	//---------------------------------------------------------//

	back_propagation_node_from_output_layer
		#(	.DATA_WIDTH				(DATA_WIDTH)
		)
		bp_output_layer_node
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_in & valid_in_outlayer),
			.i_data_expected	(expected),
			.i_data_node		(data_node),
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
			.i_delta			(delta_node_outlayer[node_in_counter]),
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
			.i_delta			(delta_node_hidden_2[node_in_counter]),
			.i_weight			(weight),
			.o_data				(data_out_hidden_1),
			.o_valid			(valid_out_hidden_1)
		);

	back_leakyrelu_function
		#(	.DATA_WIDTH 		(DATA_WIDTH)
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
	
	back_error_calculation
		#(	.DATA_WIDTH 			(DATA_WIDTH),
			.LEARNING_RATE			(LEARNING_RATE)
		)
		bp_error_calculation
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_valid				(valid_in_error),
			.i_data_point			(data_point),
			.i_delta				(delta),
			.o_error				(error),
			.o_valid				(valid_out_error)
		);
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			current_delta_layer 	<= 2'b00;
		end
		else begin
			
			if (i_data_expected_valid) begin
				data_expected[i_data_expected_addr] <= i_data_expected;
				if (i_data_expected_addr == NUMBER_OF_OUTPUT_NODE-1) begin
					expected_active <= 1;
				end
				else expected_active <= 0;
			end
			
			case(i_data_layer)
				2'b00: // INPUT LAYER
					begin
						if (i_data_valid) begin
							data_node_inlayer[i_data_addr] <= i_data;
							if (i_data_addr == NUMBER_OF_INPUT_NODE-1) begin
								inlayer_active <= 1;
							end
							else inlayer_active <= 0;
						end
					end
				2'b01: // HIDDEN 1 LAYER
					begin
						if (i_data_valid) begin
							data_node_hidden_1[i_data_addr] <= i_data;
							if (i_data_addr == NUMBER_OF_HIDDEN_NODE_LAYER_1-1) begin
								hidden_1_active <= 1;
							end
							else hidden_1_active <= 0;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (i_data_valid) begin
							data_node_hidden_2[i_data_addr] <= i_data;
							if (i_data_addr == NUMBER_OF_HIDDEN_NODE_LAYER_2-1) begin
								hidden_2_active <= 1;
							end
							else hidden_2_active <= 0;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (i_data_valid) begin
							data_node_outlayer[i_data_addr] <= i_data;
							if (i_data_addr == NUMBER_OF_OUTPUT_NODE-1) begin
								outlayer_active <= 1;
							end
							else outlayer_active <= 0;
						end
					end
			endcase
			
			if (expected_active & inlayer_active & hidden_1_active & hidden_2_active & outlayer_active) begin
				weight_request <= 1;
				current_delta_layer <= 2'b00;
				node_in_counter <= 'd0;
				expected_active <= 0;
				inlayer_active 	<= 0;
				hidden_1_active <= 0;
				hidden_2_active <= 0;
				outlayer_active	<= 0;
			end
			
			case(current_delta_layer)
				2'b00: // PREPARE LOAD WEIGHT
					begin
						if (weight_request) begin
							weight_counter 		<= 'd0;
							expected_counter	<= 'd0;
							node_out_counter 	<= 'd0;
							delta_node_counter	<= 'd0;
							current_delta_layer <= 2'b11;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 0;
						valid_in_outlayer 		<= 1;
						
						if (node_out_counter < NUMBER_OF_OUTPUT_NODE) begin
							if (valid_out_outlayer) begin	
								data_in_leaky <= data_out_outlayer;
								first_bit_select <= data_node_outlayer[node_out_counter][DATA_WIDTH-1];
								valid_in_leaky <= 1;
								node_out_counter <= node_out_counter + 1;
							end
							else valid_in_leaky <= 0;
						end
						else begin
							valid_in_leaky <= 0;
							node_out_counter <= 'd0;
						end
						
						if (delta_node_counter < NUMBER_OF_OUTPUT_NODE) begin	
							if (valid_out_leaky) begin	
								delta_node_outlayer[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							o_weight_valid_request <= 0;
							current_delta_layer <= 2'b10;
							delta_node_counter <= 'd0;
							weight_request <= 1;
							node_counter 	<= 'd0;
							weight_counter 	<= 'd0;
						end
					end
				2'b10: // HIDDEN LAYER 2
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_OUTPUT_NODE;
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 1;
						valid_in_outlayer 		<= 0;
						
						if (weight_request) begin
							if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2+1) begin
								if (weight_counter < NUMBER_OF_OUTPUT_NODE-1) begin
									weight_counter <= weight_counter + 1;
								end
								else begin	
									weight_counter <= 'd0;
									node_counter <= node_counter + 1;
								end
								o_weight_valid_request <= 1;
								o_weight_layer_request <= 2'b11;
								o_weight_addr_request <= weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)+node_counter;
							end
							else begin
								o_weight_valid_request <= 0;
								node_counter <= 'd0;
								weight_counter <= 'd0;
								weight_request <= 0;
							end
						end
						
						if (node_out_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2+1) begin
							if (valid_out_hidden_2) begin
								valid_in_leaky <= 1;
								data_in_leaky <= data_out_hidden_2;
								node_out_counter <= node_out_counter + 1;
								if (node_out_counter == NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
									first_bit_select <= 0;
								end
								else first_bit_select <= data_node_hidden_2[node_out_counter][DATA_WIDTH-1];
							end
							else valid_in_leaky <= 0;
						end
						else begin
							valid_in_leaky <= 0;
							node_out_counter <= 'd0;
						end
						
						if (delta_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2+1) begin	
							if (valid_out_leaky) begin	
								delta_node_hidden_2[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							o_weight_valid_request <= 0;
							current_delta_layer <= 2'b01;
							delta_node_counter <= 'd0;
							weight_request <= 1;
						end
					end
				2'b01: // HIDDEN LAYER 1
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_HIDDEN_NODE_LAYER_2;
						valid_in_hidden_1 		<= 1;
						valid_in_hidden_2 		<= 0;
						valid_in_outlayer 		<= 0;
						
						if (weight_request) begin
							if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1+1) begin
								if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2-1) begin
									weight_counter <= weight_counter + 1;
								end
								else begin	
									weight_counter <= 'd0;
									node_counter <= node_counter + 1;
								end
								o_weight_valid_request <= 1;
								o_weight_layer_request <= 2'b10;
								o_weight_addr_request <= weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)+node_counter;
							end
							else begin
								o_weight_valid_request <= 0;
								node_counter <= 'd0;
								weight_counter <= 'd0;
								weight_request <= 0;
							end
						end
						
						if (node_out_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1+1) begin
							if (valid_out_hidden_1) begin
								valid_in_leaky <= 1;
								data_in_leaky <= data_out_hidden_1;
								node_out_counter <= node_out_counter + 1;
								if (node_out_counter == NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
									first_bit_select <= 0;
								end
								else first_bit_select <= data_node_hidden_1[node_out_counter][DATA_WIDTH-1];
							end
							else valid_in_leaky <= 0;
						end
						else begin
							valid_in_leaky <= 0;
							node_out_counter <= 'd0;
						end
						
						if (delta_node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1+1) begin	
							if (valid_out_leaky) begin	
								delta_node_hidden_1[delta_node_counter] <= data_out_leaky;
								delta_node_counter <= delta_node_counter + 1;
							end
						end
						else begin
							o_weight_valid_request <= 0;
							current_delta_layer <= 2'b00;
							delta_node_counter <= 'd0;
							weight_request <= 0;
							o_error_layer <= 2'b11;
							error_calculation_active <= 1;
							delta_counter <= 'd0;
							data_point_counter <= 'd0;
							error_counter <= 'd0;
						end				
					end
			endcase
			
			case(o_error_layer)
				2'b11: // ERROR OUTPUT LAYER 
					begin
						if(error_calculation_active) begin
							if (delta_counter < NUMBER_OF_OUTPUT_NODE) begin
								if (data_point_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_outlayer[delta_counter];
									data_point 			<= data_node_hidden_2[data_point_counter];
									data_point_counter 	<= data_point_counter + 1;
								end
								else begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_outlayer[delta_counter];
									data_point 			<= 'h3F800000;
									data_point_counter 	<= 'd0;
									delta_counter 		<= delta_counter + 1;
								end
							end
							else begin
								valid_in_error 	<= 0;
								delta_counter 	<= 'd0;
								error_calculation_active <= 0;
							end
						end
						
						if (error_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)) begin
							if (valid_out_error) begin
								o_error_valid 	<= 1;
								o_error_addr 	<= error_counter;
								o_error 		<= error;
								error_counter 	<= error_counter + 1;
							end
							else o_error_valid 	<= 0;
						end
						else begin
							error_counter <= 'd0;
							o_error_valid <= 0;
							o_error_layer <= 'b10;
							error_calculation_active <= 1;
						end
					end
				2'b10: // ERROR HIDDEN 2 LAYER	
					begin
						if (error_calculation_active) begin
							if (delta_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
								if (data_point_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_hidden_2[delta_counter];
									data_point 			<= data_node_hidden_1[data_point_counter];
									data_point_counter 	<= data_point_counter + 1;
								end
								else begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_hidden_2[delta_counter];
									data_point 			<= 'h3F800000;
									data_point_counter 	<= 'd0;
									delta_counter 		<= delta_counter + 1;
								end
							end
							else begin
								valid_in_error 	<= 0;
								delta_counter 	<= 'd0;
								error_calculation_active <= 0;
							end
						end
						
						if (error_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)) begin
							if (valid_out_error) begin
								o_error_valid 	<= 1;
								o_error_addr 	<= error_counter;
								o_error 		<= error;
								error_counter 	<= error_counter + 1;
							end
							else o_error_valid 	<= 0;
						end
						else begin
							error_counter <= 'd0;
							o_error_valid <= 0;
							o_error_layer <= 'b01;
							error_calculation_active <= 1;
						end
					end
				2'b01: // ERROR HIDDEN 1 LAYER	
					begin
						if (error_calculation_active) begin
							if (delta_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
								if (data_point_counter < NUMBER_OF_INPUT_NODE) begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_hidden_1[delta_counter];
									data_point 			<= data_node_inlayer[data_point_counter];
									data_point_counter 	<= data_point_counter + 1;
								end
								else begin
									valid_in_error 		<= 1;
									delta 				<= delta_node_hidden_1[delta_counter];
									data_point 			<= 'h3F800000;
									data_point_counter 	<= 'd0;
									delta_counter 		<= delta_counter + 1;
								end
							end
							else begin
								valid_in_error <= 0;
								delta_counter <= 'd0;
								error_calculation_active <= 0;
							end
						end
						
						if (error_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)) begin
							if (valid_out_error) begin
								o_error_valid 	<= 1;
								o_error_addr 	<= error_counter;
								o_error 		<= error;
								error_counter 	<= error_counter + 1;
							end
							else o_error_valid 	<= 0;
						end
						else begin
							error_counter <= 'd0;
							o_error_valid <= 0;
							o_error_layer <= 'b00;
							error_calculation_active <= 0;
						end
					end
			endcase
			
			if (current_delta_layer == 2'b11) begin
				if (expected_counter < NUMBER_OF_OUTPUT_NODE) begin
					valid_in 	<= 1;
					expected 	<= data_expected[expected_counter];
					data_node 	<= data_node_outlayer[expected_counter];
					expected_counter <= expected_counter + 1;
				end
				else valid_in <= 0;
			end 
			else begin
				if (i_weight_valid) begin
					weight <= i_weight;
					valid_in <= 1;
				end
				else valid_in <= 0;
			end
			
			if (node_in_counter < INPUT_NODE_CONFIG-1) begin
				if (valid_in) begin
					node_in_counter <= node_in_counter + 1;
				end
			end
			else node_in_counter <= 'd0;
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
