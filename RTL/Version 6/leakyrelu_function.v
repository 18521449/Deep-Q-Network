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
	input 												clk;
	input 												rst_n;
	input 												i_valid;
	input 		[DATA_WIDTH-1:0] 						i_data;
	output reg	[DATA_WIDTH-1:0] 						o_data;
	output reg 											o_valid;
	//-------------------------------------------------------//

	//-------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]						data_in;
	wire		[DATA_WIDTH-1:0] 						data_out;
	wire 												valid_out;
	reg 												valid_in;
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
			if (i_valid) begin
				data_in <= i_data;
				if (i_data[DATA_WIDTH-1]) begin
					valid_in <= 1;
				end
				else begin
					valid_in <= 0;
				end
			end
			if (valid_out) begin
				if (LEAKYRELU_ENABLE) begin
					if (valid_in) 
						o_data <= data_out;
					else o_data <= data_in;
				end 
				else o_data <= data_in;
				o_valid <= 1;
				valid_in <= 0;
			end
			else begin	
				o_data <= 'dz;
				o_valid <= 0;
			end
		end
	end

endmodule
	