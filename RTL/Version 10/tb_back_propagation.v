`timescale 1ns/1ps
module tb_back_propagation();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F;	//0.002

parameter DATA_FILE_INPUT	 	= "main_ram_input_data.txt";
parameter DATA_FILE_HIDDEN_1 	= "main_ram_hidden_1_data.txt";
parameter DATA_FILE_HIDDEN_2 	= "main_ram_hidden_2_data.txt";
parameter DATA_FILE_OUTPUT 		= "main_ram_output_data.txt";
parameter DATA_FILE_EXPECTED 	= "main_ram_expected.txt";
parameter WEIGHT_FILE_HIDDEN_2 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_FILE_OUTPUT  	= "main_ram_output_weight.txt";
parameter ERROR_FILE 			= "main_ram_error.txt";
parameter DATA_BUFFER_WIDTH 	= NUMBER_OF_INPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;

localparam DATA_EXPECTED_WIDTH		= $clog2(NUMBER_OF_OUTPUT_NODE);
localparam DATA_COUNTER_WIDTH 		= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
localparam WEIGHT_COUNTER_WIDTH 	= 11;

parameter k =5;

	//-----------------input and output port-----------------//
	reg 									clk;
	reg 									rst_n;
	reg 									i_data_valid;
	reg 	[LAYER_WIDTH-1:0]				i_data_layer;
	reg 	[DATA_COUNTER_WIDTH-1:0]		i_data_addr;
	reg		[DATA_WIDTH-1:0]				i_data;
	reg 									i_data_expected_valid;
	reg 	[DATA_EXPECTED_WIDTH-1:0]		i_data_expected_addr;
	reg		[DATA_WIDTH-1:0]				i_data_expected;
	reg 									i_weight_valid;
	reg 	[LAYER_WIDTH-1:0]				i_weight_layer;
	reg 	[WEIGHT_COUNTER_WIDTH-1:0]		i_weight_addr;
	reg		[DATA_WIDTH-1:0]				i_weight;
	wire									o_weight_valid_request;
	wire 	[LAYER_WIDTH-1:0]				o_weight_layer_request;
	wire	[WEIGHT_COUNTER_WIDTH-1:0]		o_weight_addr_request;
	wire									o_error_valid;
	wire	[LAYER_WIDTH-1:0]				o_error_layer;
	wire 	[WEIGHT_COUNTER_WIDTH-1:0]		o_error_addr;
	wire	[DATA_WIDTH-1:0]				o_error;
	//-------------------------------------------------------//


	reg 	[DATA_WIDTH-1:0] 			ram_weight_hidden_2		[32*33-1:0];
	reg 	[DATA_WIDTH-1:0] 			ram_weight_output		[3*33-1:0];
	reg 	[DATA_WIDTH-1:0]			ram_error				[1250:0];

	reg 	[DATA_WIDTH-1:0] 			ram_data_input			[2-1:0];
	reg 	[DATA_WIDTH-1:0] 			ram_data_hidden_1		[32-1:0];
	reg 	[DATA_WIDTH-1:0] 			ram_data_hidden_2		[32-1:0];
	reg 	[DATA_WIDTH-1:0] 			ram_data_output			[3-1:0];
	reg 	[DATA_WIDTH-1:0] 			ram_data_expected		[3-1:0];

	reg 	[5:0]						weight_counter;
	reg 	[6:0]						node_counter;
	reg 								weight_valid;
	reg 								data_valid;
	reg 	[1:0]						data_layer;
	reg 	[11:0]						error_addr;
	
initial begin
	$readmemh(WEIGHT_FILE_HIDDEN_2	, ram_weight_hidden_2);
	$readmemh(WEIGHT_FILE_OUTPUT	, ram_weight_output);
	$readmemh(DATA_FILE_INPUT		, ram_data_input);
	$readmemh(DATA_FILE_HIDDEN_1	, ram_data_hidden_1);
	$readmemh(DATA_FILE_HIDDEN_2	, ram_data_hidden_2);
	$readmemh(DATA_FILE_OUTPUT		, ram_data_output);
	$readmemh(DATA_FILE_EXPECTED	, ram_data_expected);
	clk 			<= 0;
	rst_n 			<= 1;
	weight_counter 	<= 'd0;
	node_counter 	<= 'd0;
	data_layer 		<= 'd0;
	data_valid 		<= 0;
	error_addr 		<= 'd0;
	#k#k 	data_valid <= 1;
	#(6000*k) $writememh (ERROR_FILE, ram_error);
	#k#k $finish;
end

back_propagation	
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE),
		.ALPHA							(ALPHA),
		.LEARNING_RATE					(LEARNING_RATE)
	)
	back_propagation_tb
	(	.clk					(clk),
		.rst_n					(rst_n),	
		.i_data_valid			(i_data_valid),
		.i_data_layer			(i_data_layer),
		.i_data_addr			(i_data_addr),
		.i_data					(i_data),
		.i_data_expected_valid	(i_data_expected_valid),
		.i_data_expected_addr	(i_data_expected_addr),
		.i_data_expected		(i_data_expected),
		.i_weight_valid			(i_weight_valid),
		.i_weight_layer			(i_weight_layer),
		.i_weight_addr			(i_weight_addr),
		.i_weight				(i_weight),
		.o_weight_valid_request	(o_weight_valid_request),
		.o_weight_layer_request	(o_weight_layer_request), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		.o_weight_addr_request	(o_weight_addr_request),
		.o_error_valid			(o_error_valid),
		.o_error_layer			(o_error_layer),
		.o_error_addr			(o_error_addr),
		.o_error				(o_error)	
	);
	
integer i;
always @(posedge clk) begin
	
	if (data_valid) begin
		i_data_valid 	<= 1;
		i_data_layer 	<= data_layer;
		i_data_addr 	<= node_counter;
		
		case (data_layer) 
			2'b00:
				begin
					if (node_counter < NUMBER_OF_INPUT_NODE-1) begin
						node_counter 	<= node_counter + 1;
						i_data			<= ram_data_input[node_counter];
					end
					else begin
						i_data			<= ram_data_input[node_counter];
						node_counter 	<= 'd0;
						data_layer 		<= 2'b01;
					end
				end
			2'b01:
				begin
					if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1-1) begin
						node_counter 	<= node_counter + 1;
						i_data			<= ram_data_hidden_1[node_counter];
					end
					else begin
						i_data			<= ram_data_hidden_1[node_counter];
						node_counter 	<= 'd0;
						data_layer 		<= 2'b10;
					end
				end
			2'b10:
				begin
					if (node_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2-1) begin
						node_counter 	<= node_counter + 1;
						i_data			<= ram_data_hidden_2[node_counter];
					end
					else begin
						i_data			<= ram_data_hidden_2[node_counter];
						node_counter 	<= 'd0;
						data_layer 		<= 2'b11;
					end
				end
			2'b11:
				begin
					if (node_counter < NUMBER_OF_OUTPUT_NODE-1) begin
						node_counter 	<= node_counter + 1;
						i_data			<= ram_data_output[node_counter];
						
						i_data_expected_valid 	<= 1;
						i_data_expected_addr 	<= node_counter;
						i_data_expected 		<= ram_data_expected[node_counter];
					end
					else begin
						i_data			<= ram_data_output[node_counter];
						node_counter 	<= 'd0;
						data_layer 		<= 2'b00;
						data_valid		<= 0;
						
						i_data_expected_valid 	<= 1;
						i_data_expected_addr 	<= node_counter;
						i_data_expected 		<= ram_data_expected[node_counter];
					end
				end
		endcase
	end
	else begin
		i_data_expected_valid <= 0;
		i_data_valid <= 0;
	end
	
	case(o_weight_layer_request)
		2'b11:
			begin
				if (o_weight_valid_request) begin
					i_weight_valid <= 1;
					i_weight_layer <= 2'b11;
					i_weight_addr <= o_weight_addr_request;
					i_weight <= ram_weight_output[o_weight_addr_request];
				end
				else i_weight_valid <= 0;
			end
		2'b10: 
			begin
				if (o_weight_valid_request) begin
					i_weight_valid <= 1;
					i_weight_layer <= 2'b10;
					i_weight_addr <= o_weight_addr_request;
					i_weight <= ram_weight_hidden_2[o_weight_addr_request];
				end
				else i_weight_valid <= 0;
			end
		default: i_weight_valid <= 0;
	endcase
	
	if (o_error_valid) begin
		ram_error[o_error_addr] <= o_error;
		$display("error :%h", o_error);
		$display("addr 	:%d", o_error_addr);
		$display("layer :%b", o_error_layer);
		$display("--------------------------------");
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
