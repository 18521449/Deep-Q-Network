`timescale 1ns/1ps
module tb_feed_fw();

parameter DATA_WIDTH = 32;
parameter ADDRESS_WIDTH = 5;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter ADDRESS_NODE = 0;
parameter k =5;

reg 														clk;
reg 														rst_n;
reg 														i_valid;
reg 		[ADDRESS_WIDTH-1:0] 							i_addr;
reg			[DATA_WIDTH-1:0] 								i_bias;
wire		[DATA_WIDTH-1:0] 								o_data;
wire	 													o_valid;

initial begin
  clk <= 0;
  rst_n <= 1;
  i_valid <= 0;
  #k#k i_valid <= 1;
  #k#k i_valid <= 0;
  
end

feed_forward_node
	#(	.DATA_WIDTH(32),
		.ADDRESS_WIDTH(5),
		.NUMBER_OF_INPUT_NODE(2),
		.DATA_FILE("target_ram_input_data.txt"),
		.WEIGHT_FILE("target_ram_hidden_1_weight.txt"),
		.ADDRESS_NODE(ADDRESS_NODE))
	feed_forward_node_tb
	(	.clk(clk),
		.rst_n(rst_n),
		.i_valid(i_valid),
		.o_data(o_data),
		.o_valid(o_valid)
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



	
