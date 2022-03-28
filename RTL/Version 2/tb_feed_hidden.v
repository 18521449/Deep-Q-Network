`timescale 1ns/1ps
module tb_feed_hidden();

parameter DATA_WIDTH = 32;
parameter ADDRESS_WIDTH = 5;
parameter DATA_INPUT_FILE = "target_ram_input_data.txt";
parameter DATA_OUTPUT_FILE = "target_ram_hidden_1_data.txt";
parameter WEIGHT_FILE = "target_ram_hidden_1_weight.txt";
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_OUTPUT_NODE = 32;

reg 														clk;
reg 														rst_n;
reg 														i_valid;
wire	 													o_valid;

initial begin
  clk <= 0;
  rst_n <= 1;
  i_valid <= 0;
  #k#k i_valid <= 1;
  #k#k i_valid <= 0;
  
end

feed_forward_hidden_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH			(ADDRESS_WIDTH),
		.DATA_INPUT_FILE		(DATA_INPUT_FILE),
		.DATA_OUTPUT_FILE		(DATA_OUTPUT_FILE),
		.WEIGHT_FILE			(WEIGHT_FILE),
		.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
		)
	feed_forward_hidden_layer_tb
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%b", o_data);
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
