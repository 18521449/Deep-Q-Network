`timescale 1ns/1ps
module tb_bp_node_hidden();

parameter DATA_WIDTH 				= 32;
parameter ADDRESS_WIDTH 			= 11;
parameter [DATA_WIDTH-1:0]  ALPHA 	= 32'h3DCCCCCD;
parameter WEIGHT_FILE 				= "target_ram_output_weight.txt";
parameter DELTA_IN_FILE 			= "main_ram_hidden_2_delta.txt";
parameter ADDRESS_NODE 				= 0;
parameter NUMBER_OF_FORWARD_NODE 	= 3;
parameter NUMBER_OF_BACK_NODE		= 32;
parameter k=5;

reg 							clk;
reg 							rst_n;
reg 	[DATA_WIDTH-1:0]		i_data_node;
reg 							i_valid;
wire	[DATA_WIDTH-1:0]		o_delta_node;		
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k i_valid <= 1;
	i_data_node <= 'h40e15c67;
	#k#k i_valid <= 0;
end

back_propagation_node_from_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
		.ALPHA					(ALPHA),
		.WEIGHT_FILE 			(WEIGHT_FILE),
		.DELTA_IN_FILE 			(DELTA_IN_FILE),
		.ADDRESS_NODE 			(ADDRESS_NODE),
		.NUMBER_OF_FORWARD_NODE (NUMBER_OF_FORWARD_NODE),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_BACK_NODE)
	)
	tb_bp_node_hidden_
	(	clk,
		rst_n,
		i_valid,
		i_data_node,
		o_delta_node,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%h", o_delta_node);
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
