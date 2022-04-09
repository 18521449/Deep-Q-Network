`timescale 1ns/1ps
module tb_bp_hidden_layer();

parameter DATA_WIDTH 				= 32;
parameter ADDRESS_WIDTH 			= 11;
parameter [DATA_WIDTH-1:0]  ALPHA 	= 32'h3DCCCCCD;
parameter WEIGHT_FILE 				= "target_ram_output_weight.txt";
parameter DELTA_IN_FILE 			= "main_ram_output_delta.txt";
parameter DELTA_OUT_FILE 			= "main_ram_hidden_2_delta.txt";
parameter DATA_NODE_FILE 			= "target_ram_hidden_2_data.txt";
parameter NUMBER_OF_FORWARD_NODE 	= 3;
parameter NUMBER_OF_BACK_NODE 		= 32;
parameter k=5;

reg 							clk;
reg 							rst_n;
reg 							i_valid;
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k i_valid <= 1;
	#k#k i_valid <= 0;
end

back_propagation_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
		.ALPHA					(ALPHA),
		.WEIGHT_FILE			(WEIGHT_FILE),
		.DELTA_IN_FILE			(DELTA_IN_FILE),
		.DELTA_OUT_FILE 		(DELTA_OUT_FILE),
		.DATA_NODE_FILE			(DATA_NODE_FILE),
		.NUMBER_OF_FORWARD_NODE	(NUMBER_OF_FORWARD_NODE),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_BACK_NODE)
	)
	tb_bp_hidden_layer_
	(	clk,
		rst_n,
		i_valid,
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



	
