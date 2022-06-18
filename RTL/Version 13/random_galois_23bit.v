`timescale 1ns/1ps
module random_galois_23bit
	(	clk,
		rst_n,
		i_enable,
		o_random_data
	);

	//-------------input and output port--------//
	input 						clk;
	input 						rst_n;
	input 						i_enable;
	output		[22:0] 			o_random_data;
	//----------------------------------------//
	
	wire 	taps, Q_x;
	reg 	[22:0] Q_reg;
	
	initial begin
		Q_reg <= 'd65;
	end
	
	assign o_random_data = Q_reg;
	
	assign taps = Q_reg[0];
	
	assign Q_x = Q_reg[0] ^ Q_reg[5];
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			Q_reg <= 'd65;
		end
		else begin
			if (i_enable) 
				Q_reg <= {taps, Q_reg[22:5], Q_x, Q_reg[3:1]};
		end
	end
	
endmodule
