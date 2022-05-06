module leakyrelu_function
	#(	parameter DATA_WIDTH =32,
		parameter LEAKYRELU_ENABLE = 1'b1,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD
	)
	(	clk,
		rst_n,
		i_valid,
		i_data,
		o_data,
		o_valid
	);
	//-----------------input and output port-----------------//
	input 										clk;
	input 										rst_n;
	input 										i_valid;
	input 		[DATA_WIDTH-1:0] 				i_data;
	output reg	[DATA_WIDTH-1:0] 				o_data;
	output reg 									o_valid;
	//-------------------------------------------------------//

	//-------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]				data_in;
	wire		[DATA_WIDTH-1:0] 				data_out;
	wire 										valid_out;
	reg 										valid_in;
	//-------------------------------------------------------//
	
	//-------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]				data_in_reg0;
	reg 		[DATA_WIDTH-1:0]				data_in_reg1;
	reg 		[DATA_WIDTH-1:0]				data_in_reg2;
	reg 		[DATA_WIDTH-1:0]				data_in_reg3;
	reg 		[DATA_WIDTH-1:0]				data_in_reg4;
	reg 		[DATA_WIDTH-1:0]				data_in_reg5;
	reg 		[DATA_WIDTH-1:0]				data_in_reg6;
	reg 										valid_in_reg0;
	reg 										valid_in_reg1;
	reg 										valid_in_reg2;
	reg 										valid_in_reg3;
	reg 										valid_in_reg4;
	reg 										valid_in_reg5;
	reg 										valid_in_reg6;
	//-------------------------------------------------------//
	

	multiplier_floating_point32 mul // 7 CLOCK
			(	.clk		(clk),
				.rstn		(rst_n), 
				.valid_in	(i_valid),
				.inA		(i_data), 
				.inB		(ALPHA),
				.valid_out	(valid_out),
				.out_data	(data_out));
		
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_in <= 'd0;
		end
		else begin
			data_in_reg1 <= data_in_reg0;
			data_in_reg2 <= data_in_reg1;
			data_in_reg3 <= data_in_reg2;
			data_in_reg4 <= data_in_reg3;
			data_in_reg5 <= data_in_reg4;
			data_in_reg6 <= data_in_reg5;
			valid_in_reg1 <= valid_in_reg0;
			valid_in_reg2 <= valid_in_reg1;
			valid_in_reg3 <= valid_in_reg2;
			valid_in_reg4 <= valid_in_reg3;
			valid_in_reg5 <= valid_in_reg4;
			valid_in_reg6 <= valid_in_reg5;
			if (i_valid) begin
				data_in_reg0 <= i_data;
				if (i_data[DATA_WIDTH-1]) begin
					valid_in_reg0 <= 1;
				end
				else begin
					valid_in_reg0 <= 0;
				end
			end
			else valid_in_reg0 <= 0;
			if (valid_out) begin
				if (LEAKYRELU_ENABLE) begin
					if (valid_in_reg6) 
						o_data <= data_out;
					else o_data <= data_in_reg6;
				end 
				else o_data <= data_in_reg6;
				o_valid <= 1;
			end
			else begin	
				o_data <= 'dz;
				o_valid <= 0;
			end
		end
	end

endmodule
	