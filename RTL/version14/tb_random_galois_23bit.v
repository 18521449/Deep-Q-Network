`timescale 1ns/1ps
module tb_random_galois_23bit();

parameter k=5;

//-------------input and output port-----------//
reg 						clk;
reg 						rst_n;
reg 						i_enable;
wire		[23:1] 			o_random_data;
//---------------------------------------------//

initial begin
	clk <= 0;
	rst_n <= 0;
	#k#k rst_n <= 1;
	#k#k i_enable <= 1;
	#(20*k) i_enable <= 0;
	#(20*k) i_enable <= 1;
	#(100*k) $finish;
end

	
random_galois_23bit tb_random_23bit
	(	clk,
		rst_n,
		i_enable,
		o_random_data
	);

always @(o_random_data) 
	$display("random data: %d", o_random_data);

always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
