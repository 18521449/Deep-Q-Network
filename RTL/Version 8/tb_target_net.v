`timescale 1ns/1ps
module tb_target_net();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter DATA_INPUT_FILE 		= "main_ram_input_data.txt";
parameter WEIGHT_HIDDEN_1_FILE 	= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE 	= "main_ram_output_weight.txt";
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter k=5;


//-----------------input and output port-------------//
reg 									clk;
reg 									rst_n;
reg 									i_data_valid;
reg 		[DATA_WIDTH-1:0]			i_data;
reg 									i_weight_valid;
reg 		[LAYER_WIDTH-1:0]			i_weight_layer;
reg 		[DATA_WIDTH-1:0]			i_weight;
wire		[DATA_WIDTH-1:0]			o_data;
wire	 								o_valid;
//----------------------------------------------------//

reg 		[DATA_WIDTH-1:0]			ram_data_in			[NUMBER_OF_INPUT_NODE-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_1	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_2	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_output	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];

reg 		[5:0]						node_counter;
reg 		[11:0]						weight_counter;
reg										weight_valid;
reg										load_data;

initial begin
	$readmemh(DATA_INPUT_FILE, 		ram_data_in);
	$readmemh(WEIGHT_HIDDEN_1_FILE, ram_weight_hidden_1);
	$readmemh(WEIGHT_HIDDEN_2_FILE, ram_weight_hidden_2);
	$readmemh(WEIGHT_OUTPUT_FILE, 	ram_weight_output);
	clk <= 0;
	rst_n <= 1;
	node_counter <= 'd0;
	weight_counter <= 'd0;
	weight_valid <= 0;
	load_data <= 0;
	i_weight_layer <= 2'b00;
	#k#k weight_valid <= 1;
	#(10000*k) $finish;
end

target_net
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.ALPHA							(ALPHA)
		)
	target_net_tb
	(	.clk			(clk),
		.rst_n			(rst_n),
		.i_data_valid	(i_data_valid),
		.i_data			(i_data),
		.i_weight_valid	(i_weight_valid),
		.i_weight_layer	(i_weight_layer),
		.i_weight		(i_weight),
		.o_data			(o_data),
		.o_valid		(o_valid)
	);

always @(posedge clk) begin
	case(i_weight_layer)
		2'b00:
			begin
				if (weight_valid) begin
					i_weight_layer <= 2'b01;
					node_counter <= 'd0;
					weight_counter <= 'd0;
				end
			end
		2'b01:
			begin
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
					if (weight_counter < NUMBER_OF_INPUT_NODE) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight <= ram_weight_hidden_1[(node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight <= ram_weight_hidden_1[(node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b10;
				end
			end
		2'b10:
			begin
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
					if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight <= ram_weight_hidden_2[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight <= ram_weight_hidden_2[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b11;
				end
			end
		2'b11:
			begin
				if (node_counter < NUMBER_OF_OUTPUT_NODE) begin
					if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
						if (weight_valid) begin
							i_weight_valid <= 1;
							i_weight <= ram_weight_output[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight <= ram_weight_output[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter];
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_counter <='d0;
					node_counter <= 'd0;
					i_weight_valid <= 0;
					i_weight_layer <= 2'b00;
					weight_valid <= 0;
					load_data <= 1;
				end
			end
	endcase

	if (load_data) begin
		#k i_data_valid <= 1;
		i_data <= 'hBFC00000;
		#k#k i_data <= 'h3FA00000;
		load_data <= 0;
		#k#k i_data_valid <= 0;
	end
	
	if (o_valid) begin
		$display("data out: %h", o_data);
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
