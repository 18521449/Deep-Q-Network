`timescale 1ns/1ps
module feed_forward
	(	clk,
		rst_n,
		i_load_weight_enable,
		i_load_data_enable,
		i_weight_addr,
		i_weight,
		i_data,
		o_load_weight_done,
		o_data_addr,
		o_data,
		o_valid
	);
	`include "params.sv"
	
	localparam TOTAL_NODE = NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;	
	
	//-----------------input and output port-----------------//
	input 									clk;
	input 									rst_n;
	input 									i_load_weight_enable;
	input 									i_load_data_enable;
	input 		[TOTAL_NODE-1:0]			i_weight_addr;
	input 		[DATA_WIDTH-1:0] 			i_weight;
	input		[DATA_WIDTH-1:0] 			i_data;
	output 		[TOTAL_NODE-1:0]			o_load_weight_done;
	output reg	[TOTAL_NODE-1:0]			o_data_addr;
	output reg	[DATA_WIDTH-1:0] 			o_data;
	output reg 								o_valid;
	//-------------------------------------------------------//
	
	
	//---------------------------------------------------------//
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_1;
	wire 	[DATA_WIDTH-1:0]	data_out_hidden_2;
	wire 	[DATA_WIDTH-1:0]	data_out_temp;
	//---------------------------------------------------------//
	
	//---------------------------------------------------------//
	wire 						valid_out_hidden_1;
	wire 						valid_out_hidden_2;
	wire 						valid_out_temp;
	//---------------------------------------------------------//

	feed_forward_layer
		#(	.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
			.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.LEAKYRELU_ENABLE		(1'b1))
		fw_hidden_layer_1
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_load_weight_enable	(i_load_weight_enable),
			.i_load_data_enable		(i_load_data_enable),
			.i_weight_addr			(i_weight_addr[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]),
			.i_weight				(i_weight),
			.i_data					(i_data),
			.o_load_weight_done		(o_load_weight_done[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0]),
			.o_data 				(data_out_hidden_1),
			.o_valid				(valid_out_hidden_1)
		);
		
	feed_forward_layer
		#(	.NUMBER_OF_INPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
			.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.LEAKYRELU_ENABLE		(1'b1))
		fw_hidden_layer_2
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_load_weight_enable	(i_load_weight_enable),
			.i_load_data_enable		(valid_out_hidden_1),
			.i_weight_addr			(i_weight_addr[NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1-1:NUMBER_OF_HIDDEN_NODE_LAYER_1]),
			.i_weight				(i_weight),
			.i_data					(data_out_hidden_1),
			.o_load_weight_done		(o_load_weight_done[NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1-1:NUMBER_OF_HIDDEN_NODE_LAYER_1]),
			.o_data 				(data_out_hidden_2),
			.o_valid				(valid_out_hidden_2)
		);

	feed_forward_layer
		#(	.NUMBER_OF_INPUT_NODE	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
			.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE),
			.LEAKYRELU_ENABLE		(1'b0))
		fw_output_layer
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_load_weight_enable	(i_load_weight_enable),
			.i_load_data_enable		(valid_out_hidden_2),
			.i_weight_addr			(i_weight_addr[NUMBER_OF_OUTPUT_NODE+NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1-1:NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1]),
			.i_weight				(i_weight),
			.i_data					(data_out_hidden_2),
			.o_load_weight_done		(o_load_weight_done[NUMBER_OF_OUTPUT_NODE+NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1-1:NUMBER_OF_HIDDEN_NODE_LAYER_2+NUMBER_OF_HIDDEN_NODE_LAYER_1]),
			.o_data 				(data_out_temp),
			.o_valid				(valid_out_temp)
		);
		
	reg [$clog2(TOTAL_NODE)-1:0] 	node_counter;
		
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			node_counter <= 'd0;
		end
		else begin
			if (valid_out_hidden_1) begin
				o_data <= data_out_hidden_1;
			end
			if (valid_out_hidden_2) begin
				o_data <= data_out_hidden_2;
			end
			if (valid_out_temp) begin
				o_data <= data_out_temp;
			end
			if (valid_out_hidden_1 || valid_out_hidden_2 || valid_out_temp) begin
				o_valid <= 1;
				o_data_addr <= node_counter;
				node_counter <= node_counter + 1;
			end
			else begin
				o_valid <= 0;
				o_data_addr <= 'dz;
				o_data <= 'dz;
			end
		end
	end	
endmodule
