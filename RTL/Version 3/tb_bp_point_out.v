`timescale 1ns/1ps
module tb_bp_point_out();

parameter DATA_WIDTH = 32;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter k=5;

reg 							clk;
reg 							rst_n;
reg 							i_valid;
reg		[DATA_WIDTH-1:0] 		i_data_expected;
reg		[DATA_WIDTH-1:0] 		i_data_node;
reg 	[DATA_WIDTH-1:0]		i_data_point;
wire	[DATA_WIDTH-1:0] 		o_delta_point;
wire	[DATA_WIDTH-1:0] 		o_error_point;
wire	 						o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k i_valid <= 1;
	i_data_expected <= 'h40A66666;
	i_data_node <= 'h4059999A;
	i_data_point <= 'hC019999A;
	#k#k i_valid <= 0;
end

back_propagation_point_from_output_layer
	#(	.DATA_WIDTH	(DATA_WIDTH),
		.ALPHA		(ALPHA)
	)
	tb_bp_point_out
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		i_data_point,
		o_delta_point,
		o_error_point,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%h \n%h", o_delta_point, o_error_point);
		#k#k#k#k $finish;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
