`timescale 1ns/1ps
module random_galois_8bit
	(	clk,
		rst_n,
		i_enable,
		o_random_data
	);

	//-------------input and output port--------//
	input 						clk;
	input 						rst_n;
	input 						i_enable;
	output		[8:1] 			o_random_data;
	//----------------------------------------//
	
	wire 	taps;
	wire 	[8:1] Q_x;
	reg 	[8:1] Q_next, Q_reg;

	initial begin
		Q_reg <= 'd50;
	end
	
	assign o_random_data = Q_reg;
	
	assign taps = Q_reg[1];
	
	assign Q_x[4] = Q_reg[1] ^ Q_reg[5];
	assign Q_x[3] = Q_reg[1] ^ Q_reg[4];
	assign Q_x[2] = Q_reg[1] ^ Q_reg[3];
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			Q_reg <= 'd50;
		end
		else begin
			if (i_enable) 
				Q_reg <= Q_next;
		end
	end
	
	always @(taps or Q_reg) begin
		Q_next <= {taps, Q_reg[8], Q_reg[7], Q_reg[6], Q_reg[5], Q_x[4], Q_x[3], Q_x[2]};
	end
	
endmodule