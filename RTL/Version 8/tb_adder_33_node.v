`timescale 1ns/1ps
module tb_adder_33_node();

parameter DATA_FILE = "data_1_32.txt";
parameter k =5;

reg 				clk;
reg 				rst_n;
reg 				i_valid;
//reg		[32-1:0] 	i_data;
wire	[32-1:0] 	o_data;
wire	 			o_valid;

reg 	[32-1:0] 	data 	[32-1:0];
reg 	[6-1:0]		counter;
initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	$readmemh(DATA_FILE, data);
	counter <= 0;
	#k#k 	i_valid <= 1;
	#(400*k) $finish;
end

adder_32_input_pipeline_floating_point32 adder
	(	clk,
		rst_n,
		i_valid,
		data[counter],
		o_data,
		o_valid
	);

always @(posedge clk) begin
	if (i_valid) begin
		counter <= counter + 1;
	end
	if (counter == 32-1) begin
		counter <= 'd0;
		i_valid <= 0;
	end
	if (o_valid) begin
		$display("%h", o_data);
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
