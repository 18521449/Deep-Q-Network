module ram_weight
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(
	clk,
	i_ram_enable,
	i_rw_select, // 1 for read, 0 for write
	i_layer,
	i_weight,
	o_weight,
	o_valid
	);
	localparam BIGEST_WIDTH = $clog2((NUMBER_OF_HIDDEN_NODE_LAYER_1+1)*NUMBER_OF_HIDDEN_NODE_LAYER_2);
	
	input							clk;
	input							i_ram_enable;
	input							i_rw_select; // 1 for read, 0 for write
	input		[LAYER_WIDTH-1:0]	i_layer;
	input 		[DATA_WIDTH-1:0] 	i_weight;
	output reg 	[DATA_WIDTH-1:0] 	o_weight;
	output reg 						o_valid;
	
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_weight_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_weight_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_weight_outlayer 	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	
	reg [BIGEST_WIDTH-1:0] 			weight_counter;
	reg 							valid_in;
	reg 							read_valid;
	reg 							write_valid;
	
	initial begin
		weight_counter <= 'd0;
		read_valid <= 0;
	end
	
	always @(posedge clk) begin
		if (i_ram_enable & i_rw_select) begin // read
			read_valid <= 1;
		end
		else if (i_ram_enable & !i_rw_select) begin // write
			o_valid <= 0;
			case (i_layer)
				2'b01: // HIDDEN 1 LAYER
					begin
						if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1) begin 
							ram_weight_hidden_1[weight_counter] <= i_weight;
							weight_counter <= weight_counter + 1;
						end
						else begin
							weight_counter <= 'd0;
							ram_weight_hidden_1[weight_counter] <= i_weight;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1) begin 
							ram_weight_hidden_2[weight_counter] <= i_weight;
							weight_counter <= weight_counter + 1;
						end
						else begin
							weight_counter <= 'd0;
							ram_weight_hidden_2[weight_counter] <= i_weight;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (weight_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1) begin 
							ram_weight_outlayer[weight_counter] <= i_weight;
							weight_counter <= weight_counter + 1;
						end
						else begin
							weight_counter <= 'd0;
							ram_weight_outlayer[weight_counter] <= i_weight;
						end
					end
			endcase
		end
			
		if (read_valid) begin
			case (i_layer)
				2'b01: // HIDDEN 1 LAYER
					begin
						if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)) begin 
							o_weight <= ram_weight_hidden_1[weight_counter];
							weight_counter <= weight_counter + 1;
							o_valid <= 1;
						end
						else begin
							weight_counter <= 'd0;
							read_valid <= 0;
							o_valid <= 0;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (weight_counter < NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)) begin 
							o_weight <= ram_weight_hidden_2[weight_counter];
							weight_counter <= weight_counter + 1;
							o_valid <= 1;
						end
						else begin
							weight_counter <= 'd0;
							read_valid <= 0;
							o_valid <= 0;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (weight_counter < NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)) begin 
							o_weight <= ram_weight_outlayer[weight_counter];
							weight_counter <= weight_counter + 1;
							o_valid <= 1;
						end
						else begin
							weight_counter <= 'd0;
							read_valid <= 0;
							o_valid <= 0;
						end
					end
				
			endcase
		end
		else o_valid <= 0;
		
	end
	
	// function for clog2
	function integer clog2;
	input integer value;
	begin
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	end
	endfunction
	
endmodule