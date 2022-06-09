`timescale 1ns/1ps
module tb_ann();

parameter DATA_WIDTH 						= 32;
parameter ACTION_WIDTH						= 2;
parameter LAYER_WIDTH	 					= 2;
parameter NUMBER_OF_INPUT_NODE 				= 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32;
parameter NUMBER_OF_OUTPUT_NODE 			= 3;
parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F; 	//0.002
parameter [DATA_WIDTH-1:0] GAMMA			= 'h3F4CCCCD; 	//0.8
parameter [DATA_WIDTH-1:0] UPDATE_RATE		= 'h3F000000; 	//0.5
parameter DATA_INPUT_FILE 					= "main_ram_input_data.txt";
parameter WEIGHT_HIDDEN_1_FILE 				= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE 				= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE 				= "main_ram_output_weight.txt";
parameter k=5;

parameter DATA_COUNTER_WIDTH 	= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter WEIGHT_COUNTER_WIDTH 	= 11;


//-----------------input and output port-------------//
	reg										clk;
	reg 									rst_n;
	reg 									i_valid;
	reg 		[DATA_WIDTH-1:0]			i_current_state_0;
	reg 		[DATA_WIDTH-1:0]			i_current_state_1;
	reg 		[DATA_WIDTH-1:0]			i_reward;
	reg 		[ACTION_WIDTH-1:0]			i_action;
	reg 		[DATA_WIDTH-1:0]			i_next_state_0;
	reg 		[DATA_WIDTH-1:0]			i_next_state_1;
	reg 									i_done;
	reg 									i_weight_valid;
	reg 		[LAYER_WIDTH-1:0]			i_weight_layer;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_weight_addr;
	reg 		[DATA_WIDTH-1:0]			i_weight;
	reg 									i_update_request;
	wire  									o_action_valid;
	wire  	[ACTION_WIDTH-1:0]				o_action;
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
	#(1257*2*k) i_valid <= 1;
			i_current_state_0 	<= 'hBEF283C2;
			i_current_state_1	<= 'h3B84707D;
			i_reward			<= 'hC1300000;
			i_action			<= 'd1;
			i_next_state_0		<= 'hBEF0A2E8;
			i_next_state_1		<= 'h3B706CE5;
			i_done				<= 0;
	#k#k	i_valid <= 0;
	#(5350*2*k) i_valid <= 1;
			i_current_state_0 	<= 'hBF0BB4B6;
			i_current_state_1	<= 'h3BA54102;
			i_reward			<= 'h40800000;
			i_action			<= 'd1;
			i_next_state_0		<= 'hBF0A5F56;
			i_next_state_1		<= 'h3BAAB017;
			i_done				<= 0;
	#k#k	i_valid <= 0;
	#(5350*2*k) i_valid <= 1;
			i_current_state_0 	<= 'hBED5ABE5;
			i_current_state_1	<= 'h3B190824;
			i_reward			<= 'hC1300000;
			i_action			<= 'd1;
			i_next_state_0		<= 'hBED4E08A;
			i_next_state_1		<= 'h3ACB5AB2;
			i_done				<= 0;
	#k#k	i_valid <= 0;
	#(5350*2*k) $finish;
	// i_update_request <= 1;
	// #k#k 		i_update_request <= 0;
	// #(2000*2*k)	$finish;
end

ann
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.ACTION_WIDTH					(ACTION_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.LEARNING_RATE					(LEARNING_RATE),
		.GAMMA							(GAMMA),
		.UPDATE_RATE					(UPDATE_RATE)
	)
	ann_tb
	(	.clk				(clk),
		.rst_n				(rst_n),
		.i_valid			(i_valid),
		.i_current_state_0	(i_current_state_0),
		.i_current_state_1	(i_current_state_1),
		.i_reward			(i_reward),
		.i_action			(i_action),
		.i_next_state_0		(i_next_state_0),
		.i_next_state_1		(i_next_state_1),
		.i_done				(i_done),
		.i_weight_valid		(i_weight_valid),
		.i_weight_layer		(i_weight_layer),
		.i_weight_addr		(i_weight_addr),
		.i_weight			(i_weight),
		.i_update_request	(i_update_request),
		.o_action			(o_action),
		.o_action_valid		(o_action_valid)
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
					load_data <= 1;
				end
			end
	endcase

	if (load_data) begin
		#k i_valid <= 1;
		i_current_state_0 	<= 'hBEF283C2;
		i_current_state_1	<= 'h3B84707D;
		i_reward			<= 'hC1300000;
		i_action			<= 'd1;
		i_next_state_0		<= 'hBEF0A2E8;
		i_next_state_1		<= 'h3B706CE5;
		i_done				<= 0;
		load_data 			<= 0;
		#k#k i_valid 		<= 0;
	end
	
	// if (o_valid) begin
		// $display("data out: %h", o_data);
	// end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
