`timescale 1ns/1ps
module feed_forward_layer
	#(	parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_OUTPUT_NODE = 32,
		parameter LEAKYRELU_ENABLE = 1'b1
		)
	(	clk,
		rst_n,
		i_load_weight_enable,
		i_load_data_enable,
		i_weight_addr,
		i_weight,
		i_data,
		o_load_weight_done,
		o_data,
		o_valid
	);
	`include "params.sv"
	
	//-----------------input and output port-----------------//
	input 									clk;
	input 									rst_n;
	input 									i_load_weight_enable;
	input 									i_load_data_enable;
	input 		[NUMBER_OF_OUTPUT_NODE-1:0]	i_weight_addr;
	input 		[DATA_WIDTH-1:0] 			i_weight;
	input		[DATA_WIDTH-1:0] 			i_data;
	output 		[NUMBER_OF_OUTPUT_NODE-1:0]	o_load_weight_done;
	output reg	[DATA_WIDTH-1:0] 			o_data;
	output reg 								o_valid;
	//-------------------------------------------------------//

	//------------------------------------------------------------------------------//
	// reg 	[DATA_WIDTH-1:0] 				weight;
	wire 	[DATA_WIDTH-1:0] 				data_out		[NUMBER_OF_OUTPUT_NODE-1:0]; 
	reg  	[DATA_WIDTH-1:0] 				ram_out			[NUMBER_OF_OUTPUT_NODE-1:0];
	wire 	[NUMBER_OF_OUTPUT_NODE-1:0] 	valid_out;
	// reg 	[NUMBER_OF_OUTPUT_NODE:0] 		load_weight_enable;
	// wire 	[NUMBER_OF_OUTPUT_NODE:0] 		load_weight_done;
	//------------------------------------------------------------------------------//
	
	genvar i;
	generate
		for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin: hidden_generate
			feed_forward_node 
			#( 	.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
				.LEAKYRELU_ENABLE		(LEAKYRELU_ENABLE))
			feed_forward_node_gen
			(	.clk					(clk),
				.rst_n					(rst_n),
				.i_load_weight_enable	(i_load_weight_enable&i_weight_addr[i]),
				.i_load_data_enable		(i_load_data_enable),
				.i_weight				(i_weight),
				.i_data					(i_data),
				.o_load_weight_done		(o_load_weight_done[i]),
				.o_data 				(data_out[i]),
				.o_valid				(valid_out[i])
			);
		end
	endgenerate
	
	// reg [$clog2(NUMBER_OF_OUTPUT_NODE)-1:0] 	load_weight_node_counter;
	reg [$clog2(NUMBER_OF_OUTPUT_NODE)-1:0] 	load_data_node_counter;
	reg 										load_data_out;

	initial begin
		//load_weight_node_counter 	<= 'd0;
		load_data_node_counter <= 'd0;
	end

	// always @(posedge clk) begin
		// if (i_load_weight_enable) begin
			// weight <= i_weight;
			// load_weight_enable[load_weight_node_counter] <= 1;
		// end
		// else begin
			// load_weight_enable[load_weight_node_counter] <= 0;
		// end
		// if (load_weight_done[load_weight_node_counter]) begin
			// load_weight_node_counter <= load_weight_node_counter + 1;
			// load_weight_enable[load_weight_node_counter-1] <= 0;
		// end
	// end

	integer j, k;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (j=0; j<NUMBER_OF_OUTPUT_NODE; j=j+1) begin
				ram_out[j] <= 'd0;
			end
		end
		else begin
			for (k=0; k<NUMBER_OF_OUTPUT_NODE; k=k+1) begin
				if (valid_out[k]) begin
					ram_out[k] <= data_out[k];
				end
			end
			if (valid_out[NUMBER_OF_OUTPUT_NODE-1]) begin
				load_data_out <= 1;
			end
			if (load_data_out) begin
				if (load_data_node_counter < NUMBER_OF_OUTPUT_NODE-1) begin
					o_valid <= 1;
					o_data <= ram_out[load_data_node_counter];
					load_data_node_counter <= load_data_node_counter + 1;
				end
				else begin
					if (load_data_node_counter == NUMBER_OF_OUTPUT_NODE-1) begin
						o_valid <= 1;
						o_data <= ram_out[NUMBER_OF_OUTPUT_NODE-1];
						load_data_out <= 0;
						load_data_node_counter <= 'd0;
					end
				end
			end 
			else begin
				o_valid <= 0;
				o_data <= 'dz;
			end
		end
	end

endmodule
