`timescale 1ns/1ps
module tb_feed_forward();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter [DATA_WIDTH-1:0]  ALPHA = 32'h3DCCCCCD;
parameter WEIGHT_FILE_HIDDEN_1 	= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_FILE_HIDDEN_2 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_FILE_OUTPUT  	= "main_ram_output_weight.txt";
parameter DATA_BUFFER_WIDTH = NUMBER_OF_INPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;
parameter BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter k =5;

reg 									clk;
reg 									rst_n;
reg 									i_data_valid;
reg		[DATA_WIDTH-1:0]				i_data;
reg 									i_weight_valid;
reg		[DATA_WIDTH-1:0]				i_weight;
wire 	[LAYER_WIDTH-1:0]				o_current_layer;
wire									o_weight_valid;
wire	[DATA_WIDTH-1:0]				o_data;
wire 	[BIGEST_WIDTH-1:0]				o_data_addr;
wire									o_data_valid;


reg [DATA_WIDTH-1:0] 			ram_weight_hidden_1		[32*3-1:0];
reg [DATA_WIDTH-1:0] 			ram_weight_hidden_2		[32*33-1:0];
reg [DATA_WIDTH-1:0] 			ram_weight_output		[3*33-1:0];
reg [11-1:0]					weight_counter;
reg 							weight_valid;

initial begin
	$readmemh(WEIGHT_FILE_HIDDEN_1, ram_weight_hidden_1);
	$readmemh(WEIGHT_FILE_HIDDEN_2, ram_weight_hidden_2);
	$readmemh(WEIGHT_FILE_OUTPUT, ram_weight_output);
	clk <= 0;
	rst_n <= 1;
	weight_counter <= 'd0;
	i_data_valid <= 0;
	#k#k 	i_data_valid <= 1;
			i_data <= 32'hBFC00000;
	#k#k 	i_data <= 32'h3FA00000;
	#k#k	i_data_valid <= 0;
end

feed_forward	
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE),
		.ALPHA							(ALPHA)
	)
	feed_forward_tb
	(	.clk				(clk),
		.rst_n				(rst_n),	
		.i_data_valid		(i_data_valid),
		.i_data				(i_data),
		.i_weight_valid		(i_weight_valid),
		.i_weight			(i_weight),
		.o_current_layer	(o_current_layer), // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		.o_weight_valid		(o_weight_valid),
		.o_data_addr		(o_data_addr),
		.o_data				(o_data),
		.o_data_valid		(o_data_valid)
	);

always @(posedge clk) begin
	case(o_current_layer)
		2'b01: 	
			begin	
				if (o_weight_valid) begin	
					weight_valid <= 1;
				end
				if (weight_counter < 32*3) begin
					if (weight_valid) begin
						i_weight <= ram_weight_hidden_1 [weight_counter];
						i_weight_valid <= 1;
						weight_counter <= weight_counter + 1;
					end
					else i_weight_valid <= 0;
				end
				else begin
					weight_valid <= 0;
					i_weight_valid <= 0;
					weight_counter <= 'd0;
				end
			end
		2'b10:
			begin	
				if (o_weight_valid) begin	
					weight_valid <= 1;
				end
				if (weight_counter < 32*33) begin
					if (weight_valid) begin
						i_weight <= ram_weight_hidden_2 [weight_counter];
						i_weight_valid <= 1;
						weight_counter <= weight_counter + 1;
					end
					else i_weight_valid <= 0;
				end
				else begin
					weight_valid <= 0;
					i_weight_valid <= 0;
					weight_counter <= 'd0;
				end
			end
		2'b11:
			begin	
				if (o_weight_valid) begin	
					weight_valid <= 1;
				end
				if (weight_counter < 33*3) begin
					if (weight_valid) begin
						i_weight <= ram_weight_output [weight_counter];
						i_weight_valid <= 1;
						weight_counter <= weight_counter + 1;
					end
					else i_weight_valid <= 0;
				end
				else begin
					weight_valid <= 0;
					i_weight_valid <= 0;
					weight_counter <= 'd0;
					#(1000*k) $finish;
				end
			end
	endcase
	
	if (o_data_valid) begin
		$display("%h", o_data);
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
