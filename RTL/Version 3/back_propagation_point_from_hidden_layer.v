`timescale 1ns/1ps
module back_propagation_point_from_hidden_layer
	#(	parameter DATA_WIDTH = 32,
		parameter ADDRESS_WIDTH = 11,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD
		parameter DELTA_FILE = "main_ram_hidden_1_delta.txt",
		parameter WEIGHT_FILE = "main_ram_output_weight.txt",
		parameter NUMBER_OF_FORWARD_NODE = 3
	)
	(	clk,
		rst_n,
		i_valid,
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
wire valid_out_sub, valid_out_mul, valid_out_temp;
//---------------------------------------------------------//

genvar i;
generate 
	for (i=0; i<NUMBER_OF_FORWARD_NODE; i=i+1) begin: get_delta_generate
		ram
		#(
			.RAM_WIDTH			(DATA_WIDTH),
			.RAM_ADDR_BITS		(ADDRESS_WIDTH),
			.DATA_FILE			(DATA_FILE),
			.ADDRESS			(i)
		)
		ram_delta_gen
		(
			.clk			(clk),
			.rst_n			(rst_n),
			.ram_enable		(i_valid),
			.write_enable	(1'b0),
			.i_data			(),
			.o_data			(delta[i]),
			.o_valid		(valid_out_ram_delta[i])
		);
	end
endgenerate

genvar j;
generate 
	for (j=0; j<NUMBER_OF_FORWARD_NODE+1; j=j+1) begin: get_weight_generate
		ram
		#(
			.RAM_WIDTH			(DATA_WIDTH),
			.RAM_ADDR_BITS		(ADDRESS_WIDTH),
			.DATA_FILE			(WEIGHT_FILE),
			.ADDRESS			(ADDRESS_NODE*(NUMBER_OF_INPUT_NODE+1) + j)
		)
		ram_weight_gen
		(
			.clk			(clk),
			.rst_n			(rst_n),
			.ram_enable		(i_valid),
			.write_enable	(1'b0),
			.i_data			(),
			.o_data			(weight[j]),
			.o_valid		(valid_out_ram_weight[j])
		);
	end
endgenerate

genvar k;
generate
	for (k=0; k<NUMBER_OF_FORWARD_NODE; k=k+1) begin: mul_generate
		multiplier_floating_point32 mul // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(&valid_out_ram_delta&valid_out_ram_weight),
				.inA		(delta[k]), 
				.inB		(weight[k]),
				.valid_out	(valid_out_mul[k]),
				.out_data	(data_out_mul[k]));
	end
endgenerate


//-------------------------------------------------------//
assign result_add_temp[0] = 'd0;
assign valid_add[0] = valid_in_add;
//-------------------------------------------------------//

genvar l;
generate
	for (l=0; l<NUMBER_OF_FORWARD_NODE; l=l+1) begin: add_generate
		adder_floating_point32 add // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_add[l]),
				.inA(result_mul_temp[l]), 
				.inB(result_add_temp[l]),
				.valid_out(valid_add[l+1]),
				.out_data(result_add_temp[l+1]));
	end
endgenerate

multiplier_floating_point32 mul_deactivate // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_add[DATA_WIDTH]),
				.inA(result_add_temp[DATA_WIDTH]), 
				.inB(((data_node[DATA_WIDTH-1]) ? (ALPHA) : 'h3F800000)),
				.valid_out(valid_out_mul_deactivate),
				.out_data(delta_temp));

multiplier_floating_point32 mul_delta // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_out_mul_deactivate),
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
		if (valid_out_mul) begin
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
