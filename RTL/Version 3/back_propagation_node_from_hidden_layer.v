`timescale 1ns/1ps
module back_propagation_node_from_hidden_layer
	#(	parameter DATA_WIDTH 				= 32,
		parameter ADDRESS_WIDTH 			= 11,
		parameter [DATA_WIDTH-1:0]  ALPHA 	= 32'h3DCCCCCD,
		parameter WEIGHT_FILE 				= "main_ram_output_weight.txt",
		parameter DELTA_IN_FILE 			= "main_ram_output_delta.txt",
		parameter ADDRESS_NODE 				= 0,
		parameter NUMBER_OF_FORWARD_NODE 	= 3,
		parameter NUMBER_OF_BACK_NODE		= 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_node,
		o_delta_node,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
input 		[DATA_WIDTH-1:0]		i_data_node;
output 		[DATA_WIDTH-1:0] 		o_delta_node;
output 	 							o_valid;
//---------------------------------------------------//

//-------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0]		delta			[NUMBER_OF_FORWARD_NODE-1:0];
wire 		[DATA_WIDTH-1:0]		weight			[NUMBER_OF_FORWARD_NODE-1:0];
reg 		[DATA_WIDTH-1:0]		data_node;
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0]		result_add_temp [NUMBER_OF_FORWARD_NODE:0];
reg 		[DATA_WIDTH-1:0]		result_mul_temp [NUMBER_OF_FORWARD_NODE-1:0];
wire 		[DATA_WIDTH-1:0]		data_out_mul 	[NUMBER_OF_FORWARD_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire 		[NUMBER_OF_FORWARD_NODE-1:0]	valid_out_ram_delta;
wire		[NUMBER_OF_FORWARD_NODE-1:0]	valid_out_ram_weight;
wire		[NUMBER_OF_FORWARD_NODE-1:0]	valid_out_mul;
wire 		[NUMBER_OF_FORWARD_NODE:0]		valid_add;
reg 										valid_in_add;
//--------------------------------------------------------------------------------------//


genvar i;
generate 
	for (i=0; i<NUMBER_OF_FORWARD_NODE; i=i+1) begin: get_delta_generate
		ram
		#(
			.RAM_WIDTH		(DATA_WIDTH),
			.RAM_ADDR_BITS	(ADDRESS_WIDTH),
			.DATA_FILE		(DELTA_IN_FILE),
			.ADDRESS		(i)
		)
		ram_delta_gen
		(
			.clk			(clk),
			.rst_n			(rst_n),
			.ram_enable		(i_valid),
			.write_enable	(1'b0),
			.i_data			(),
			.o_data			(delta[i]),
			.o_valid		(valid_out_ram_delta[i])
		);
	end
endgenerate

genvar j;
generate 
	for (j=0; j<NUMBER_OF_FORWARD_NODE; j=j+1) begin: get_weight_generate
		ram
		#(
			.RAM_WIDTH		(DATA_WIDTH),
			.RAM_ADDR_BITS	(ADDRESS_WIDTH),
			.DATA_FILE		(WEIGHT_FILE),
			.ADDRESS		(j*(NUMBER_OF_BACK_NODE+1) + ADDRESS_NODE)
		)
		ram_weight_gen
		(
			.clk			(clk),
			.rst_n			(rst_n),
			.ram_enable		(i_valid),
			.write_enable	(1'b0),
			.i_data			(),
			.o_data			(weight[j]),
			.o_valid		(valid_out_ram_weight[j])
		);
	end
endgenerate

assign valid_in = (&valid_out_ram_delta) & (&valid_out_ram_weight);

genvar k;
generate
	for (k=0; k<NUMBER_OF_FORWARD_NODE; k=k+1) begin: mul_generate
		multiplier_floating_point32 mul // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(valid_in),
				.inA		(delta[k]), 
				.inB		(weight[k]),
				.valid_out	(valid_out_mul[k]),
				.out_data	(data_out_mul[k]));
	end
endgenerate


//-------------------------------------------------------//
assign result_add_temp[0] = 'd0;
assign valid_add[0] = valid_in_add;
//-------------------------------------------------------//

genvar l;
generate
	for (l=0; l<NUMBER_OF_FORWARD_NODE; l=l+1) begin: add_generate
		adder_floating_point32 add // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(valid_add[l]),
				.inA		(result_mul_temp[l]), 
				.inB		(result_add_temp[l]),
				.valid_out	(valid_add[l+1]),
				.out_data	(result_add_temp[l+1]));
	end
endgenerate

multiplier_floating_point32 mul_deactivate // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(valid_add[NUMBER_OF_FORWARD_NODE]),
				.inA		(result_add_temp[NUMBER_OF_FORWARD_NODE]), 
				.inB		(((data_node[DATA_WIDTH-1]) ? (ALPHA) : 'h3F800000)),
				.valid_out	(o_valid),
				.out_data	(o_delta_node));

integer n;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		data_node <= 'd0;
	end
	else begin
		if (i_valid) begin
			data_node <= i_data_node;
		end
		for (n=0; n<NUMBER_OF_FORWARD_NODE; n=n+1) begin
			if (valid_out_mul[n]) begin
				result_mul_temp[n] <= data_out_mul[n];
			end
		end
		if (&valid_out_mul) begin
			valid_in_add <= 1'b1;
		end
		else valid_in_add <= 1'b0;
	end
end

endmodule
