`timescale 1ns/1ps
module tb_random_galois_32bit();

parameter k=5;
parameter OUTPUT_FILE = "random_result.txt";

//-------------input and output port-----------//
reg 						clk;
reg 						rst_n;
reg 						i_enable;
wire		[32-1:0] 		o_random_data;
//---------------------------------------------//

reg 	[32-1:0]	ram [999999:0];
reg 	[20-1:0]	counter;

initial begin
	clk <= 0;
	rst_n <= 0;
	counter <= 0;
	#k#k rst_n <= 1;
	#k#k i_enable <= 1;
end

	
random_floating_point_32bit tb_random_32bit
	(	clk,
		rst_n,
		i_enable,
		o_random_data
	);

always @(o_random_data) begin
	$display("random data: %h", o_random_data);
	$display("random count: %d", counter);
	$display("---------------------");
	ram[counter] <= o_random_data;
	counter <= counter + 1;
	if (counter == 1000000) begin	
		$writememh(OUTPUT_FILE, ram);
		#(4*k) $finish;
	end
end

always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
