module target_net_max
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);
	
	//--------input and output port-------//
	input 							clk;
	input 							rst_n;
	input 							i_valid;
	input 		[DATA_WIDTH-1:0] 	i_data;
	output 		[DATA_WIDTH-1:0] 	o_data;
	output  						o_valid;
	//------------------------------------//

	//--------------------------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0] 	data_buffer 	[NUMBER_OF_OUTPUT_NODE-1:0];
	//--------------------------------------------------------------------------//

	//---------------------------------------------//
	wire 		[DATA_WIDTH-1:0]	data_A;
	wire 		[DATA_WIDTH-1:0] 	data_B;
	wire 		[DATA_WIDTH-1:0] 	data_C;
	wire 		[DATA_WIDTH-1:0] 	data_out_1;
	wire 		[DATA_WIDTH-1:0] 	data_out_2;
	wire 		[DATA_WIDTH-1:0] 	data_mux;
	wire 							valid_out_1;
	reg 							valid_in;
	reg [$clog2(NUMBER_OF_OUTPUT_NODE)-1:0]	node_counter;
	//---------------------------------------------//

	assign data_A = data_buffer[0];
	assign data_B = data_buffer[1];
	assign data_C = data_buffer[2];
	assign data_mux = (data_out_1[DATA_WIDTH-1] ? data_B : data_A);
	assign o_data = (o_valid) ? (data_out_2[DATA_WIDTH-1] ? data_mux : data_C) : 'dz;

	adder_floating_point32 add_1 // 7 CLOCK
				(	.clk(clk),
					.rstn(rst_n), 
					.valid_in(valid_in),
					.inA(data_A), 
					.inB({~data_B[DATA_WIDTH-1] ,data_B[DATA_WIDTH-2:0]}),
					.valid_out(valid_out_1),
					.out_data(data_out_1));
					
	adder_floating_point32 add_2 // 7 CLOCK
				(	.clk(clk),
					.rstn(rst_n), 
					.valid_in(valid_out_1),
					.inA(data_C), 
					.inB({~data_mux[DATA_WIDTH-1], data_mux[DATA_WIDTH-2:0]}),
					.valid_out(o_valid),
					.out_data(data_out_2));

	initial begin
		node_counter <= 'd0;
		valid_in <= 'd0;
	end

	integer i;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin
				data_buffer[i] <= 'd0;
			end
			node_counter <= 'd0;
		end
		else begin	
			if (node_counter < NUMBER_OF_OUTPUT_NODE) begin
				if (i_valid) begin
					data_buffer[node_counter] <= i_data;
					node_counter <= node_counter + 1;
				end
				valid_in <= 0;
			end
			else begin
				node_counter <= 'd0;
				valid_in <= 1;
			end
		end
	end

	// function for clog2
	function integer clog2;
	input integer value;
	begin
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	end
	endfunction
endmodule