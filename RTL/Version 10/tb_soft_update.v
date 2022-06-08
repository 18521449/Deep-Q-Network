`timescale 1ns/1ps
module tb_soft_update();

parameter DATA_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter WEIGHT_HIDDEN_1_FILE 	= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_HIDDEN_2_FILE 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_OUTPUT_FILE 	= "main_ram_output_weight.txt";
parameter [DATA_WIDTH-1:0]	UPDATE_RATE	= 'h3F000000;
parameter k=5;

parameter DATA_COUNTER_WIDTH 	= $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter WEIGHT_COUNTER_WIDTH 	= 11;


//-----------------input and output port-------------//
reg 									clk;
reg 									rst_n;
reg 									i_update_request;
reg 									i_target_weight_valid;
reg 		[LAYER_WIDTH-1:0]			i_target_weight_layer;
reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_target_weight_addr;
reg 		[DATA_WIDTH-1:0]			i_target_weight;
reg 									i_main_weight_valid;
reg 		[LAYER_WIDTH-1:0]			i_main_weight_layer;
reg 		[WEIGHT_COUNTER_WIDTH-1:0]	i_main_weight_addr;
reg 		[DATA_WIDTH-1:0]			i_main_weight;
wire									o_weight_valid_request;
wire 		[LAYER_WIDTH-1:0]			o_weight_layer_request;
wire 		[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr_request;
wire 									o_update_weight_done;
wire 									o_update_weight_valid;
wire		[LAYER_WIDTH-1:0] 			o_update_weight_layer;
wire 		[WEIGHT_COUNTER_WIDTH-1:0]	o_update_weight_addr;
wire 		[DATA_WIDTH-1:0]			o_update_weight;
//----------------------------------------------------//

reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_1	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_hidden_2	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
reg 		[DATA_WIDTH-1:0]			ram_weight_output	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];

initial begin
	$readmemh(WEIGHT_HIDDEN_1_FILE, ram_weight_hidden_1);
	$readmemh(WEIGHT_HIDDEN_2_FILE, ram_weight_hidden_2);
	$readmemh(WEIGHT_OUTPUT_FILE, 	ram_weight_output);
	clk <= 0;
	rst_n <= 1;
	#k#k 	i_update_request <= 1;
	#k#k 	i_update_request <= 0;
	#(4000*2*k) $finish;
end

dqn_soft_update
	#(	.DATA_WIDTH						(DATA_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2 	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE 			(NUMBER_OF_OUTPUT_NODE),
		.UPDATE_RATE					(UPDATE_RATE)
		)
	dqn_soft_update_tb
	(	clk,
		rst_n,
		i_update_request,
		i_target_weight_valid,
		i_target_weight_layer,
		i_target_weight_addr,
		i_target_weight,
		i_main_weight_valid,
		i_main_weight_layer,
		i_main_weight_addr,
		i_main_weight,
		o_weight_valid_request,
		o_weight_layer_request,
		o_weight_addr_request,
		o_update_weight_done,
		o_update_weight_valid,
		o_update_weight_layer,
		o_update_weight_addr,
		o_update_weight
   );

always @(posedge clk) begin
	
	case(o_weight_layer_request)
		2'b01:
			begin
				if (o_weight_valid_request) begin
					i_target_weight_valid 	<= 1;
					i_target_weight_layer 	<= o_weight_layer_request;
					i_target_weight_addr 	<= o_weight_addr_request;
					i_target_weight 		<= ram_weight_hidden_1[o_weight_addr_request];
					
					i_main_weight_valid 	<= 1;
					i_main_weight_layer 	<= o_weight_layer_request;
					i_main_weight_addr 		<= o_weight_addr_request;
					i_main_weight 			<= ram_weight_hidden_1[o_weight_addr_request];
				end
				else begin
					i_target_weight_valid 	<= 0;
					i_main_weight_valid 	<= 0;
				end
			end
		2'b10:
			begin
				if (o_weight_valid_request) begin
					i_target_weight_valid 	<= 1;
					i_target_weight_layer 	<= o_weight_layer_request;
					i_target_weight_addr 	<= o_weight_addr_request;
					i_target_weight 		<= ram_weight_hidden_2[o_weight_addr_request];
					
					i_main_weight_valid 	<= 1;
					i_main_weight_layer 	<= o_weight_layer_request;
					i_main_weight_addr 		<= o_weight_addr_request;
					i_main_weight 			<= ram_weight_hidden_2[o_weight_addr_request];
				end
				else begin
					i_target_weight_valid 	<= 0;
					i_main_weight_valid 	<= 0;
				end
			end
		2'b11:
			begin
				if (o_weight_valid_request) begin
					i_target_weight_valid 	<= 1;
					i_target_weight_layer 	<= o_weight_layer_request;
					i_target_weight_addr 	<= o_weight_addr_request;
					i_target_weight 		<= ram_weight_output[o_weight_addr_request];
					
					i_main_weight_valid 	<= 1;
					i_main_weight_layer 	<= o_weight_layer_request;
					i_main_weight_addr 		<= o_weight_addr_request;
					i_main_weight 			<= ram_weight_output[o_weight_addr_request];
				end
				else begin
					i_target_weight_valid 	<= 0;
					i_main_weight_valid 	<= 0;
				end
			end
	endcase
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
