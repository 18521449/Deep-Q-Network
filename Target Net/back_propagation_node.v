//module back_propagation_node
//	#(	parameter DATA_WIDTH = 32,
//		parameter NUMBER_OF_OUTPUT_NODE = 3)
//	(	clk,
//		rst_n,
//		i_error,
//		i_weight,
//		i_current_data,
//		i_back_data,
//		i_valid,
//		o_error, 
//		o_valid
//	);
//-----------------input and output port-----------------//
//input 																clk;
//input 																rst_n;
//input 																i_valid;
//input 		[DATA_WIDTH*NUMBER_OF_OUTPUT_NODE-1:0] 	i_error;
//input 		[DATA_WIDTH*NUMBER_OF_OUTPUT_NODE-1:0] 	i_weight;
//input 		[DATA_WIDTH-1:0] 									i_current_data;
//input 		[DATA_WIDTH-1:0] 									i_back_data;
//output reg	[DATA_WIDTH-1:0] 									o_error;
//output reg 															o_valid;
//-------------------------------------------------------//
//
//--------------------------------------------------------------------//
//wire 			[DATA_WIDTH-1:0] 	data_out_mul 		[NUMBER_OF_INPUT_NODE-1:0];
//reg 			[DATA_WIDTH-1:0] 	result_mul_temp	[NUMBER_OF_INPUT_NODE-1:0];
//wire 			[DATA_WIDTH-1:0] 	result_add_temp	[NUMBER_OF_INPUT_NODE:0];
//wire 			[DATA_WIDTH-1:0] 	data_out_temp;
//reg 			[DATA_WIDTH-1:0] 	bias;
//--------------------------------------------------------------------//
//
//---------------------------------------------------------//
//reg valid_in;
//wire [NUMBER_OF_INPUT_NODE-1:0] 	valid_out_mul; 
//wire [NUMBER_OF_INPUT_NODE:0] 	valid_add;
//wire valid_out_temp;
//---------------------------------------------------------//
//
//-------------------------------------------------------//
//assign result_add_temp[0] = 'd0;
//-------------------------------------------------------//
//genvar i;
//generate
//	for (i=0; i<NUMBER_OF_INPUT_NODE; i=i+1) begin: mul_generate
//		multiplier_floating_point32 mul // 7 CLOCK
//			(	.clk(clk),
//				.rstn(rst_n), 
//				.valid_in(i_valid),
//				.inA(i_error[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]), 
//				.inB(i_weight[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
//				.valid_out(valid_out_mul[i]),
//				.out_data(data_out_mul[i]));
//	end
//endgenerate
//
//assign valid_add[0] = &valid_out_mul;
//
//genvar j;
//generate
//	for (j=0; j<NUMBER_OF_INPUT_NODE; j=j+1) begin: add_generate
//		adder_floating_point32 add // 7 CLOCK
//			(	.clk(clk),
//				.rstn(rst_n), 
//				.valid_in(valid_add[j]),
//				.inA(data_out_mul[j]), 
//				.inB(result_add_temp[j]),
//				.valid_out(valid_add[j+1]),
//				.out_data(result_add_temp[j+1]));
//	end
//endgenerate
//
//
//adder_floating_point32 sub_current_data_ // 7 CLOCK  1-current_data
//			(	.clk(clk),
//				.rstn(rst_n), 
//				.valid_in(valid_in),
//				.inA('b00111111100000000000000000000000), // dec = 1
//				.inB(i_current_data),
//				.valid_out(valid_out_sub),
//				.out_data(sub_current_data));
//
//multiplier_floating_point32 mul // 7 CLOCK
//			(	.clk(clk),
//				.rstn(rst_n), 
//				.valid_in(valid_out_sub),
//				.inA(sub_current_data), 
//				.inB(back_data),
//				.valid_out(valid_out_back_data),
//				.out_data(back_data_out);
//
//multiplier_floating_point32 mul // 7 CLOCK
//			(	.clk(clk),
//				.rstn(rst_n), 
//				.valid_in(&valid_out_mul&valid_out_back_data),
//				.inA(result_add_temp[NUMBER_OF_OUTPUT_NODE]), 
//				.inB(back_data_out_reg),
//				.valid_out(valid_out),
//				.out_data(data_out_temp);
//
//integer k;
//always @(posedge clk) begin	
//	if (i_valid) begin
//		bias <= i_bias;
//		valid_in <= 1;
//	end
//	else valid_in <= 0;
//	for (k=0; k<NUMBER_OF_INPUT_NODE; k=k+1) begin
//		if (valid_out_mul[k]) begin
//			result_mul_temp[k] <= data_out_mul[k];
//		end
//	end
//	if (valid_out_temp) begin
//		o_data <= data_out_temp;
//		o_valid <= 1;
//	end 
//	else begin
//		o_data <= 'dz;
//		o_valid <= 0;
//	end
//end
//
//endmodule
