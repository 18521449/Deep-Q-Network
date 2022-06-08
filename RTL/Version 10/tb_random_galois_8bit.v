`timescale 1ns/1ps
module tb_random_galois_8bit();

parameter N = 8;
parameter k=5;

//-------------input and output port-----------//
reg 						clk;
reg 						rst_n;
wire		[N:1] 			o_random_data;
//---------------------------------------------//

initial begin
	clk <= 0;
	rst_n <= 0;
	#k#k rst_n <= 1;
	#(200*k) $finish;
end

	
random_galois_8bit tb_random_8bit
	(	clk,
		rst_n,
		o_random_data
	);

always @(o_random_data) 
	$display("random data: %d", o_random_data);

always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
