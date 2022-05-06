`timescale 1ns/1ps
module tb_feed_fw_node();

parameter DATA_WIDTH =32;
parameter NUMBER_OF_INPUT_NODE = 33;
parameter LEAKYRELU_ENABLE = 1'b1;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter DATA_FILE = "data.txt";
parameter WEIGHT_FILE = "weight.txt";
parameter k =5;

reg 							clk;
reg 							rst_n;
reg 							i_valid;
reg 		[DATA_WIDTH-1:0] 	i_weight;
reg		[DATA_WIDTH-1:0] 	i_data;
wire		[DATA_WIDTH-1:0] 	o_data;
wire	 						o_valid;

reg [DATA_WIDTH-1:0] data 		[NUMBER_OF_INPUT_NODE-1:0];
reg [DATA_WIDTH-1:0] weight 	[NUMBER_OF_INPUT_NODE-1:0];
reg [5:0] counter;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	$readmemh(DATA_FILE, data);
	$readmemh(WEIGHT_FILE, weight);
	counter <= 0;
	#k#k 	i_valid <= 1;
			// i_weight <= 32'h40A66666;
			// i_data <= 32'h40500000;
	// #k#k 	i_weight <= 32'h4089999A;
			// i_data <= 32'h40300000;
	// #k#k	i_weight <= 32'h3E19999A;
			// i_data <= 32'h3F800000;
	// #k#k 	i_valid <= 0;
	// #k#k 	i_valid <= 1;
			// i_weight <= 32'h40A66666;
			// i_data <= 32'h40500000;
	// #k#k 	i_weight <= 32'h4089999A;
			// i_data <= 32'h40300000;
	// #k#k	i_weight <= 32'h3E19999A;
			// i_data <= 32'h3F800000;
	// #k#k	i_valid <= 0;
	#(20000*k) $finish;
end

feed_forward_node_for_input_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
		.LEAKYRELU_ENABLE		(LEAKYRELU_ENABLE),
		.ALPHA					(ALPHA)
	)
	feed_forward_node_tb
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_valid				(i_valid),
		.i_weight				(weight[counter]),
		.i_data					(data[counter]),
		.o_data 				(o_data),
		.o_valid				(o_valid)
	);

always @(posedge clk) begin
	if (i_valid) begin
		counter <= counter + 1;
	end
	if (counter == NUMBER_OF_INPUT_NODE-1) begin
		i_valid <= 0;
	end
	if (o_valid) begin
		$display("%h", o_data);
		
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
