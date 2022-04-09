`timescale 1ns/1ps
module tb_bp_node_upweight();

parameter DATA_WIDTH 				= 32;
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F;
parameter k=5;

reg 							clk;
reg 							rst_n;
reg 	[DATA_WIDTH-1:0]		i_old_weight;
reg 	[DATA_WIDTH-1:0]		i_data_node;
reg 	[DATA_WIDTH-1:0]		i_delta;
reg 							i_valid;
wire	[DATA_WIDTH-1:0]		o_new_weight;		
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k i_valid <= 1;
	i_old_weight 	<= 'h40B66666;
	i_data_node 	<= 'hC0933333;
	i_delta 		<= 'h4059999A;
	#k#k i_valid <= 0;
end

update_weight_point
	#(	.DATA_WIDTH		(DATA_WIDTH),
		.LEARNING_RATE	(LEARNING_RATE)	//0.002
	)
	tb_update_weight
	(	clk,
		rst_n,
		i_valid,
		i_old_weight,
		i_data_node,
		i_delta,
		o_new_weight,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%h", o_new_weight);
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
