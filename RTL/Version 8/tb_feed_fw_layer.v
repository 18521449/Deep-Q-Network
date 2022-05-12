`timescale 1ns/1ps
module tb_feed_fw_layer();
`include "params.sv"

parameter LEAKYRELU_ENABLE = 1'b1;
parameter k =5;

reg 							clk;
reg 							rst_n;
reg 							i_load_weight_enable;
reg 							i_load_data_enable;
reg	[NUMBER_OF_OUTPUT_NODE-1:0]	i_weight_addr;
reg 		[DATA_WIDTH-1:0] 	i_weight;
reg			[DATA_WIDTH-1:0] 	i_data;
wire[NUMBER_OF_OUTPUT_NODE-1:0]	o_load_weight_done;
wire		[DATA_WIDTH-1:0] 	o_data;
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_load_data_enable <= 0;
	i_load_weight_enable <= 0;
	#k#k 	i_load_weight_enable <= 1;
			i_weight_addr <= 2'b01;
			i_weight <= 32'h40A66666;
	#k#k 	i_weight <= 32'h4089999A;
	#k#k	i_weight <= 32'h3E19999A;
	#k#k	i_weight_addr <= 2'b10;
			i_weight <= 32'h4047AE14;
	#k#k 	i_weight <= 32'h4089999A;
	#k#k	i_weight <= 32'h3E19999A;
	#k#k	i_load_weight_enable <= 0;
	
	#k#k	i_load_data_enable <= 1;
			i_data <= 32'h40500000;
	#k#k 	i_data <= 32'h40300000;
	#k#k	i_load_data_enable <= 0;
end

feed_forward_layer
	#(	.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE),
		.LEAKYRELU_ENABLE		(LEAKYRELU_ENABLE))
	feed_forward_layer_tb
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_load_weight_enable	(i_load_weight_enable),
		.i_load_data_enable		(i_load_data_enable),
		.i_weight_addr			(i_weight_addr),
		.i_weight				(i_weight),
		.i_data					(i_data),
		.o_load_weight_done		(o_load_weight_done),
		.o_data 				(o_data),
		.o_valid				(o_valid)
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%b", o_data);
		#(10*k) $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
