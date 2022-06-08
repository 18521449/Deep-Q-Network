`timescale 1ns/1ps
module main_net_update_weight
	#(	parameter DATA_WIDTH 						= 32,
		parameter LAYER_WIDTH 						= 2,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3
	)
	(	clk,
		rst_n,
		i_weight_valid,
		i_weight_layer,
		i_weight_addr,
		i_weight,
		i_error_valid,
		i_error_layer,
		i_error_addr,
		i_error,
		o_weight_valid_request,
		o_weight_layer_request, // [0: input layer], [1: hidden 1], [2: hidden 2], [3: output layer]
		o_weight_addr_request,
		o_new_weight_valid,
		o_new_weight_layer,
		o_new_weight_addr,
		o_new_weight
	);
	
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	localparam TOTAL_WEIGHT = 1251;
	
	//-----------------input and output port-------------//
	input 										clk;
	input 										rst_n;
	input 										i_weight_valid;
	input 		[LAYER_WIDTH-1:0]				i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_weight_addr;
	input		[DATA_WIDTH-1:0]				i_weight;
	input 										i_error_valid;
	input 		[LAYER_WIDTH-1:0]				i_error_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_error_addr;
	input		[DATA_WIDTH-1:0]				i_error;
	output reg									o_weight_valid_request;
	output reg 	[LAYER_WIDTH-1:0]				o_weight_layer_request;
	output reg	[WEIGHT_COUNTER_WIDTH-1:0]		o_weight_addr_request;
	output reg									o_new_weight_valid;
	output reg	[LAYER_WIDTH-1:0]				o_new_weight_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]		o_new_weight_addr;
	output reg	[DATA_WIDTH-1:0]				o_new_weight;
	//-------------------------------------------------------//
	
	//-----------------------------------------------------------------------------------------------------------------//
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_error_hidden_1 		[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_error_hidden_2 		[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_error_outlayer 		[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	//-----------------------------------------------------------------------------------------------------------------//
	reg [DATA_WIDTH-1:0] ram_new_weight_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_new_weight_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_new_weight_outlayer 	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	//-----------------------------------------------------------------------------------------------------------------//
	
	//-------------------------------------------------------//
	reg 		[LAYER_WIDTH-1:0]				layer_reg_0;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_1;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_2;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_3;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_4;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_5;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_6;
	reg 		[LAYER_WIDTH-1:0]				layer_reg_7;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_0;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_1;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_2;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_3;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_4;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_5;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_6;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		addr_reg_7;
	//-------------------------------------------------------//
	
	//-------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]				weight;
	reg 		[DATA_WIDTH-1:0]				error;
	wire 		[DATA_WIDTH-1:0]				new_weight;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]		weight_counter;
	reg 		[LAYER_WIDTH-1:0]				new_weight_layer;
	//-------------------------------------------------------//
	
	//-------------------------------------------------------//
	reg 										update_new_weight;
	reg 										valid_in;
	wire 										valid_out;
	//-------------------------------------------------------//
	
	//-------------------------------------------------------//
	adder_floating_point32 sub_weight // 7 CLOCK
		(	.clk		(clk),	
			.rstn		(rst_n), 
			.valid_in	(valid_in),
			.inA		(weight), 
			.inB		({~error[DATA_WIDTH-1], error[DATA_WIDTH-2:0]}),
			.valid_out	(valid_out),
			.out_data	(new_weight));
	//-------------------------------------------------------//
	
	initial begin
		weight_counter <= 'd0;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			layer_reg_0 <= 'd0;
			addr_reg_0 <= 'd0;
		end
		else begin
			if (i_error_valid) begin
				case (i_error_layer)
					2'b01: 
						begin
							ram_error_hidden_1[i_error_addr] <= i_error;
							o_weight_valid_request 	<= 1;
							o_weight_layer_request 	<= i_error_layer;
							o_weight_addr_request 	<= i_error_addr;
						end
					2'b10: 
						begin
							ram_error_hidden_2[i_error_addr] <= i_error;
							o_weight_valid_request 	<= 1;
							o_weight_layer_request 	<= i_error_layer;
							o_weight_addr_request 	<= i_error_addr;
						end
					2'b11: 
						begin
							ram_error_outlayer[i_error_addr] <= i_error;
							o_weight_valid_request 	<= 1;
							o_weight_layer_request 	<= i_error_layer;
							o_weight_addr_request 	<= i_error_addr;
						end
				endcase
			end
			else o_weight_valid_request <= 0;
			
			if (i_weight_valid) begin
				valid_in <= 1;
				weight <= i_weight;
				case(i_weight_layer)
					2'b01: error <= ram_error_hidden_1[i_weight_addr];
					2'b10: error <= ram_error_hidden_2[i_weight_addr];
					2'b11: error <= ram_error_outlayer[i_weight_addr];						
				endcase
				layer_reg_0 <= i_weight_layer;
				addr_reg_0	<= i_weight_addr;
			end
			else valid_in <= 0;
			
			// pipeline
			layer_reg_1 <= layer_reg_0;
			layer_reg_2 <= layer_reg_1;
			layer_reg_3 <= layer_reg_2;
			layer_reg_4 <= layer_reg_3;
			layer_reg_5 <= layer_reg_4;
			layer_reg_6 <= layer_reg_5;
			layer_reg_7 <= layer_reg_6;
			addr_reg_1 	<= addr_reg_0;
			addr_reg_2 	<= addr_reg_1;
			addr_reg_3 	<= addr_reg_2;
			addr_reg_4 	<= addr_reg_3;
			addr_reg_5 	<= addr_reg_4;
			addr_reg_6 	<= addr_reg_5;
			addr_reg_7 	<= addr_reg_6;
			
			if (valid_out) begin
				case (layer_reg_7)
					2'b01: ram_new_weight_hidden_1[addr_reg_7] <= new_weight;
					2'b10: ram_new_weight_hidden_2[addr_reg_7] <= new_weight;
					2'b11: ram_new_weight_outlayer[addr_reg_7] <= new_weight;
				endcase
				if (weight_counter < TOTAL_WEIGHT-1) begin
					weight_counter <= weight_counter + 1;
				end
				else begin
					weight_counter 		<= 'd0;
					if (weight_counter == TOTAL_WEIGHT-1) begin
						update_new_weight 	<= 1;
						new_weight_layer 	<= 2'b01;
					end
				end
			end
		
			
			if (update_new_weight) begin
				o_new_weight_valid 	<= 1;
				o_new_weight_layer	<= new_weight_layer;
				o_new_weight_addr 	<= weight_counter;
				
				case (new_weight_layer)
					2'b01:
						begin
							if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin
								o_new_weight 		<= ram_new_weight_hidden_1[weight_counter];
								weight_counter 		<= weight_counter + 1;
							end
							else begin
								weight_counter 		<= 'd0;
								o_new_weight 		<= ram_new_weight_hidden_1[weight_counter];
								new_weight_layer 	<= 2'b10;
							end
						end
					2'b10:
						begin
							if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin
								o_new_weight 		<= ram_new_weight_hidden_2[weight_counter];
								weight_counter 		<= weight_counter + 1;
							end
							else begin
								weight_counter 		<= 'd0;
								o_new_weight 		<= ram_new_weight_hidden_2[weight_counter];
								new_weight_layer 	<= 2'b11;
							end
						end
					2'b11:
						begin
							if (weight_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
								o_new_weight 		<= ram_new_weight_outlayer[weight_counter];
								weight_counter 		<= weight_counter + 1;
							end
							else begin
								weight_counter 		<= 'd0;
								o_new_weight 		<= ram_new_weight_outlayer[weight_counter];
								new_weight_layer 	<= 2'b01;
								update_new_weight 	<= 0;
							end
						end
				endcase
			end
			else o_new_weight_valid <= 0;
		end	
	end
endmodule

