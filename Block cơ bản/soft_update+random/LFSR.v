module lfsr #(parameter MSB=16) ( 
	input 		clk,
	input 		rstn,
	output reg 	[MSB-1:0]out			
);

always @ (posedge clk) begin
	if(!rstn)
		out <= 1;
	else begin
		out[MSB-2:0] <= out[MSB-1:1];
		out[MSB-1]	<= (((out[0]^out[2]) ^ out[3]) ^  out[5]);  
	end
end
endmodule