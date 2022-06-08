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
	output		[23:1] 			o_random_data;
	//----------------------------------------//
	
	wire 	taps, Q_x;
	reg 	[23:1] Q_next, Q_reg;
	
	initial begin
		Q_reg <= 'd65;
	end
	
	assign o_random_data = Q_reg;
	
	assign taps = Q_reg[1];
	
	assign Q_x = Q_reg[1] ^ Q_reg[6];
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			Q_reg <= 'd65;
		end
		else begin
			if (i_enable) 
				Q_reg <= Q_next;
		end
	end
	
	always @(taps or Q_reg) begin
		Q_next <= {taps, Q_reg[23:6], Q_x, Q_reg[4:2]};
	end
	
endmodule