module adder_3_input_pipeline_floating_point32
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);
	parameter DATA_WIDTH = 32;
	//------------input and output port----------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input		[32-1:0] 				i_data;
	output 		[32-1:0] 				o_data;
	output  							o_valid;
	//-------------------------------------------//

	//----------------------------buffer------------------------//
	reg 		[32-1:0] 				data_buffer [3-1:0];
	//----------------------------------------------------------//
	//----------------------------------------------------------//
	reg 	[32-1:0] 					reg_data_1;
	reg 	[32-1:0] 					reg_data_2;
	reg 	[32-1:0] 					reg_data_3;
	reg 	[32-1:0] 					reg_data_4;
	reg 	[32-1:0] 					reg_data_5;
	reg 	[32-1:0] 					reg_data_6;
	reg 	[32-1:0] 					reg_data_7;
	wire 	[32-1:0] 					add_data_out;
	reg 	[2-1:0] 					node_counter;
	//---------------------------------------------------------//
	//---------------------------------------------------------//
	reg 						 		valid_add;
	wire								add_valid_out;
	//---------------------------------------------------------//
	
	initial begin
		node_counter <= 'd0;
	end
	
	adder_floating_point32 add_data // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(valid_add),
					.inA		(data_buffer[0]), 
					.inB		(data_buffer[1]),
					.valid_out	(add_valid_out),
					.out_data	(add_data_out));
	
	adder_floating_point32 add_bias // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(add_valid_out),
					.inA		(add_data_out), 
					.inB		(reg_data_7),
					.valid_out	(o_valid),
					.out_data	(o_data));
	
	integer f;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (f=0; f < 33; f=f+1) begin
				data_buffer[f] 	<= 'd0;
			end
			node_counter <= 'd0;
		end
		else begin
			reg_data_2 <= reg_data_1;
			reg_data_3 <= reg_data_2;
			reg_data_4 <= reg_data_3;
			reg_data_5 <= reg_data_4;
			reg_data_6 <= reg_data_5;
			reg_data_7 <= reg_data_6;
			if (node_counter < 2) begin
				if (i_valid) begin
					data_buffer[node_counter] <= i_data;
					node_counter <= node_counter + 1;
				end
				valid_add <= 0;
			end
			else begin
				reg_data_1 <= i_data;
				node_counter <= 'd0;
				valid_add <= 1;
			end
		end
	end
		
endmodule



