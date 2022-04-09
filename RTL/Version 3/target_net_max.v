module target_net_max
	#(	parameter DATA_WIDTH = 32,
		parameter DATA_OUTPUT_FILE = "target_ram_output_data.txt",
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(	clk,
		rst_n,
		i_valid,
		o_data,
		o_valid
	);
	
//--------input and output port-------//
input 							clk;
input 							rst_n;
input 							i_valid;
output 		[DATA_WIDTH-1:0] 	o_data;
output  						o_valid;
//------------------------------------//

//-------------------------------------------------------//
reg 		[DATA_WIDTH-1:0] 	ram 	[NUMBER_OF_OUTPUT_NODE-1:0];
wire 		[DATA_WIDTH-1:0]	i_data_A, i_data_B, i_data_C;
wire 		[DATA_WIDTH-1:0] 	data_out_1, data_out_2, data_mux;
wire 							valid_out_1;
reg valid_in;
//-------------------------------------------------------//

assign i_data_A = ram[0];
assign i_data_B = ram[1];
assign i_data_C = ram[2];

adder_floating_point32 add_1 // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_in),
				.inA(i_data_A), 
				.inB({~i_data_B[DATA_WIDTH-1] ,i_data_B[DATA_WIDTH-2:0]}),
				.valid_out(valid_out_1),
				.out_data(data_out_1));
				
adder_floating_point32 add_2 // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_out_1),
				.inA(i_data_C), 
				.inB({~data_mux[DATA_WIDTH-1], data_mux[DATA_WIDTH-2:0]}),
				.valid_out(o_valid),
				.out_data(data_out_2));

assign data_mux = (data_out_1[DATA_WIDTH-1] ? i_data_B : i_data_A);
assign o_data = (o_valid) ? (data_out_2[DATA_WIDTH-1] ? data_mux : i_data_C) : 'dz;

always @(posedge clk or negedge rst_n) begin
	if (rst_n) begin
		if (i_valid) begin
			$readmemh(DATA_OUTPUT_FILE, ram);
			valid_in <= 1;
		end
		else begin
			valid_in <= 0;
		end
	end
end

endmodule
	