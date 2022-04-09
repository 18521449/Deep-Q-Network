`timescale 1ns/1ps
module tb_leakyrelu();

parameter DATA_WIDTH = 32;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter k =5;

reg 												clk;
reg 												rst_n;
reg 												i_valid;
reg 		[DATA_WIDTH-1:0] 						i_data;
wire		[DATA_WIDTH-1:0] 						o_data;
wire 												o_valid;

initial begin
  clk <= 0;
  rst_n <= 1;
  i_valid <= 0;
  #k#k i_valid <= 1;
  i_data <= 'h40900000;
  #k#k i_valid <= 0;
  #k#k i_valid <= 1;
  i_data <= 'hC0B33333;
  
end

leakyrelu_function
	#(	.DATA_WIDTH	(DATA_WIDTH),
		.ALPHA		(ALPHA) //alpha = 0.1
	)
	tb_leakyrelu_funct
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
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



	

