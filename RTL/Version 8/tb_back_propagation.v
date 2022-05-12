`timescale 1ns/1ps
module tb_back_propagation();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter DATA_FILE_HIDDEN_1 	= "main_ram_hidden_1_data.txt";
parameter DATA_FILE_HIDDEN_2 	= "main_ram_hidden_2_data.txt";
parameter DATA_FILE_OUTPUT 		= "main_ram_output_data.txt";
parameter DATA_FILE_EXPECTED 	= "main_ram_expected.txt";
parameter WEIGHT_FILE_HIDDEN_2 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_FILE_OUTPUT  	= "main_ram_output_weight.txt";
parameter DATA_BUFFER_WIDTH = NUMBER_OF_INPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;
parameter BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter k =5;

reg 								clk;
reg 								rst_n;
reg 								i_data_valid;
reg		[DATA_WIDTH-1:0]			i_data_expected;
reg		[DATA_WIDTH-1:0]			i_data_node;
reg 								i_weight_valid;
reg		[DATA_WIDTH-1:0]			i_weight;
wire 	[LAYER_WIDTH-1:0]			o_current_layer;
wire								o_weight_valid;
wire	[DATA_WIDTH-1:0]			o_delta;
wire 	[BIGEST_WIDTH-1:0]			o_delta_addr;
wire								o_delta_valid;


reg 	[DATA_WIDTH-1:0] 			ram_weight_hidden_2		[32*33-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_weight_output		[3*33-1:0];

reg 	[DATA_WIDTH-1:0] 			ram_data_hidden_1		[32-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_data_hidden_2		[32-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_data_output			[3-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_data_expected		[3-1:0];

reg 	[5:0]						weight_counter;
reg 	[6:0]						node_counter;
reg 								weight_valid;
reg 								data_valid;

initial begin
	$readmemh(WEIGHT_FILE_HIDDEN_2	, ram_weight_hidden_2);
	$readmemh(WEIGHT_FILE_OUTPUT	, ram_weight_output);
	$readmemh(DATA_FILE_HIDDEN_1	, ram_data_hidden_1);
	$readmemh(DATA_FILE_HIDDEN_2	, ram_data_hidden_2);
	$readmemh(DATA_FILE_OUTPUT		, ram_data_output);
	$readmemh(DATA_FILE_EXPECTED	, ram_data_expected);
	clk 			<= 0;
	rst_n 			<= 1;
	weight_counter 	<= 'd0;
	node_counter 	<= 'd0;
	data_valid 		<= 0;
	#k#k 	data_valid <= 1;
	#(2700*k) $finish;
end

back_propagation	
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE),
		.ALPHA							(ALPHA)
	)
	back_propagation_tb
	(	.clk				(clk),
		.rst_n				(rst_n),	
		.i_data_valid		(i_data_valid),
		.i_data_expected	(i_data_expected),
		.i_data_node		(i_data_node),
		.i_weight_valid		(i_weight_valid),
		.i_weight			(i_weight),
		.o_current_layer	(o_current_layer), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		.o_weight_valid		(o_weight_valid),
		.o_delta_addr		(o_delta_addr),
		.o_delta			(o_delta),
		.o_delta_valid		(o_delta_valid)
	);

always @(posedge clk) begin
	
	if (data_valid) begin
		if (node_counter < NUMBER_OF_OUTPUT_NODE) begin
			i_data_valid <= 1;
			i_data_expected <= ram_data_expected[node_counter];
			i_data_node		<= ram_data_output[node_counter];
			node_counter <= node_counter + 1;
		end
		else begin
			if (node_counter < NUMBER_OF_OUTPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
				i_data_valid <= 1;
				i_data_expected <= 'dz;
				i_data_node <= ram_data_hidden_2[node_counter - NUMBER_OF_OUTPUT_NODE];
				node_counter <= node_counter + 1;
			end
			else begin
				if (node_counter < NUMBER_OF_OUTPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
					i_data_valid <= 1;
					i_data_expected <= 'dz;
					i_data_node <= ram_data_hidden_1[node_counter - NUMBER_OF_OUTPUT_NODE - NUMBER_OF_HIDDEN_NODE_LAYER_2];
					node_counter <= node_counter + 1;
				end
				else begin
					data_valid 		<= 0;
					node_counter 	<= 'd0;
					i_data_valid 	<= 0;
				end
			end
		end
	end
	
	case(o_current_layer)
		
		2'b10:
			begin	
				if (o_weight_valid) begin	
					weight_valid <= 1;
				end
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2) begin
					if (weight_counter < 2) begin
						if (weight_valid) begin
							i_weight <= ram_weight_output [weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)+node_counter];
							i_weight_valid <= 1;
							weight_counter <= weight_counter + 1;
						end
						else i_weight_valid <= 0;
					end
					else begin
						i_weight <= ram_weight_output [weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)+node_counter];
						i_weight_valid <= 1;
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_valid <= 0;
					i_weight_valid <= 0;
					weight_counter <= 'd0;
					node_counter <= 'd0;
				end
			end
		2'b01: 	
			begin	
				if (o_weight_valid) begin	
					weight_valid <= 1;
				end
				if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1) begin
					if (weight_counter < 31) begin
						if (weight_valid) begin
							i_weight <= ram_weight_hidden_2 [weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)+node_counter];
							i_weight_valid <= 1;
							weight_counter <= weight_counter + 1;
						end
						else i_weight_valid <= 0;
					end
					else begin
						i_weight <= ram_weight_hidden_2 [weight_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)+node_counter];
						i_weight_valid <= 1;
						weight_counter <= 'd0;
						node_counter <= node_counter + 1;
					end
				end
				else begin
					weight_valid <= 0;
					i_weight_valid <= 0;
					weight_counter <= 'd0;
					node_counter <= 'd0;
				end
			end
	endcase
	
	if (o_delta_valid) begin
		$display("delta :%h", o_delta);
		$display("addr 	:%d", o_delta_addr);
		$display("--------------------------------");
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
