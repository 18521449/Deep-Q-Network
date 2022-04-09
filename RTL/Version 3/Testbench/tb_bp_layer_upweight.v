`timescale 1ns/1ps
module tb_bp_layer_upweight();

parameter DATA_WIDTH 						= 32;
parameter ADDRESS_WIDTH 					= 11;
parameter WEIGHT_FILE 						= "main_ram_output_weight.txt";
parameter DATA_POINT_FILE 					= "main_ram_hidden_2_data.txt";
parameter DELTA_FILE 						= "main_ram_output_delta.txt";
parameter NEW_WEIGHT_FILE					= "main_ram_output_weight_new.txt";
parameter NUMBER_OF_FORWARD_NODE 			= 3;
parameter NUMBER_OF_BACK_NODE				= 32;
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F;
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

update_weight_layer
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.ADDRESS_WIDTH			(ADDRESS_WIDTH),
		.WEIGHT_FILE 			(WEIGHT_FILE),
		.DATA_POINT_FILE 		(DATA_POINT_FILE),
		.DELTA_FILE 			(DELTA_FILE),
		.NEW_WEIGHT_FILE		(NEW_WEIGHT_FILE),
		.NUMBER_OF_FORWARD_NODE (NUMBER_OF_FORWARD_NODE),
		.NUMBER_OF_BACK_NODE	(NUMBER_OF_BACK_NODE),
		.LEARNING_RATE			(LEARNING_RATE)	//0.002
	)
	tb_update_weight_layer
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



	
