`timescale 1ns/1ps
module tb_bp_node_hidden();

	parameter DATA_WIDTH = 32;
	parameter k=5;

	reg 							clk;
	reg 							rst_n;
	reg 							i_valid;
	reg		[DATA_WIDTH-1:0] 		i_delta;
	reg		[DATA_WIDTH-1:0] 		i_weight;
	wire 	[DATA_WIDTH-1:0]		o_data;
	wire	 						o_valid;

	initial begin
		clk <= 0;
		rst_n <= 1;
		i_valid <= 0;
		#k#k 	i_valid <= 1;
				i_delta <= 'h40A66666;
				i_weight <= 'hC059999A;
		#k#k	i_delta <= 'h40133333;
				i_weight <= 'h40A00000;
		#k#k	i_delta <= 'hC08CCCCD;
				i_weight <= 'hC1100000;
		#k#k	i_delta <= 'h40A66666;
				i_weight <= 'hC059999A;
		#k#k	i_delta <= 'h40133333;
				i_weight <= 'h40A00000;
		#k#k	i_delta <= 'hC08CCCCD;
				i_weight <= 'hC1100001;
		#k#k i_valid <= 0;
		#(200*k) $finish;
	end

	back_propagation_node_from_hidden_2_layer
		#(	.DATA_WIDTH		(DATA_WIDTH)
		)
		bp_hidden_layer
		(	.clk			(clk),
			.rst_n			(rst_n),
			.i_valid		(i_valid),
			.i_delta		(i_delta),
			.i_weight		(i_weight),
			.o_data			(o_data),
			.o_valid		(o_valid)
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



	
