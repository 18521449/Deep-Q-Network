`timescale 1ns/1ps
module tb_bp_node_out();

	parameter DATA_WIDTH = 32;
	parameter k=5;

	reg 							clk;
	reg 							rst_n;
	reg 							i_valid;
	reg		[DATA_WIDTH-1:0] 		i_data_expected;
	reg		[DATA_WIDTH-1:0] 		i_data_node;
	wire 	[DATA_WIDTH-1:0]		o_data;	
	wire	 						o_valid;

	initial begin
		clk <= 0;
		rst_n <= 1;
		i_valid <= 0;
		#k#k 	i_valid <= 1;
				i_data_expected <= 'h40A66666;
				i_data_node <= 'hC059999A;
		#k#k	i_data_expected <= 'h40133333;
				i_data_node <= 'h40A00000;
		#k#k	i_data_expected <= 'hC08CCCCD;
				i_data_node <= 'hC1100000;
		#k#k i_valid <= 0;
		#(40*k) $finish;
	end

	back_propagation_node_from_output_layer
		#(	.DATA_WIDTH				(DATA_WIDTH)
		)
		bp_output_layer
		(	.clk					(clk),
			.rst_n					(rst_n),
			.i_valid				(i_valid),
			.i_data_expected		(i_data_expected),
			.i_data_node			(i_data_node),
			.o_data					(o_data),
			.o_valid				(o_valid)
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



	
