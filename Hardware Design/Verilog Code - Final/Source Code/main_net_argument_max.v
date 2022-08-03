module main_net_argument_max
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3,
		parameter DATA_COUNTER_WIDTH = 5,
		parameter ACTION_WIDTH = 2
	)
	(	clk,
		rst_n,
		i_data_valid,
		i_data_addr,
		i_data,
		o_arg_max, // addr of data
		o_arg_max_valid
	);

	//-----------------input and output port--------------//
	input 									clk;
	input 									rst_n;
	input 									i_data_valid;
	input 		[DATA_COUNTER_WIDTH-1:0]	i_data_addr;
	input 		[DATA_WIDTH-1:0] 			i_data;
	output reg	[ACTION_WIDTH-1:0] 			o_arg_max;
	output reg 								o_arg_max_valid;
	//---------------------------------------------------//

	//--------------------------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0] 	data_buffer 	[NUMBER_OF_OUTPUT_NODE-1:0];
	//--------------------------------------------------------------------------//

	//---------------------------------------------//
	reg 		[DATA_WIDTH-1:0] 			max_1;
	wire 		[DATA_WIDTH-1:0] 			data_out_1;
	wire 		[DATA_WIDTH-1:0] 			data_out_2;
	wire 									valid_out_add_1;
	wire 									valid_out_add_2;
	reg 									valid_in_add_1;
	reg 									valid_in_add_2;
	reg 		[DATA_COUNTER_WIDTH-1:0]	node_counter;
	//---------------------------------------------//

	adder_floating_point32 add_1 // 7 CLOCK
				(	.clk			(clk),
					.rstn			(rst_n), 
					.valid_in		(valid_in_add_1),
					.inA			(data_buffer[0]), 
					.inB			({~data_buffer[1][DATA_WIDTH-1] ,data_buffer[1][DATA_WIDTH-2:0]}),
					.valid_out		(valid_out_add_1),
					.out_data		(data_out_1));
					
	adder_floating_point32 add_2 // 7 CLOCK
				(	.clk			(clk),
					.rstn			(rst_n), 
					.valid_in		(valid_in_add_2),
					.inA			(data_buffer[2]), 
					.inB			({~max_1[DATA_WIDTH-1], max_1[DATA_WIDTH-2:0]}),
					.valid_out		(valid_out_add_2),
					.out_data		(data_out_2));

	initial begin
		node_counter <= 'd0;
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
				if (i_data_valid) begin
					data_buffer[i_data_addr] <= i_data;
					node_counter <= node_counter + 1;
				end
				valid_in_add_1 <= 0;
			end
			else begin
				node_counter <= 'd0;
				valid_in_add_1 <= 1;
			end
			
			if (valid_out_add_1) begin
				if (data_out_1[DATA_WIDTH-1]) begin
					max_1 <= data_buffer[1];
					o_arg_max <= 'd1;
				end
				else begin
					max_1 <= data_buffer[0];
					o_arg_max <= 'd0;
				end
				valid_in_add_2 <= 1;
			end
			else valid_in_add_2 <= 0;
			
			if (valid_in_add_2) begin
				if (!data_out_2[DATA_WIDTH-1]) begin
					o_arg_max <= 'd2;
				end
				o_arg_max_valid <= 1;
			end
			else o_arg_max_valid <= 0;
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