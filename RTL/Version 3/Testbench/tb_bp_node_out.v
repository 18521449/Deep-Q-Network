`timescale 1ns/1ps
module tb_bp_node_out();

parameter DATA_WIDTH = 32;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter ADDRESS_WIDTH = 11;
parameter DATA_FILE = "main_ram_hidden_1_data.txt";
parameter DELTA_FILE = "main_ram_hidden_1_delta.txt";
parameter ERROR_FILE = "main_ram_hidden_1_error.txt";
parameter NODE_ADDRESS = 0;
parameter NUMBER_OF_HIDDEN_NODE = 2;
parameter k=5;

reg 							clk;
reg 							rst_n;
reg 							i_valid;
reg		[DATA_WIDTH-1:0] 		i_data_expected;
reg		[DATA_WIDTH-1:0] 		i_data_node;
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k i_valid <= 1;
	i_data_expected <= 'h40A66666;
	i_data_node <= 'hC059999A;
	#k#k i_valid <= 0;
end

back_propagation_node_from_output_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ALPHA					(ALPHA),
		.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
		.DATA_FILE 				(DATA_FILE),
		.DELTA_FILE 			(DELTA_FILE),
		.ERROR_FILE 			(ERROR_FILE),
		.NODE_ADDRESS 			(NODE_ADDRESS),
		.NUMBER_OF_HIDDEN_NODE 	(NUMBER_OF_HIDDEN_NODE)
	)
	tb_bp_node_out
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
