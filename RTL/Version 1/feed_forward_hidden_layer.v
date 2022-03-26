module feed_forward_hidden_layer
	#(	parameter DATA_WIDTH = 32,
		parameter NUMBER_OF_INPUT_NODE = 32,
		parameter NUMBER_OF_HIDDEN_NODE = 32)
	(	clk,
		rst_n,
		i_data,
		i_weight,
		i_valid,
		i_bias,
		o_data, 
		o_valid
	);
//-----------------input and output port--------------------------------------------//
input 																							clk;
input 																							rst_n;
input 																							i_valid;
input 		[DATA_WIDTH*NUMBER_OF_INPUT_NODE-1:0] 									i_data;	
input 		[DATA_WIDTH*NUMBER_OF_INPUT_NODE*NUMBER_OF_HIDDEN_NODE-1:0] 	i_weight;
input 		[DATA_WIDTH-1:0] 																i_bias;
output 		[DATA_WIDTH*NUMBER_OF_HIDDEN_NODE-1:0] 								o_data;
output reg 																						o_valid;
//----------------------------------------------------------------------------------//

//---------------------------------------------------------//
wire [NUMBER_OF_HIDDEN_NODE-1:0] valid_out; 
//---------------------------------------------------------//

genvar i;
generate
	for (i=0; i<NUMBER_OF_HIDDEN_NODE; i=i+1) begin: hidden_generate
		feed_forward_node 
		#( .DATA_WIDTH(DATA_WIDTH),
			.NUMBER_OF_INPUT_NODE(NUMBER_OF_INPUT_NODE))
		feed_forward_node_gen
		(	.clk		(clk),
			.rst_n	(rst_n),
			.i_data 	(i_data),
			.i_weight(i_weight[DATA_WIDTH*NUMBER_OF_INPUT_NODE*(i+1)-1:DATA_WIDTH*NUMBER_OF_INPUT_NODE*i]),
			.i_bias	(i_bias[i]),
			.i_valid	(i_valid),
			.o_data	(o_data[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
			.o_valid	(valid_out[i])
		);
	end
endgenerate


always @(posedge clk) begin
	if (&valid_out) begin
		o_valid <= 1;
	end 
	else begin
		o_valid <= 0;
	end
end

endmodule
