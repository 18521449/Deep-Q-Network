`timescale 1ns/1ps
module tb_target_net();

parameter DATA_WIDTH = 32;
parameter ADDRESS_WIDTH = 11;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter DATA_INPUT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_input_data.txt";
parameter DATA_HIDDEN_1_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_1_data.txt";
parameter DATA_HIDDEN_2_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_2_data.txt";
parameter DATA_OUTPUT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_output_data.txt";
parameter WEIGHT_HIDDEN_1_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_output_weight.txt";
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter k=5;

reg 														clk;
reg 														rst_n;
reg 														i_valid;
wire 	[DATA_WIDTH-1:0]									o_data;
wire	 													o_valid;

initial begin
  clk <= 0;
  rst_n <= 1;
  i_valid <= 0;
  #k#k i_valid <= 1;
  #k#k i_valid <= 0;
  
end

target_net
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ADDRESS_WIDTH					(ADDRESS_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.DATA_INPUT_FILE 				(DATA_INPUT_FILE),
		.DATA_HIDDEN_1_FILE 			(DATA_HIDDEN_1_FILE),
		.DATA_HIDDEN_2_FILE				(DATA_HIDDEN_2_FILE),
		.DATA_OUTPUT_FILE 				(DATA_OUTPUT_FILE),
		.WEIGHT_HIDDEN_1_FILE 			(WEIGHT_HIDDEN_1_FILE),
		.WEIGHT_HIDDEN_2_FILE 			(WEIGHT_HIDDEN_2_FILE),
		.WEIGHT_OUTPUT_FILE 			(WEIGHT_OUTPUT_FILE),
		.ALPHA							(ALPHA)
		)
	target_net_tb
	(	clk,
		rst_n,
		i_valid,
		o_data,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%h", o_data);
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
