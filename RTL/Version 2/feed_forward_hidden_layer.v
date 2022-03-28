module feed_forward_hidden_layer
	#(	parameter DATA_WIDTH = 32,
		parameter ADDRESS_WIDTH = 5,
		parameter DATA_INPUT_FILE = "target_ram_input_data.txt",
		parameter DATA_OUTPUT_FILE = "target_ram_hidden_1_data.txt",
		parameter WEIGHT_FILE = "target_ram_hidden_1_weight.txt",
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_OUTPUT_NODE = 32
		)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
//-----------------input and output port--------------------------------------------//
input 																		clk;
input 																		rst_n;
input 																		i_valid;
output reg 																	o_valid;
//----------------------------------------------------------------------------------//

//---------------------------------------------------------//
wire [DATA_WIDTH-1:0] 				data_out 		[NUMBER_OF_OUTPUT_NODE-1:0]; 
wire [NUMBER_OF_OUTPUT_NODE-1:0] 	valid_out; 
//---------------------------------------------------------//

genvar i;
generate
	for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin: hidden_generate
		feed_forward_node 
		#( 	.DATA_WIDTH				(DATA_WIDTH),
			.ADDRESS_WIDTH			(ADDRESS_WIDTH),
			.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
			.DATA_FILE				(DATA_INPUT_FILE),
			.WEIGHT_FILE			(WEIGHT_FILE),
			.ADDRESS_NODE			(i))
		feed_forward_node_gen
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(i_valid),
			.o_data		(data_out[i]),
			.o_valid	(valid_out[i])
		);
		ram
		#(
			.RAM_WIDTH				(DATA_WIDTH*NUMBER_OF_INPUT_NODE),
			.RAM_ADDR_BITS			(ADDRESS_WIDTH),
			.DATA_FILE				(DATA_OUTPUT_FILE),
			.ADDRESS				(i)
		)
		ram_data_gen
		(
			.clk			(clk),
			.rst_n			(rst_n),
			.ram_enable		(valid_out[i]),
			.write_enable	(1),
			.i_data			(data_out[i]),
			.o_data			()
		);
		end
endgenerate

always @(posedge clk) begin
	if (&valid_out) begin
		o_valid <= 1;
	end 
	else begin
		o_valid <= 0;
	end
end

endmodule
