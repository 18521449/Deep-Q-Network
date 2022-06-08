`timescale 1ns/1ps
module feed_forward
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(	clk,
		rst_n,	
		i_data_valid,
		i_data_layer,
		i_data_addr,
		i_data,
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		o_weight_valid_request,
		o_weight_layer_request, // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		o_weight_addr_request,
		o_data_valid,
		o_data_layer,
		o_data_addr,
		o_data
	);	
	
	localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//------------------------input and output port-----------------------//
	input 										clk;
	input 										rst_n;
	input 										i_data_valid;
	input 		[LAYER_WIDTH-1:0]				i_data_layer;
	input 		[DATA_COUNTER_WIDTH-1:0]		i_data_addr;
	input		[DATA_WIDTH-1:0]				i_data;
	input 										i_weight_valid;
	input 		[LAYER_WIDTH-1:0]				i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_weight_addr;
	input		[DATA_WIDTH-1:0]				i_weight;
	output reg									o_weight_valid_request;
	output reg 	[LAYER_WIDTH-1:0]				o_weight_layer_request;
	output reg	[WEIGHT_COUNTER_WIDTH-1:0]		o_weight_addr_request;
	output reg									o_data_valid;
	output reg	[LAYER_WIDTH-1:0]				o_data_layer;
	output reg 	[DATA_COUNTER_WIDTH-1:0]		o_data_addr;
	output reg	[DATA_WIDTH-1:0]				o_data;	
	//--------------------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg 	[DATA_WIDTH-1:0]	weight;
	wire 	[DATA_WIDTH-1:0]	data_out;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_1;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_2;
	//---------------------------------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg		[DATA_WIDTH-1:0] 	data_input			[NUMBER_OF_INPUT_NODE:0];
	reg		[DATA_WIDTH-1:0] 	data_hidden_1		[NUMBER_OF_HIDDEN_NODE_LAYER_1:0];
	reg		[DATA_WIDTH-1:0] 	data_hidden_2		[NUMBER_OF_HIDDEN_NODE_LAYER_2:0];
	//---------------------------------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 						valid_in;
	reg  						valid_in_hidden_1;
	reg  						valid_in_hidden_2;
	reg  						valid_in_outlayer;
	wire 						valid_out_hidden_1;
	wire 						valid_out_hidden_2;
	wire 						valid_out;
	reg 						weight_request;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [DATA_COUNTER_WIDTH:0] 		INPUT_NODE_CONFIG;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [DATA_COUNTER_WIDTH:0] 		node_in_counter;
	reg [DATA_COUNTER_WIDTH:0] 		node_out_counter;
	reg [WEIGHT_COUNTER_WIDTH:0] 	weight_counter;
	//---------------------------------------------------------//

	feed_forward_node_from_input_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.LEAKYRELU_ENABLE		(1'b1)
	)
	fw_hidden_1_node
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_hidden_1),
		.i_weight				(weight),
		.i_data					(data_input[node_in_counter]),
		.o_data 				(data_out_hidden_1),
		.o_valid				(valid_out_hidden_1)
	);
	
	feed_forward_node_from_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.LEAKYRELU_ENABLE		(1'b1)
	)
	fw_hidden_2_node
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_hidden_2),
		.i_weight				(weight),
		.i_data					(data_hidden_1[node_in_counter]),
		.o_data 				(data_out_hidden_2),
		.o_valid				(valid_out_hidden_2)
	);
	
	feed_forward_node_from_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.LEAKYRELU_ENABLE		(1'b0)
	)
	fw_output_layer_node
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_outlayer),
		.i_weight				(weight),
		.i_data					(data_hidden_2[node_in_counter]),
		.o_data 				(data_out),
		.o_valid				(valid_out)
	);
	
	initial begin
		data_input[NUMBER_OF_INPUT_NODE] <= 'h3F800000;
		data_hidden_1[NUMBER_OF_HIDDEN_NODE_LAYER_1] <= 'h3F800000;
		data_hidden_2[NUMBER_OF_HIDDEN_NODE_LAYER_2] <= 'h3F800000;
	end
	
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			o_weight_layer_request 	<= 2'b00;
		end
		else begin
		
			case(i_data_layer)
				2'b00: // INPUT LAYER
					begin
						if (i_data_valid) begin
							data_input[i_data_addr] 	<= i_data;
							if (i_data_addr == NUMBER_OF_INPUT_NODE-1) begin
								weight_request 			<= 1;
								o_weight_layer_request 	<= 2'b00;
								node_in_counter 		<= 'd0;
							end
							else weight_request 		<= 0;
						end
					end
			endcase
			
			case(o_weight_layer_request)
				2'b00: // PREPARE LOAD WEIGHT
					begin
						if (weight_request) begin
							weight_counter 			<= 'd0;
							node_out_counter 		<= 'd0;
							o_weight_layer_request 	<= 2'b01;
						end
					end
				2'b01: // HIDDEN LAYER 1
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_INPUT_NODE;
						valid_in_hidden_1 		<= 1;
						valid_in_hidden_2 		<= 0;
						valid_in_outlayer 		<= 0;
						
						if (weight_request) begin
							if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)) begin
								o_weight_valid_request 	<= 1;
								o_weight_addr_request 	<= weight_counter;
								weight_counter 			<= weight_counter + 1;
							end
							else begin
								o_weight_valid_request 	<= 0;
								weight_counter 			<= 'd0;
								weight_request 			<= 0;
							end
						end
						
						if (node_out_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
							if (valid_out_hidden_1) begin	
								data_hidden_1[node_out_counter] <= data_out_hidden_1;
								o_data_layer 		<= o_weight_layer_request;
								o_data_addr 		<= node_out_counter;
								o_data 				<= data_out_hidden_1;
								node_out_counter 	<= node_out_counter + 1;
							end
						end
						else begin
							o_weight_valid_request 	<= 0;
							o_weight_layer_request	<= 2'b10;
							node_out_counter 		<= 'd0;
							weight_request 			<= 1;
						end
					end
				2'b10: // HIDDEN LAYER 2
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_HIDDEN_NODE_LAYER_1;
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 1;
						valid_in_outlayer 		<= 0;
						
						if (weight_request) begin
							if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)) begin
								o_weight_valid_request 	<= 1;
								o_weight_addr_request 	<= weight_counter;
								weight_counter 			<= weight_counter + 1;
							end
							else begin
								o_weight_valid_request 	<= 0;
								weight_counter 			<= 'd0;
								weight_request 			<= 0;
							end
						end
						
						if (node_out_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
							if (valid_out_hidden_2) begin	
								data_hidden_2[node_out_counter] <= data_out_hidden_2;
								o_data_layer 		<= o_weight_layer_request;
								o_data_addr 		<= node_out_counter;
								o_data 				<= data_out_hidden_2;
								node_out_counter 	<= node_out_counter + 1;
							end
						end
						else begin
							o_weight_valid_request 	<= 0;
							o_weight_layer_request 	<= 2'b11;
							node_out_counter 		<= 'd0;
							weight_request 			<= 1;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_HIDDEN_NODE_LAYER_2;
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 0;
						valid_in_outlayer 		<= 1;
						
						if (weight_request) begin
							if (weight_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)) begin
								o_weight_valid_request 	<= 1;
								o_weight_addr_request 	<= weight_counter;
								weight_counter 			<= weight_counter + 1;
							end
							else begin
								o_weight_valid_request 	<= 0;
								weight_counter 			<= 'd0;
								weight_request 			<= 0;
							end
						end
						
						if (node_out_counter < NUMBER_OF_OUTPUT_NODE) begin
							if (valid_out) begin	
								o_data_layer 		<= o_weight_layer_request;
								o_data_addr 		<= node_out_counter;
								o_data 				<= data_out;
								node_out_counter 	<= node_out_counter + 1;
							end
						end
						else begin
							o_weight_valid_request 	<= 0;
							o_weight_layer_request 	<= 2'b00;
							node_out_counter 		<= 'd0;
							weight_request 			<= 0;
						end
					end
			endcase
			
			if (i_weight_valid) begin
				weight <= i_weight;
				valid_in <= 1;
			end
			else valid_in <= 0;
			
			if (valid_in) begin
				if (node_in_counter < INPUT_NODE_CONFIG)
					node_in_counter <= node_in_counter + 1;
				else node_in_counter <= 'd0;
			end
			
			if (valid_out_hidden_1 || valid_out_hidden_2 || valid_out) begin
				o_data_valid <= 1;
			end
			else o_data_valid <= 0;
			
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
