`timescale 1ns/1ps
module tb_feed_forward();
`include "params.sv"

parameter WEIGHT_FILE = "weight.txt";
parameter TOTAL_NODE = NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;	
parameter TOTAL_WEIGHT = 5*3 + 5*6 + 3*6;
parameter k =5;

reg 							clk;
reg 							rst_n;
reg 							i_load_weight_enable;
reg 							i_load_data_enable;
reg			[TOTAL_NODE-1:0]	i_weight_addr;
reg 		[DATA_WIDTH-1:0] 	i_weight;
reg			[DATA_WIDTH-1:0] 	i_data;
wire		[TOTAL_NODE-1:0]	o_load_weight_done;
wire 		[TOTAL_NODE-1:0]	o_data_addr;
wire		[DATA_WIDTH-1:0] 	o_data;
wire	 						o_valid;

reg [DATA_WIDTH-1:0] 			ram_weight 		[TOTAL_WEIGHT-1:0];
reg [$clog2(TOTAL_WEIGHT)-1:0]	weight_counter;
reg [$clog2(TOTAL_NODE)-1:0]	node_counter;

initial begin
	$readmemh(WEIGHT_FILE, ram_weight);
	clk <= 0;
	rst_n <= 1;
	i_load_data_enable <= 0;
	i_load_weight_enable <= 0;
	i_weight_addr <= 'd1;
	weight_counter <= 'd0;
	node_counter <= 'd0;
	#k#k 	i_load_weight_enable <= 1;
			i_weight <= ram_weight[0];
			i_load_data_enable <= 1;
			i_data <= 32'h40500000;
	#k#k 	i_data <= 32'h40300000;
	#k#k	i_load_data_enable <= 0;
end

feed_forward	feed_forward_tb
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_load_weight_enable	(i_load_weight_enable),
		.i_load_data_enable		(i_load_data_enable),
		.i_weight_addr			(i_weight_addr),
		.i_weight				(i_weight),
		.i_data					(i_data),
		.o_load_weight_done		(o_load_weight_done),
		.o_data_addr			(o_data_addr),
		.o_data 				(o_data),
		.o_valid				(o_valid)
	);

always @(posedge clk) begin
	if (i_load_weight_enable) begin
		
		if (o_load_weight_done[node_counter]) begin
			node_counter <= node_counter + 1;
			i_weight_addr <= i_weight_addr << 1;
			i_weight <= ram_weight[weight_counter];
		end
		else begin
			i_weight <= ram_weight[weight_counter+1];
			weight_counter <= weight_counter + 1;
		end
	end
	if (o_valid) begin
		$display("%h", o_data);
	end
	if (node_counter == TOTAL_NODE) begin	
		i_load_weight_enable <= 0;
		node_counter <= 'd0;
		#(1000*k) $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
