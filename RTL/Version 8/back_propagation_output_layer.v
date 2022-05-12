`timescale 1ns/1ps
module back_propagation_output_layer
	#(
		parameter DATA_EXPECTED_FILE 		= "main_ram_expected.txt",
		parameter DATA_NODE_FILE 			= "main_ram_output_data.txt",
		parameter DELTA_OUT_FILE 			= "main_ram_output_delta.txt",
		parameter NUMBER_OF_OUTPUT_NODE 	= 3
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		o_delta,
		o_valid
	);
	`include "params.sv"
	
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	output reg 							o_valid;
	//---------------------------------------------------//

	//-------------------------------------------------------------------------------------//
	wire 		[DATA_WIDTH-1:0]		data_expected			[NUMBER_OF_OUTPUT_NODE-1:0];
	wire 		[DATA_WIDTH-1:0]		data_node				[NUMBER_OF_OUTPUT_NODE-1:0];
	//--------------------------------------------------------------------------------------//

	//--------------------------------------------------------------------------------------//
	wire 		[DATA_WIDTH-1:0] 		delta_node	 			[NUMBER_OF_OUTPUT_NODE-1:0];
	reg 		[DATA_WIDTH-1:0] 		ram_delta_node	 		[NUMBER_OF_OUTPUT_NODE-1:0];
	//--------------------------------------------------------------------------------------//

	//--------------------------------------------------------------------------------------//
	wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out;			
	wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out_ram_exp;
	wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out_ram_node;
	reg 								write_file;
	wire 								valid_in;
	//--------------------------------------------------------------------------------------//

	genvar i;
	generate 
		for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin: get_data_generate
			ram
				#(
					.RAM_WIDTH			(DATA_WIDTH),
					.RAM_ADDR_BITS		(ADDRESS_WIDTH),
					.DATA_FILE			(DATA_EXPECTED_FILE),
					.ADDRESS			(i)
				)
				ram_data_expected
				(
					.clk				(clk),
					.rst_n				(rst_n),
					.ram_enable			(i_valid),
					.write_enable		(1'b0),
					.i_data				(),
					.o_data				(data_expected[i]),
					.o_valid			(valid_out_ram_exp[i])
				);
			ram
				#(
					.RAM_WIDTH			(DATA_WIDTH),
					.RAM_ADDR_BITS		(ADDRESS_WIDTH),
					.DATA_FILE			(DATA_NODE_FILE),
					.ADDRESS			(i)
				)
				ram_data_node
				(
					.clk				(clk),
					.rst_n				(rst_n),
					.ram_enable			(i_valid),
					.write_enable		(1'b0),
					.i_data				(),
					.o_data				(data_node[i]),
					.o_valid			(valid_out_ram_node[i])
				);
		end
	endgenerate

	assign valid_in = (&valid_out_ram_exp) & (&valid_out_ram_node);

	genvar j;
	generate
		for (j=0; j<NUMBER_OF_OUTPUT_NODE; j=j+1) begin: node_generate
			back_propagation_node_from_output_layer
				#(	.DATA_WIDTH				(DATA_WIDTH))
				node_output_gen
				(	.clk					(clk),
					.rst_n					(rst_n),
					.i_valid				(valid_in),
					.i_data_expected		(data_expected[j]),
					.i_data_node			(data_node[j]),
					.o_delta_node			(delta_node[j]),
					.o_valid				(valid_out[j])
				);
		end
	endgenerate

	integer k;
	always @(posedge clk or negedge rst_n) begin	
		if (!rst_n) begin
		end
		else begin
			for (k=0; k<NUMBER_OF_OUTPUT_NODE; k=k+1) begin
				if (valid_out[k]) begin
					ram_delta_node[k] <= delta_node[k];
				end
			end
			if (&valid_out) begin
				write_file <= 1;
				#1 $writememh(DELTA_OUT_FILE, ram_delta_node);
			end
			else write_file <= 0;
			if (write_file) begin
				o_valid <= 1;
			end
			else begin
				o_valid <= 0;
			end
		end
	end

endmodule
