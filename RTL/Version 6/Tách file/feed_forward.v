`timescale 1ns/1ps
module feed_forward
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 5,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 5,
		parameter NUMBER_OF_OUTPUT_NODE = 3,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD
	)
	(	clk,
		rst_n,	
		i_data_valid,
		i_data,
		i_weight_valid,
		i_weight,
		o_current_layer, // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		o_weight_valid,
		o_data_addr,
		o_data,
		o_data_valid
	);	
	
	localparam DATA_BUFFER_WIDTH = NUMBER_OF_INPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;
	localparam BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	
	//-----------------input and output port-----------------//
	input 										clk;
	input 										rst_n;
	input 										i_data_valid;
	input		[DATA_WIDTH-1:0]				i_data;
	input 										i_weight_valid;
	input		[DATA_WIDTH-1:0]				i_weight;
	output reg 	[LAYER_WIDTH-1:0]				o_current_layer;
	output reg									o_weight_valid;
	output reg	[DATA_WIDTH-1:0]				o_data;
	output reg 	[BIGEST_WIDTH-1:0]				o_data_addr;
	output reg									o_data_valid;
	//-------------------------------------------------------//
	
	//--------------------------------------------------------------------------------//
	reg 	[DATA_WIDTH-1:0]	data;
	reg 	[DATA_WIDTH-1:0]	weight;
	reg		[DATA_WIDTH-1:0] 	data_buffer			[DATA_BUFFER_WIDTH-1:0];
	wire 	[DATA_WIDTH-1:0]	data_out;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_1;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_2;
	//---------------------------------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 						valid_in;
	reg  						valid_in_hidden_1;
	reg  						valid_in_hidden_2;
	reg  						valid_in_output_layer;
	wire 						valid_out_hidden_1;
	wire 						valid_out_hidden_2;
	wire 						valid_out;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [BIGEST_WIDTH-1:0] 		NUMBER_OF_CURRENT_NODE;
	reg [BIGEST_WIDTH-1:0] 		INPUT_NODE_CONFIG;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg [BIGEST_WIDTH-1:0] 		node_counter;
	reg [BIGEST_WIDTH-1:0] 		weight_counter;
	reg [BIGEST_WIDTH-1:0] 		data_counter;
	reg [BIGEST_WIDTH-1:0] 		data_in_counter;
	//---------------------------------------------------------//

	feed_forward_node_for_input_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE+1),
		.LEAKYRELU_ENABLE		(1'b1),
		.ALPHA					(ALPHA)
	)
	node_hidden_1
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_hidden_1),
		.i_weight				(weight),
		.i_data					(data),
		.o_data 				(data_out_hidden_1),
		.o_valid				(valid_out_hidden_1)
	);
	
	feed_forward_node_for_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_1+1),
		.LEAKYRELU_ENABLE		(1'b1),
		.ALPHA					(ALPHA)
	)
	node_hidden_2
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_hidden_2),
		.i_weight				(weight),
		.i_data					(data),
		.o_data 				(data_out_hidden_2),
		.o_valid				(valid_out_hidden_2)
	);
	
	feed_forward_node_for_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_2+1),
		.LEAKYRELU_ENABLE		(1'b0),
		.ALPHA					(ALPHA)
	)
	node_output_layer
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(valid_in & valid_in_output_layer),
		.i_weight				(weight),
		.i_data					(data),
		.o_data 				(data_out),
		.o_valid				(valid_out)
	);
	
	initial begin
		node_counter 	<= 'd0;
		weight_counter 	<= 'd0;
		data_counter 	<= 'd0;
		o_current_layer <= 'd0;
		data_in_counter <= 'd0;
	end
	
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			node_counter 	<= 'd0;
			weight_counter 	<= 'd0;
			data_counter 	<= 'd0;
			data_in_counter	<= 'd0;
		end
		else begin
		
			case(o_current_layer)
				2'b00: // INPUT LAYER
					begin
						if (data_in_counter < NUMBER_OF_INPUT_NODE) begin
							if (i_data_valid) begin
								data_buffer[data_in_counter] <= i_data;
								data_in_counter <= data_in_counter + 1;
							end
							o_weight_valid <= 0;
						end
						else begin
							data_in_counter <= 'd0;
							data_counter 	<= 'd0;
							node_counter 	<= 'd0;
							weight_counter 	<= 'd0;
							o_current_layer <= 2'b01;
							o_weight_valid 	<= 1;
						end
					end
				2'b01: // HIDDEN LAYER 1
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_INPUT_NODE;
						NUMBER_OF_CURRENT_NODE 	<= NUMBER_OF_HIDDEN_NODE_LAYER_1;
						valid_in_hidden_1 		<= 1;
						valid_in_hidden_2 		<= 0;
						valid_in_output_layer 	<= 0;
					end
				2'b10: // HIDDEN LAYER 2
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_HIDDEN_NODE_LAYER_1;
						NUMBER_OF_CURRENT_NODE 	<= NUMBER_OF_HIDDEN_NODE_LAYER_2;
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 1;
						valid_in_output_layer 	<= 0;
					end
				2'b11: // OUTPUT LAYER
					begin
						INPUT_NODE_CONFIG		<= NUMBER_OF_HIDDEN_NODE_LAYER_2;
						NUMBER_OF_CURRENT_NODE 	<= NUMBER_OF_OUTPUT_NODE;
						valid_in_hidden_1 		<= 0;
						valid_in_hidden_2 		<= 0;
						valid_in_output_layer 	<= 1;
					end
			endcase
			
			if (node_counter < NUMBER_OF_CURRENT_NODE) begin
				if (i_weight_valid) begin
					if (weight_counter < INPUT_NODE_CONFIG) begin
						data 			<= data_buffer[weight_counter];
						weight_counter 	<= weight_counter + 1;
					end
					else begin
						data			<= 'h3F800000;
						weight_counter 	<= 'd0;
						node_counter 	<= node_counter + 1;
					end
					valid_in 		<= 1;
					weight 			<= i_weight;
				end
				else begin
					valid_in 		<= 0;
				end
				o_weight_valid 	<= 0;
			end
			else begin
				node_counter <= 'd0;
				o_current_layer <= o_current_layer + 1;
				o_weight_valid 	<= 1;
			end
			
			if (valid_out) begin
				o_data_addr 	<= data_counter;
				o_data 			<= data_out;
				o_data_valid 	<= 1;
				data_counter 	<= data_counter + 1;
			end
			else begin
				o_data_addr 	<= 'dz;
				o_data 			<= 'dz;
				o_data_valid 	<= 0;
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
