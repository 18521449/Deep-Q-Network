`timescale 1ns/1ps
module adder_24_input_pipeline_floating_point32
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);
	
	//------------input and output port----------//
	input 						clk;
	input 						rst_n;
	input 						i_valid;
	input		[32-1:0] 		i_data;
	output 		[32-1:0] 		o_data;
	output  					o_valid;
	//-------------------------------------------//

	//----------------------------------buffer------------------//
	reg 		[32-1:0] 		data_buffer [24-1:0];
	//----------------------------------------------------------//
	
	//----------------------------------------------------------//
	wire 	[32-1:0] 					add_data_1	[12-1:0];
	wire 	[32-1:0] 					add_data_2	[6-1:0];
	wire 	[32-1:0] 					add_data_3	[3-1:0];
	wire 	[32-1:0] 					add_data_4;
	reg 	[32-1:0] 					reg_data_1;
	reg 	[6-1:0] 					node_counter;
	//---------------------------------------------------------//
	//---------------------------------------------------------//
	reg 						 		valid_add;
	wire 	[12-1:0]					valid_out_add_1;
	wire 	[6-1:0]						valid_out_add_2;
	wire 	[3-1:0]						valid_out_add_3;
	wire 								valid_out_add_4;
	//---------------------------------------------------------//
	
	initial begin
		node_counter <= 'd0;
	end
	
	genvar i;
	generate
		for (i=0; i<12; i=i+1) begin: add_generate_1
			adder_floating_point32 add // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(valid_add),
					.inA		(data_buffer[i*2 + 0]), 
					.inB		(data_buffer[i*2 + 1]),
					.valid_out	(valid_out_add_1[i]),
					.out_data	(add_data_1[i]));
		end
	endgenerate
	
	genvar k;
	generate
		for (k=0; k<6; k=k+1) begin: add_generate_2
			adder_floating_point32 add // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(&valid_out_add_1),
					.inA		(add_data_1[k*2 + 0]), 
					.inB		(add_data_1[k*2 + 1]),
					.valid_out	(valid_out_add_2[k]),
					.out_data	(add_data_2[k]));
		end
	endgenerate
	
	genvar l;
	generate
		for (l=0; l<3; l=l+1) begin: add_generate_3
			adder_floating_point32 add // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(&valid_out_add_2),
					.inA		(add_data_2[l*2 + 0]), 
					.inB		(add_data_2[l*2 + 1]),
					.valid_out	(valid_out_add_3[l]),
					.out_data	(add_data_3[l]));
		end
	endgenerate
	
	adder_floating_point32 add_generate_4 // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(&valid_out_add_3),
					.inA		(add_data_3[0]), 
					.inB		(add_data_3[1]),
					.valid_out	(valid_out_add_4),
					.out_data	(add_data_4));
	
	adder_floating_point32 add_generate_5 // 7 CLOCK
				(	.clk		(clk),
					.rstn		(rst_n), 
					.valid_in	(valid_out_add_4),
					.inA		(add_data_4), 
					.inB		(reg_data_1),
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
			if (&valid_out_add_3)
				reg_data_1 <= add_data_3[2];
				
			if (i_valid) begin
				data_buffer[node_counter] <= i_data;
				if (node_counter < 23) begin
					node_counter <= node_counter + 1;
					valid_add <= 0;
				end
				else begin
					node_counter <= 'd0;
					valid_add <= 1;
				end
			end
			else valid_add <= 0;
		end
	end
		
endmodule



