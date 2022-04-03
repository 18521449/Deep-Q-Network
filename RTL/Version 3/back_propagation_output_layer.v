`timescale 1ns/1ps
module back_propagation_output_layer
	#(	parameter DATA_WIDTH = 32,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD,
		parameter ADDRESS_WIDTH = 11,
		parameter DATA_EXPECTED_FILE = "main_ram_expected.txt",
		parameter DATA_NODE_FILE = "main_ram_output_data.txt",
		parameter DATA_POINT_FILE = "main_ram_hidden_2_data.txt",
		parameter DELTA_FILE = "main_ram_hidden_2_delta.txt",
		parameter ERROR_FILE = "main_ram_hidden_2_error.txt",
		parameter NUMBER_OF_HIDDEN_NODE = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
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
wire 		[DATA_WIDTH-1:0] 		delta_point 		[NUMBER_OF_HIDDEN_NODE-1:0];
reg 		[DATA_WIDTH-1:0] 		ram_delta_point 	[NUMBER_OF_HIDDEN_NODE-1:0];
wire 		[DATA_WIDTH-1:0]		error_point			[NUMBER_OF_HIDDEN_NODE-1:0];
reg 		[DATA_WIDTH-1:0]		ram_error_point		[NUMBER_OF_HIDDEN_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out;			
wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out_ram_exp;
wire [NUMBER_OF_OUTPUT_NODE-1:0]	valid_out_ram_node;
reg 								write_file;
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

genvar j;
generate
	for (j=0; j<NUMBER_OF_OUTPUT_NODE; j=j+1) begin: node_generate
		back_propagation_node_from_output_layer
			#(	.DATA_WIDTH				(DATA_WIDTH),
				.ALPHA					(ALPHA),
				.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
				.DATA_FILE 				(DATA_POINT_FILE),
				.DELTA_FILE 			(DELTA_FILE),
				.ERROR_FILE 			(ERROR_FILE),
				.NODE_ADDRESS 			(j),
				.NUMBER_OF_HIDDEN_NODE 	(NUMBER_OF_HIDDEN_NODE)
			)
			node_output_gen
			(	.clk					(clk),
				.rst_n					(rst_n),
				.i_valid				(valid_out_ram_node[NUMBER_OF_OUTPUT_NODE-1]),
				.i_data_expected		(data_expected[j]),
				.i_data_node			(data_node[j]),
				.o_valid				(valid_out[j])
			);
	end
endgenerate

integer k;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
	end
	else begin
		if (&valid_out) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end

endmodule
