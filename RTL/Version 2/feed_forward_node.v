module feed_forward_node
	#(	parameter DATA_WIDTH = 32,
		parameter ADDRESS_WIDTH = 5,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter DATA_FILE = "target_ram_input_data.txt",
		parameter WEIGHT_FILE = "target_ram_hidden_1_weight.txt")
	(	clk,
		rst_n,
		i_valid,
		i_addr,
		i_bias,
		o_data,
		data,
		weight,
		result_0,
		result_1,
		valid_in,
		o_valid
	);
//-----------------input and output port-----------------//
input 														clk;
input 														rst_n;
input 														i_valid;
input 		[ADDRESS_WIDTH-1:0] 							i_addr;
input 		[DATA_WIDTH-1:0] 								i_bias;
output reg	[DATA_WIDTH-1:0] 								o_data;
output reg 													o_valid;
//-------------------------------------------------------//

//--------------------------------------------------------------------//
wire 	[DATA_WIDTH-1:0] 	data_out_mul 	[NUMBER_OF_INPUT_NODE-1:0];
reg 	[DATA_WIDTH-1:0] 	result_mul_temp	[NUMBER_OF_INPUT_NODE-1:0];
wire 	[DATA_WIDTH-1:0] 	result_add_temp	[NUMBER_OF_INPUT_NODE:0];
wire 	[DATA_WIDTH-1:0] 	data_out_temp;

output reg 	[DATA_WIDTH-1:0] 	result_0, result_1;
//--------------------------------------------------------------------//

//--------------------------------------------------------------------//
output 	[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0] 	data;
output 	[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0] 	weight;
reg 	[DATA_WIDTH-1:0] 						bias;
//--------------------------------------------------------------------//

//---------------------------------------------------------//
wire [NUMBER_OF_INPUT_NODE-1:0] 	valid_out_mul; 
wire [NUMBER_OF_INPUT_NODE:0] 		valid_add;
wire valid_out_temp;
output reg valid_in;
//---------------------------------------------------------//

	ram
	#(
		.RAM_WIDTH			(DATA_WIDTH*NUMBER_OF_INPUT_NODE),
		.RAM_ADDR_BITS		(ADDRESS_WIDTH),
		.DATA_FILE			(DATA_FILE)
	)
	ram_data
	(
		.clk			(clk),
		.rst_n			(rst_n),
		.ram_enable		(i_valid),
		.write_enable	(0),
		.addr			(i_addr),
		.i_data			(),
		.o_data			(data)
	);
	ram
	#(
		.RAM_WIDTH			(DATA_WIDTH*NUMBER_OF_INPUT_NODE),
		.RAM_ADDR_BITS		(ADDRESS_WIDTH),
		.DATA_FILE			(WEIGHT_FILE)
	)
	ram_weight_gen
	(
		.clk			(clk),
		.rst_n			(rst_n),
		.ram_enable		(i_valid),
		.write_enable	(0),
		.addr			(i_addr),
		.i_data			(),
		.o_data			(weight)
	);

//-------------------------------------------------------//
assign result_add_temp[0] = 'd0;
//-------------------------------------------------------//

genvar i;
generate
	for (i=0; i<NUMBER_OF_INPUT_NODE; i=i+1) begin: mul_generate
		multiplier_floating_point32 mul // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_in),
				.inA(data[(DATA_WIDTH*(i+1)-1):(DATA_WIDTH*i)]), 
				.inB(weight[(DATA_WIDTH*(i+1)-1):(DATA_WIDTH*i)]),
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
		.out_data(data_out_temp)
	);


integer k;
always @(posedge clk or negedge rst_n) begin	
	if (rst_n) begin
		if (i_valid) begin
			bias <= i_bias;
			valid_in <= 1;
		end
		else begin
			valid_in <= 0;
		end
		
		if (valid_out_mul[0]) begin
			result_0 <= data_out_mul[0];
		end
		if (valid_out_mul[1]) begin
			result_1 <= data_out_mul[1];
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
end

endmodule
