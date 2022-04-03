`timescale 1ns/1ps
module back_propagation_node_from_output_layer
	#(	parameter DATA_WIDTH = 32,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD,
		parameter ADDRESS_WIDTH = 11,
		parameter DATA_FILE = "main_ram_hidden_1_data.txt",
		parameter DELTA_FILE = "main_ram_hidden_1_delta.txt",
		parameter ERROR_FILE = "main_ram_hidden_1_error.txt",
		parameter NODE_ADDRESS = 0,
		parameter NUMBER_OF_HIDDEN_NODE = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
input		[DATA_WIDTH-1:0] 		i_data_expected;
input		[DATA_WIDTH-1:0] 		i_data_node;
output reg 							o_valid;
//---------------------------------------------------//

//-------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0]		data_point			[NUMBER_OF_HIDDEN_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0] 		delta_point 		[NUMBER_OF_HIDDEN_NODE-1:0];
reg 		[DATA_WIDTH-1:0] 		ram_delta_point 	[NUMBER_OF_HIDDEN_NODE-1:0];
wire 		[DATA_WIDTH-1:0]		error_point			[NUMBER_OF_HIDDEN_NODE-1:0];
reg 		[DATA_WIDTH-1:0]		ram_error_point		[NUMBER_OF_HIDDEN_NODE-1:0];
reg 		[DATA_WIDTH-1:0] 		data_expected;
reg 		[DATA_WIDTH-1:0] 		data_node;
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire [NUMBER_OF_HIDDEN_NODE-1:0]	valid_out;			
wire [NUMBER_OF_HIDDEN_NODE-1:0]	valid_out_ram;
reg 								write_file;
//--------------------------------------------------------------------------------------//

genvar i;
generate 
	for (i=0; i<NUMBER_OF_HIDDEN_NODE; i=i+1) begin: get_data_generate
		ram
			#(
				.RAM_WIDTH			(DATA_WIDTH),
				.RAM_ADDR_BITS		(ADDRESS_WIDTH),
				.DATA_FILE			(DATA_FILE),
				.ADDRESS			(i)
			)
			ram_data_point
			(
				.clk				(clk),
				.rst_n				(rst_n),
				.ram_enable			(i_valid),
				.write_enable		(1'b0),
				.i_data				(),
				.o_data				(data_point[i]),
				.o_valid			(valid_out_ram[i])
			);
	end
endgenerate

genvar j;
generate
	for (j=0; j<NUMBER_OF_HIDDEN_NODE; j=j+1) begin: point_generate
		back_propagation_point_from_output_layer
		#(	.DATA_WIDTH 		(DATA_WIDTH),
			.ALPHA				(ALPHA)
		)
		point_output_gen
		(	.clk				(clk),
			.rst_n				(rst_n),
			.i_valid			(valid_out_ram[j]),
			.i_data_expected	(data_expected),
			.i_data_node		(data_node),
			.i_data_point		(data_point[j]),
			.o_delta_point		(delta_point[j]),
			.o_error_point		(error_point[j]),
			.o_valid			(valid_out[j])
		);
	end
endgenerate

integer k;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		for (k=0; k<NUMBER_OF_HIDDEN_NODE; k=k+1) begin
			ram_delta_point[k] <= 'd0;
			ram_error_point[k] <= 'd0;
		end
	end
	else begin
		if (i_valid) begin
			data_expected <= i_data_expected;
			data_node <= i_data_node;
		end
		for (k=0; k<NUMBER_OF_HIDDEN_NODE; k=k+1) begin
			if (valid_out[k]) begin
				ram_delta_point[k] <= delta_point[k];
				ram_error_point[k] <= error_point[k];
			end
		end
		if (&valid_out) begin
			write_file <= 1;
			$writememh(DELTA_FILE, ram_delta_point, NODE_ADDRESS*NUMBER_OF_HIDDEN_NODE, ((NODE_ADDRESS+1)*NUMBER_OF_HIDDEN_NODE)-1);
			$writememh(ERROR_FILE, ram_error_point, NODE_ADDRESS*NUMBER_OF_HIDDEN_NODE, ((NODE_ADDRESS+1)*NUMBER_OF_HIDDEN_NODE)-1);
		end 
		else begin
			write_file <= 0;
		end
		if (write_file) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end

endmodule
