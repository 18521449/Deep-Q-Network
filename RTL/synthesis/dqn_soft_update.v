module dqn_soft_update 
	#(	parameter DATA_WIDTH 					= 32,
		parameter LAYER_WIDTH	 				= 2,
		parameter NUMBER_OF_INPUT_NODE 			= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 		= 3,
		parameter [DATA_WIDTH-1:0]	UPDATE_RATE	= 'h3F000000
	)
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
   
   localparam WEIGHT_COUNTER_WIDTH 	= 11;
   
   //-----------------input and output port-------------//
	input 									clk;
	input 									rst_n;
	input 									i_update_request;
	input 									i_target_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_target_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_target_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_target_weight;
	input 									i_main_weight_valid;
	input 		[LAYER_WIDTH-1:0]			i_main_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]	i_main_weight_addr;
	input 		[DATA_WIDTH-1:0]			i_main_weight;
	output reg								o_weight_valid_request;
	output reg 	[LAYER_WIDTH-1:0]			o_weight_layer_request;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]	o_weight_addr_request;
	output reg 								o_update_weight_done;
	output reg 								o_update_weight_valid;
	output reg	[LAYER_WIDTH-1:0] 			o_update_weight_layer;
	output reg 	[WEIGHT_COUNTER_WIDTH-1:0]	o_update_weight_addr;
	output reg 	[DATA_WIDTH-1:0]			o_update_weight;
	//---------------------------------------------------//
   
   //-----------------------------------------------------------------------------------------------------------------//
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_update_weight_hidden1 		[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_update_weight_hidden2 		[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_update_weight_outlayer 	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	//-----------------------------------------------------------------------------------------------------------------//
	
   
	//--------------------------------------------------------------//
	wire 									valid_mul_target;
	wire 									valid_mul_main;
	wire 		[DATA_WIDTH-1:0]			data_mul_target;
	wire 		[DATA_WIDTH-1:0]			data_mul_main;
	wire 									update_weight_valid;
	wire 		[DATA_WIDTH-1:0]			update_weight;
	reg										read_weight_mode;
	reg										write_weight_mode;
	reg 		[LAYER_WIDTH-1:0]			weight_layer	[15:0];
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	weight_addr		[15:0];
	reg 		[LAYER_WIDTH-1:0]			weight_layer_counter;
	reg 		[WEIGHT_COUNTER_WIDTH-1:0]	weight_addr_counter;
	//--------------------------------------------------------------//
    
	//Qtarget*0.5
	multiplier_floating_point32 mul_target // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(i_target_weight_valid & i_main_weight_valid),
			.inA			(i_target_weight), 
			.inB			(UPDATE_RATE),
			.valid_out		(valid_mul_target),
			.out_data		(data_mul_target));
			
	//Qmain*0.5
	multiplier_floating_point32 mul_main // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(i_target_weight_valid & i_main_weight_valid),
			.inA			(i_main_weight), 
			.inB			(UPDATE_RATE),
			.valid_out		(valid_mul_main),
			.out_data		(data_mul_main));
		
	//Qtarget*0.5 + Qmain*0.5	
   adder_floating_point32 add_1 // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(valid_mul_main & valid_mul_target),
			.inA			(data_mul_target), 
			.inB			(data_mul_main),
			.valid_out		(update_weight_valid),
			.out_data		(update_weight));
			
	integer i; 
	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			read_weight_mode		<= 0;
			write_weight_mode 		<= 0;
			weight_addr_counter 	<= 'd0;
			weight_layer_counter	<= 'd0;
		end 
		else begin 
			
			if (i_update_request) begin
				read_weight_mode 		<= 1;
				write_weight_mode 		<= 0;
				weight_addr_counter 	<= 'd0;
				weight_layer_counter 	<= 'd0;
			end

			if (read_weight_mode) begin
				o_weight_layer_request 	<= weight_layer_counter;
				o_weight_addr_request 	<= weight_addr_counter;
				case(weight_layer_counter)
					2'b01:
						begin
							o_weight_valid_request 	<= 1;
							if (weight_addr_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b10;
							end
						end
					2'b10:
						begin
							o_weight_valid_request 	<= 1;
							if (weight_addr_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b11;
							end
						end
					2'b11:
						begin
							if (weight_addr_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
								o_weight_valid_request 	<= 1;
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b01;
								read_weight_mode		<= 0;
								o_weight_valid_request 	<= 0;
							end
						end
				endcase
			end
			else o_weight_valid_request <= 0;
			
			if (i_target_weight_valid & i_main_weight_valid) begin
				if (i_target_weight_layer == i_main_weight_layer) begin
					if (i_target_weight_addr == i_main_weight_addr) begin
						weight_layer[0] 	<= i_target_weight_layer;
						weight_addr	[0]		<= i_target_weight_addr;
					end
				end
			end
			
			for (i=0; i<15; i=i+1) begin
				weight_layer[i+1] <= weight_layer[i];
				weight_addr	[i+1] <= weight_addr[i];
			end
			
			if (update_weight_valid) begin
				case (weight_layer[15])
					2'b01: ram_update_weight_hidden1	[weight_addr[15]] <= update_weight;
					2'b10: ram_update_weight_hidden2	[weight_addr[15]] <= update_weight;
					2'b11: ram_update_weight_outlayer	[weight_addr[15]] <= update_weight;
				endcase
				
				if (weight_layer[15] == 2'b11) begin
					if (weight_addr[15] == NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
						write_weight_mode		<= 1;
						weight_addr_counter 	<= 'd0;
						weight_layer_counter 	<= 2'b01;
					end
				end
			end
		
			if (write_weight_mode) begin
				o_update_weight_layer 	<= weight_layer_counter;
				o_update_weight_addr 	<= weight_addr_counter;
				case (weight_layer_counter)
					2'b01:
						begin
							o_update_weight_valid 	<= 1;
							if (weight_addr_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b10;
							end
						end
					2'b10:
						begin
							o_update_weight_valid 	<= 1;
							if (weight_addr_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b11;
							end
						end
					2'b11:
						begin
							if (weight_addr_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin
								o_update_weight_valid 	<= 1;
								weight_addr_counter 	<= weight_addr_counter + 1;
							end
							else begin
								weight_addr_counter 	<= 'd0;
								weight_layer_counter	<= 2'b01;
								write_weight_mode 			<= 0;
								o_update_weight_valid 	<= 0;
								o_update_weight_done 	<= 1;
							end
						end
				endcase
			end
			else begin
				o_update_weight_valid 	<= 0;
				o_update_weight_done 	<= 0;
			end
		end 
	end 

endmodule