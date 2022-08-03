`timescale 1ns/1ps
module tb_main_net();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 24;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 24;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter DATA_INPUT_FILE 		= "main_ram_input_data.txt";
parameter WEIGHT_HIDDEN_1_FILE 	= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE 	= "main_ram_output_weight.txt";
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F; //0.002
parameter k=5;

localparam ACTION_WIDTH			= $clog2(NUMBER_OF_OUTPUT_NODE);
parameter DATA_COUNTER_WIDTH 	= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter WEIGHT_COUNTER_WIDTH 	= 11;


//-----------------input and output port-------------//
reg 									clk;
reg 									rst_n;
reg 									i_data_valid;
reg			[DATA_COUNTER_WIDTH-1:0]	i_data_addr;
reg 		[DATA_WIDTH-1:0]			i_data;
reg 									i_loss_value_valid;
reg 		[DATA_WIDTH-1:0]			i_loss_value;
reg 									i_train_action_valid;
reg 		[ACTION_WIDTH-1:0]			i_train_action;
reg 									i_weight_valid;
reg 		[LAYER_WIDTH-1:0]			i_weight_layer;
reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
reg 		[DATA_WIDTH-1:0]			i_weight;
reg 									i_load_weight_done;
reg 									i_train_mode;
reg 									i_update_request;
wire 									o_weight_valid;
wire 		[LAYER_WIDTH-1:0]			o_weight_layer;
wire 		[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr;
wire 		[DATA_WIDTH-1:0]			o_weight;
wire									o_arg_max_valid;
wire		[LAYER_WIDTH-1:0]			o_arg_max;
wire	 								o_main_net_done;
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
	#k#k 	weight_valid <= 1;
			i_load_weight_done <= 0;
			i_train_mode <= 1;
	// #(7000*2*k) i_update_request <= 1;
	// #k#k 		i_update_request <= 0;
	#(20000*2*k) $finish;
end

main_net
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.LEARNING_RATE					(LEARNING_RATE)
		)
	main_net_tb
	(	.clk					(clk),
		.rst_n					(rst_n),
		.i_data_valid			(i_data_valid),
		.i_data_addr			(i_data_addr),
		.i_data					(i_data),
		.i_loss_value_valid		(i_loss_value_valid),
		.i_loss_value			(i_loss_value),
		.i_train_action_valid	(i_train_action_valid),
		.i_train_action			(i_train_action),
		.i_weight_valid			(i_weight_valid),
		.i_weight_layer			(i_weight_layer),
		.i_weight_addr			(i_weight_addr),
		.i_weight				(i_weight),
		.i_load_weight_done		(i_load_weight_done),
		.i_train_mode			(i_train_mode),
		.i_update_request		(i_update_request),
		.o_weight_valid			(o_weight_valid),
		.o_weight_layer			(o_weight_layer),
		.o_weight_addr			(o_weight_addr),
		.o_weight				(o_weight),
		.o_arg_max_valid		(o_arg_max_valid),
		.o_arg_max				(o_arg_max),
		.o_main_net_done		(o_main_net_done)
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
					i_load_weight_done <= 1;
					load_data <= 1;
				end
			end
	endcase

	if (load_data) begin
		#k 			i_data_valid <= 1;
					i_data_addr <= 'd0;
					i_data <= 'hBEF283C2;
		#k#k 		i_data_addr <= 'd1;
					i_data <= 'h3B84707D;
					load_data <= 0;
		#k#k 		i_data_valid <= 0;
		#(300*k) 	i_loss_value_valid <= 1;
					i_loss_value <= 'h428680F9;
					i_train_action_valid <= 1;
					i_train_action <= 'd1;
		#k#k		i_loss_value_valid <= 0;
					i_train_action_valid <= 0;
	end
	
	// if (o_valid) begin
		// $display("data out: %h", o_data);
	// end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
