`timescale 1ns/1ps
module tb_target_max();

parameter DATA_WIDTH = 32;
parameter DATA_OUTPUT_FILE = "target_ram_output_data.txt";
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter k=5;

reg 														clk;
reg 														rst_n;
reg 														i_valid;
wire	 													o_valid;

initial begin
  clk <= 0;
  rst_n <= 1;
  i_valid <= 0;
  #k#k i_valid <= 1;
  #k#k i_valid <= 0;
  
end

target_net_max 
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.DATA_OUTPUT_FILE		(DATA_OUTPUT_FILE),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
	)
	tb_max
	(	clk,
		rst_n,
		i_valid,
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



	
