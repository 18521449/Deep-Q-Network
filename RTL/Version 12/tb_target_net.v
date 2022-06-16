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
parameter k=5;

parameter DATA_COUNTER_WIDTH 	= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter WEIGHT_COUNTER_WIDTH 	= 11;


//-----------------input and output port-------------//
reg 									clk;
reg 									rst_n;
reg 									i_data_valid;
reg			[DATA_COUNTER_WIDTH-1:0]	i_data_addr;
reg 		[DATA_WIDTH-1:0]			i_data;
reg 									i_weight_valid;
reg 									i_rw_weight_select;
reg 		[LAYER_WIDTH-1:0]			i_weight_layer;
reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
reg 		[DATA_WIDTH-1:0]			i_weight;
reg 									i_load_weight_done;
reg										i_update_request;
wire									o_weight_valid;
wire		[LAYER_WIDTH-1:0]			o_weight_layer;
wire 		[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr;
wire 		[DATA_WIDTH-1:0]			o_weight;
wire	 								o_q_max_valid;
wire		[DATA_WIDTH-1:0]			o_q_max;
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
	#k#k 		weight_valid 		<= 1;
				i_load_weight_done 	<= 0;
	#(4070*2*k) $finish;
end

target_net
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE)
		)
	target_net_tb
	(	.clk				(clk),
		.rst_n				(rst_n),
		.i_data_valid		(i_data_valid),
		.i_data_addr		(i_data_addr),
		.i_data				(i_data),
		.i_weight_valid		(i_weight_valid),
		.i_weight_layer		(i_weight_layer),
		.i_weight_addr		(i_weight_addr),
		.i_weight			(i_weight),
		.i_load_weight_done	(i_load_weight_done),
		.i_update_request	(i_update_request),
		.o_weight_valid		(o_weight_valid),
		.o_weight_layer		(o_weight_layer),
		.o_weight_addr		(o_weight_addr),
		.o_weight			(o_weight),
		.o_q_max			(o_q_max),
		.o_q_max_valid		(o_q_max_valid)
	);

always @(posedge clk) begin
	
	case(i_weight_layer)
		2'b00:
			begin
				i_load_weight_done <= 0;
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
							i_weight_addr <=  (node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter;
							i_weight <= ram_weight_hidden_1[(node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_INPUT_NODE+1))+weight_counter;
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
							i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter;
							i_weight <= ram_weight_hidden_2[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1))+weight_counter;
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
							i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter;
							i_weight <= ram_weight_output[(node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter];
							weight_counter <= weight_counter + 1;
						end
					end
					else begin
						i_weight_valid <= 1;
						i_weight_addr <=  (node_counter*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1))+weight_counter;
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
					i_load_weight_done <= 1;
				end
			end
	endcase

	if (load_data) begin
		#k 		i_data_valid <= 1;
				i_data_addr <= 'd0;
				i_data <= 'hBFC00000;
		#k#k	i_data_addr <= 'd1;
				i_data <= 'h3FA00000;
				load_data <= 0;
		#k#k 	i_data_valid <= 0;
	end
	
	if (o_q_max_valid) begin
		$display("data out: %h", o_q_max);
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
