module feed_forward_node
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_INPUT_NODE = 2)
	(	clk,
		rst_n,
		i_data,
		i_weight,
		i_bias,
		i_valid,
		o_data, 
		o_valid
	);
//-----------------input and output port-----------------//
input 															clk;
input 															rst_n;
input 															i_valid;
input 		[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0] 	i_data;
input 		[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0] 	i_weight;
input 		[DATA_WIDTH-1:0] 								i_bias;
output reg	[DATA_WIDTH-1:0] 								o_data;
output reg 														o_valid;
//-------------------------------------------------------//

//--------------------------------------------------------------------//
wire 			[DATA_WIDTH-1:0] 	data_out_mul 		[NUMBER_OF_INPUT_NODE-1:0];
reg 			[DATA_WIDTH-1:0] 	result_mul_temp	[NUMBER_OF_INPUT_NODE-1:0];
wire 			[DATA_WIDTH-1:0] 	result_add_temp	[NUMBER_OF_INPUT_NODE:0];
wire 			[DATA_WIDTH-1:0] 	data_out_temp;
reg 			[DATA_WIDTH-1:0] 	bias;
//--------------------------------------------------------------------//

//---------------------------------------------------------//
wire [NUMBER_OF_INPUT_NODE-1:0] 	valid_out_mul; 
wire [NUMBER_OF_INPUT_NODE:0] 	valid_add;
wire valid_out_temp;
//---------------------------------------------------------//

//-------------------------------------------------------//
assign result_add_temp[0] = 'd0;
//-------------------------------------------------------//
genvar i;
generate
	for (i=0; i<NUMBER_OF_INPUT_NODE; i=i+1) begin: mul_generate
		multiplier_floating_point32 mul // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(i_valid),
				.inA(i_data[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]), 
				.inB(i_weight[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
				.valid_out(valid_out_mul[i]),
				.out_data(data_out_mul[i]));
	end
endgenerate

assign valid_add[0] = &valid_out_mul;

genvar j;
generate
	for (j=0; j<NUMBER_OF_INPUT_NODE; j=j+1) begin: add_generate
		adder_floating_point32 add // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_add[j]),
				.inA(data_out_mul[j]), 
				.inB(result_add_temp[j]),
				.valid_out(valid_add[j+1]),
				.out_data(result_add_temp[j+1]));
	end
endgenerate

adder_floating_point32 add_bias // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_add[NUMBER_OF_INPUT_NODE]),
				.inA(result_add_temp[NUMBER_OF_INPUT_NODE]), 
				.inB(bias),
				.valid_out(valid_out_temp),
				.out_data(data_out_temp));


integer k;
always @(posedge clk) begin	
	if (i_valid) begin
		bias <= i_bias;
	end
	for (k=0; k<NUMBER_OF_INPUT_NODE; k=k+1) begin
		if (valid_out_mul[k]) begin
			result_mul_temp[k] <= data_out_mul[k];
		end
	end
	if (valid_out_temp) begin
		o_data <= data_out_temp;
		o_valid <= 1;
	end 
	else begin
		o_data <= 'dz;
		o_valid <= 0;
	end
end

endmodule
