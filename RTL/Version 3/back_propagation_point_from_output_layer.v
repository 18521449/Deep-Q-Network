`timescale 1ns/1ps
module back_propagation_point_from_output_layer
	#(	parameter DATA_WIDTH = 32,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD
		
	)
	(	clk,
		rst_n,
		i_valid,
		i_data_expected,
		i_data_node,
		i_data_point,
		o_delta_point,
		o_error_point,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
input		[DATA_WIDTH-1:0] 		i_data_expected;
input		[DATA_WIDTH-1:0] 		i_data_node;
input 		[DATA_WIDTH-1:0]		i_data_point;
output reg	[DATA_WIDTH-1:0] 		o_delta_point;
output reg	[DATA_WIDTH-1:0] 		o_error_point;
output reg 							o_valid;
//---------------------------------------------------//

//---------------------------------------------------//
wire 		[DATA_WIDTH-1:0] 		sub;
wire 		[DATA_WIDTH-1:0] 		delta_temp;
reg 		[DATA_WIDTH-1:0] 		delta_reg;
wire 		[DATA_WIDTH-1:0] 		error_temp;
reg 		[DATA_WIDTH-1:0] 		data_node;
reg 		[DATA_WIDTH-1:0] 		data_point;
//---------------------------------------------------//

//---------------------------------------------------------//
wire valid_out_sub, valid_out_temp;
//---------------------------------------------------------//

adder_floating_point32 sub_expected // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(i_valid),
				.inA(i_data_node), 
				.inB({(~i_data_expected[DATA_WIDTH-1]), i_data_expected[DATA_WIDTH-2:0]}),
				.valid_out(valid_out_sub),
				.out_data(delta_temp));

multiplier_floating_point32 mul_delta // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_out_sub),
				.inA(data_point), 
				.inB(delta_temp),
				.valid_out(valid_out_temp),
				.out_data(error_temp));

integer k;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		delta_reg <= 'd0;
		data_node <= 'd0;
		data_point <= 'd0;
	end
	else begin
		if (i_valid) begin
			data_node <= i_data_node;
			data_point <= i_data_point;
		end
		if (valid_out_sub) begin
			delta_reg <= delta_temp; 
		end
		if (valid_out_temp) begin
			o_error_point <= error_temp;
			o_delta_point <= delta_reg;
			o_valid <= 1;
		end 
		else begin
			o_error_point <= 'dz;
			o_delta_point <= 'dz;
			o_valid <= 0;
		end
	end
end

endmodule
