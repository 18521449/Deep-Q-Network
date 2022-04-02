`timescale 1ns/1ps
module feed_forward_hidden_layer
	#(	parameter DATA_WIDTH = 32,
		parameter ADDRESS_WIDTH = 10,
		parameter DATA_INPUT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_input_data.txt",
		parameter DATA_OUTPUT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_1_data.txt",
		parameter WEIGHT_FILE = "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_1_weight.txt",
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_OUTPUT_NODE = 32,
		parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD,
		parameter LEAKYRELU_ENABLE = 1'b1
		)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
//-----------------input and output port--------------------------------------------//
input 																		clk;
input 																		rst_n;
input 																		i_valid;
output reg 																	o_valid;
//----------------------------------------------------------------------------------//

//---------------------------------------------------------//
wire [DATA_WIDTH-1:0] 				data_out		[NUMBER_OF_OUTPUT_NODE-1:0]; 
reg  [DATA_WIDTH-1:0] 				ram_out			[NUMBER_OF_OUTPUT_NODE-1:0];
wire [NUMBER_OF_OUTPUT_NODE-1:0] 	valid_out;
reg 								write_file;
//---------------------------------------------------------//

genvar i;
generate
	for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin: hidden_generate
		feed_forward_node 
		#( 	.DATA_WIDTH				(DATA_WIDTH),
			.ADDRESS_WIDTH			(ADDRESS_WIDTH),
			.NUMBER_OF_INPUT_NODE	(NUMBER_OF_INPUT_NODE),
			.DATA_FILE				(DATA_INPUT_FILE),
			.WEIGHT_FILE			(WEIGHT_FILE),
			.ADDRESS_NODE			(i),
			.ALPHA					(ALPHA),
			.LEAKYRELU_ENABLE		(LEAKYRELU_ENABLE))
		feed_forward_node_gen
		(	.clk		(clk),
			.rst_n		(rst_n),
			.i_valid	(i_valid),
			.o_data		(data_out[i]),
			.o_valid	(valid_out[i])
		);
	end
endgenerate

integer k;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (k=0; k<NUMBER_OF_OUTPUT_NODE; k=k+1) begin
			ram_out[k] <= 'd0;
		end
	end
	else begin
		for (k=0; k<NUMBER_OF_OUTPUT_NODE; k=k+1) begin
			if (valid_out[k]) begin
				ram_out[k] <= data_out[k];
			end
		end
		if (&valid_out) begin
			#1 $writememh(DATA_OUTPUT_FILE, ram_out);
			write_file <= 1;
		end 
		else begin
			write_file <= 0;
		end
		if (write_file) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end

endmodule
