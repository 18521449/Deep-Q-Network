`timescale 1ns/1ps
module tb_adder_3_node();

parameter k =5;

reg 				clk;
reg 				rst_n;
reg 				i_valid;
reg		[32-1:0] 	i_data;
wire	[32-1:0] 	o_data;
wire	 			o_valid;

initial begin
	clk <= 0;
	rst_n <= 1;
	i_valid <= 0;
	#k#k#k 	i_valid <= 1;
			i_data <= 'h40A00000;
	#k#k 	i_data <= 'h40A00000;
	#k#k 	i_data <= 'h40A00000;
	#k#k	i_data <= 'h40900000;
	#k#k 	i_data <= 'h40200000;
	#k#k 	i_data <= 'h41080000;
	#k#k 	i_valid <= 0;
	#(100*k) $finish;
end

adder_3_input_pipeline_floating_point32 adder
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("%h", o_data);
		
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
