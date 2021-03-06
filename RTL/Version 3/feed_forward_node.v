module feed_forward_node
	#(	parameter DATA_WIDTH = 32,
		parameter ADDRESS_WIDTH = 5,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter DATA_FILE = "target_ram_input_data.txt",
		parameter WEIGHT_FILE = "target_ram_hidden_1_weight.txt",
		parameter ADDRESS_NODE = 0,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD,
		parameter LEAKYRELU_ENABLE = 1'b1)
	(	clk,
		rst_n,
		i_valid,
		i_data,
		i_weight,
		o_data,
		o_valid
	);
//-----------------input and output port-----------------//
input 							clk;
input 							rst_n;
input 							i_valid;
input		[DATA_WIDTH-1:0] 	data;
input 		[DATA_WIDTH-1:0] 	weight;
output reg	[DATA_WIDTH-1:0] 	o_data;
output reg 						o_valid;
//-------------------------------------------------------//

//--------------------------------------------------------------------//
wire 	[DATA_WIDTH-1:0] 	data_out_mul 	[NUMBER_OF_INPUT_NODE-1:0];
reg 	[DATA_WIDTH-1:0] 	result_mul_temp	[NUMBER_OF_INPUT_NODE-1:0];
wire 	[DATA_WIDTH-1:0] 	result_add_temp	[NUMBER_OF_INPUT_NODE:0];
wire 	[DATA_WIDTH-1:0] 	data_out_bias;
wire 	[DATA_WIDTH-1:0] 	data_out_temp;
//--------------------------------------------------------------------//

//--------------------------------------------------------------------//
reg 	[DATA_WIDTH-1:0] 	bias;
//--------------------------------------------------------------------//

//---------------------------------------------------------//
reg [$clog2(NUMBER_OF_INPUT_NODE)-1:0] counter;

wire [NUMBER_OF_INPUT_NODE-1:0] 	valid_out_mul; 
wire [NUMBER_OF_INPUT_NODE:0] 		valid_add;
wire valid_out_bias;
wire valid_out_temp;
reg  valid_in_add;
wire [NUMBER_OF_INPUT_NODE-1:0]		valid_out_ram_data; 
wire [NUMBER_OF_INPUT_NODE-1:0]		valid_out_ram_weight;
//---------------------------------------------------------//

//-------------------------------------------------------//
assign result_add_temp[0] = 'd0;
//-------------------------------------------------------//

initial 
	counter <= 0;

genvar k;
generate
	for (k=0; k<NUMBER_OF_INPUT_NODE; k=k+1) begin: mul_generate
		multiplier_floating_point32 mul // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(&valid_out_ram_data&valid_out_ram_weight),
				.inA(data[k]), 
				.inB(weight[k]),
				.valid_out(valid_out_mul[k]),
				.out_data(data_out_mul[k]));
	end
endgenerate

assign valid_add[0] = valid_in_add;

genvar l;
generate
	for (l=0; l<NUMBER_OF_INPUT_NODE; l=l+1) begin: add_generate
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

adder_floating_point32 add_bias // 7 CLOCK
	(	.clk(clk),
		.rstn(rst_n), 
		.valid_in(valid_add[NUMBER_OF_INPUT_NODE]),
		.inA(result_add_temp[NUMBER_OF_INPUT_NODE]), 
		.inB(bias),
		.valid_out(valid_out_bias),
		.out_data(data_out_bias)
	);

leakyrelu_function
	#(	.DATA_WIDTH	(DATA_WIDTH),
		.ALPHA		(ALPHA) //alpha = 0.1
	)
	leakyrelu_funct
	(	.clk		(clk),
		.rst_n		(rst_n),
		.i_valid	(valid_out_bias),
		.i_data		(data_out_bias),
		.o_data		(data_out_temp),
		.o_valid	(valid_out_temp)
	);


integer g;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter <= 0;
	end
	else begin
		if (i_valid) begin
			counter <= counter + 1'b1;
			data[counter-1] <= i_data;
			weight[counter-1] <= i_weight;
		end
		else begin
			if (counter == ) begin
				
			
		if (&valid_out_ram_weight) begin
			bias <= weight[NUMBER_OF_INPUT_NODE];
		end
		if (&valid_out_mul)
			valid_in_add = 1;
		else valid_in_add = 0;
		for (g=0; g<NUMBER_OF_INPUT_NODE; g=g+1) begin
			if (valid_out_mul[g]) begin
				result_mul_temp[g] <= data_out_mul[g];
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
