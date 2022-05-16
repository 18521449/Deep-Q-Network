`timescale 1ns/1ps
module update_weight
	#(	parameter DATA_WIDTH = 32
	)
	(	clk,
		rst_n,
		i_valid,
		i_weight,
		i_error,
		o_new_weight,
		o_valid
	);
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_valid;
	input		[DATA_WIDTH-1:0]		i_weight;
	input 		[DATA_WIDTH-1:0]		i_error;
	output 		[DATA_WIDTH-1:0] 		o_new_weight;
	output 	 							o_valid;
	//-------------------------------------------------------//

	adder_floating_point32 sub_weight // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(i_valid),
			.inA		(i_weight), 
			.inB		({~i_error[DATA_WIDTH-1], i_error[DATA_WIDTH-2:0]}),
			.valid_out	(o_valid),
			.out_data	(o_new_weight));
endmodule

/*
`timescale 1ns/1ps
module update_weight
	#(	parameter DATA_WIDTH 						= 32,
		parameter NUMBER_OF_INPUT_NODE 				= 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 	= 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 	= 32,
		parameter NUMBER_OF_OUTPUT_NODE 			= 3,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F	//0.002
	)
	(	clk,
		rst_n,
		i_weight_valid,
		i_weight,
		i_error_valid,
		i_error,
		o_current_layer,
		o_weight_valid,
		o_new_weight,
		o_valid
	);
	
	localparam BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	localparam LAYER_WIDTH = 2;
	localparam BUFFER_WIDTH = 32;
	localparam RAM_WIDTH = 11;
	
	//-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_weight_valid;
	input		[DATA_WIDTH-1:0]		i_weight;
	input 								i_error_valid;
	input 		[DATA_WIDTH-1:0]		i_error;
	output reg 	[LAYER_WIDTH-1:0]		o_current_layer;
	output reg							o_weight_valid;
	output 		[DATA_WIDTH-1:0] 		o_new_weight;
	output 	 							o_valid;
	//-------------------------------------------------------//


	//-------------------------------------------------------------------//
	reg 		[DATA_WIDTH-1:0]		error_buffer [BUFFER_WIDTH-1:0];
	reg 		[DATA_WIDTH-1:0]		weight;
	reg 		[DATA_WIDTH-1:0]		error;
	//-------------------------------------------------------------------//
	
	//---------------------------------------------------------//
	reg 		[BIGEST_WIDTH:0] 		error_counter;
	reg 		[BIGEST_WIDTH:0] 		fifo_counter;
	reg 								valid_in;
	// ---------------------------------------------------------//
	
	// ---------------------------------------------------------//
	reg 		[RAM_WIDTH:0] 			INPUT_NODE_CONFIG;
	// ---------------------------------------------------------//

	adder_floating_point32 sub_weight // 7 CLOCK
		(	.clk		(clk),
			.rstn		(rst_n), 
			.valid_in	(valid_in),
			.inA		(weight), 
			.inB		({~error[DATA_WIDTH-1], error[DATA_WIDTH-2:0]}),
			.valid_out	(o_valid),
			.out_data	(o_new_weight));

	initial begin
		error_counter <= 'd0;
		fifo_counter <= 'd0;
		o_current_layer <= 'd0;
	end
	
	integer i;
	always @(posedge clk or negedge rst_n) begin	
		if (!rst_n) begin
			error_counter <= 'd0;
			fifo_counter <= 'd0;
		end
		else begin
		
			case (o_current_layer)
				2'b00: // INPUT LAYER
					begin
						if (error_counter == 'd0) begin
							if (i_error_valid) begin
								error_buffer[fifo_counter] <= i_error;
								error_counter <= error_counter + 1;
								fifo_counter <= fifo_counter + 1;
								o_current_layer <= 2'b11;
								o_weight_valid <= 1;
							end
						end
						else o_weight_valid = 0;
					end
				2'b11: // OUTPUT LAYER
					begin
						INPUT_NODE_CONFIG <= NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1);
						if (error_counter == INPUT_NODE_CONFIG) begin
							o_current_layer <= 2'b10;
							o_weight_valid <= 1;
						end
						else o_weight_valid = 0;
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						INPUT_NODE_CONFIG <= NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1);
						if (error_counter == INPUT_NODE_CONFIG) begin
							o_current_layer <= 2'b01;
							o_weight_valid <= 1;
						end
						else o_weight_valid = 0;
					end
				2'b01: // HIDDEN 1 LAYER
					begin
						INPUT_NODE_CONFIG <= NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1);
						if (error_counter == INPUT_NODE_CONFIG) begin
							o_current_layer <= 2'b00;
							o_weight_valid <= 0;
						end
						else o_weight_valid = 0;
					end
			endcase
			
			if (i_error_valid) begin
				error_buffer[fifo_counter] <= i_error;
				fifo_counter <= fifo_counter + 1;
				if (error_counter < INPUT_NODE_CONFIG-1) begin
					error_counter <= error_counter + 1;
				end
				else error_counter <= 'd0;
			end
			else begin
				if (error_counter == INPUT_NODE_CONFIG-1) begin
					error_buffer[fifo_counter] <= i_error;
					error_counter <= 'd0;
					fifo_counter <= fifo_counter + 1;
				end
			end
			
			
			if fi 
			if (i_weight_valid) begin
				weight <= i_weight;
				error <= error_buffer[0];
				valid_in <= 1;
				if (fifo_counter > 0)
					fifo_counter <= fifo_counter - 1;
				for (i=0; i<BUFFER_WIDTH-1; i=i+1) begin
					error_buffer[i] <= error_buffer[i+1];
				end
			end
			else valid_in <= 0;
		end
	end

endmodule
*/