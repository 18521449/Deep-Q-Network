`timescale 1ns/1ps
module tb_bp_output_layer();

parameter DATA_WIDTH 			= 32;
parameter ADDRESS_WIDTH 		= 11;
parameter DATA_EXPECTED_FILE 	= "main_ram_expected.txt";
parameter DATA_NODE_FILE 		= "target_ram_output_data.txt";
parameter DELTA_FILE 			= "main_ram_hidden_2_delta.txt";
parameter NUMBER_OF_OUTPUT_NODE = 3;
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

back_propagation_output_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH 			(ADDRESS_WIDTH),
		.DATA_EXPECTED_FILE		(DATA_EXPECTED_FILE),
		.DATA_NODE_FILE			(DATA_NODE_FILE),
		.DELTA_FILE 			(DELTA_FILE),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
	)
	tb_bp_out_lay
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



	
