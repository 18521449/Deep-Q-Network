`timescale 1ns/1ps
module tb_target_max();

parameter DATA_WIDTH = 32;
parameter DATA_OUTPUT_FILE = "main_ram_output_data.txt";
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter k=5;

reg 								clk;
reg 								rst_n;
reg 								i_valid;
reg 		[DATA_WIDTH-1:0]		i_data;
wire 		[DATA_WIDTH-1:0]		o_data;
wire	 							o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k 	i_valid <= 1;
			i_data <= 'h42e26279;
	#k#k 	i_data <= 'h42f3282c;
	#k#k 	i_data <= 'h42c617e1;
	#k#k 	i_valid <= 0;
	#(12*k) i_valid <= 1;
			i_data <= 'h42e26279;
	#k#k 	i_data <= 'h42f3282c;
	#k#k 	i_data <= 'h42f40000;
	#k#k 	i_valid <= 0;
	#(100*k) $finish;
end

target_net_max 
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.NUMBER_OF_OUTPUT_NODE	(NUMBER_OF_OUTPUT_NODE)
	)
	tb_target_max
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("max:  %h", o_data);
		$display("Time: %0t", $realtime);
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
