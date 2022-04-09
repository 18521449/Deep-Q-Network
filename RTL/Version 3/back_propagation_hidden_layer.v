`timescale 1ns/1ps
module back_propagation_hidden_layer
	#(	parameter DATA_WIDTH 				= 32,
		parameter ADDRESS_WIDTH 			= 11,
		parameter [DATA_WIDTH-1:0]  ALPHA 	= 32'h3DCCCCCD,
		parameter WEIGHT_FILE 				= "target_ram_output_weight.txt",
		parameter DELTA_IN_FILE 			= "main_ram_output_delta.txt",
		parameter DELTA_OUT_FILE 			= "main_ram_hidden_2_delta.txt",
		parameter DATA_NODE_FILE 			= "target_ram_hidden_2_data.txt",
		parameter NUMBER_OF_FORWARD_NODE 	= 3,
		parameter NUMBER_OF_BACK_NODE 		= 32
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
wire 		[DATA_WIDTH-1:0]		data_node				[NUMBER_OF_BACK_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0] 		delta_node	 			[NUMBER_OF_BACK_NODE-1:0];
reg 		[DATA_WIDTH-1:0] 		ram_delta_node	 		[NUMBER_OF_BACK_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire [NUMBER_OF_BACK_NODE-1:0]		valid_out;			
wire [NUMBER_OF_BACK_NODE-1:0]		valid_out_ram_node;
reg 								write_file;
wire 								valid_in;
//--------------------------------------------------------------------------------------//

genvar i;
generate 
	for (i=0; i<NUMBER_OF_BACK_NODE; i=i+1) begin: get_data_generate
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

assign valid_in = &valid_out_ram_node;

genvar j;
generate
	for (j=0; j<NUMBER_OF_BACK_NODE; j=j+1) begin: node_generate
		back_propagation_node_from_hidden_layer
			#(	.DATA_WIDTH				(DATA_WIDTH),
				.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
				.ALPHA					(ALPHA),
				.WEIGHT_FILE 			(WEIGHT_FILE),
				.DELTA_IN_FILE 			(DELTA_IN_FILE),
				.ADDRESS_NODE 			(j),
				.NUMBER_OF_FORWARD_NODE (NUMBER_OF_FORWARD_NODE),
				.NUMBER_OF_BACK_NODE	(NUMBER_OF_BACK_NODE)
			)
			node_output_gen
			(	.clk					(clk),
				.rst_n					(rst_n),
				.i_valid				(valid_in),
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
		for (k=0; k<NUMBER_OF_BACK_NODE; k=k+1) begin
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
