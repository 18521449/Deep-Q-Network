`timescale 1ns/1ps
module block_ram_weight
	#(	parameter DATA_WIDTH = 32,
		parameter LAYER_WIDTH = 2,
		parameter NUMBER_OF_INPUT_NODE = 2,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32,
		parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32,
		parameter NUMBER_OF_OUTPUT_NODE = 3
	)
	(	clk,
		i_ram_enable,
		i_rw_select, // 1 for read, 0 for write
		i_weight_layer,
		i_weight_addr,
		i_weight,
		o_weight_valid,
		o_weight_layer,
		o_weight_addr,
		o_weight
	);
	
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//------------------------input and output port-----------------------//
	input										clk;
	input										i_ram_enable;
	input										i_rw_select; // 1 for read, 0 for write
	input		[LAYER_WIDTH-1:0]				i_weight_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_weight_addr;
	input 		[DATA_WIDTH-1:0] 				i_weight;
	output reg									o_weight_valid;
	output reg	[LAYER_WIDTH-1:0]				o_weight_layer;
	output reg	[WEIGHT_COUNTER_WIDTH-1:0]		o_weight_addr;
	output reg 	[DATA_WIDTH-1:0] 				o_weight;
	//--------------------------------------------------------------------//
	
	//-----------------------------------------------------------------------------------------------------------------//
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_weight_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_weight_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_weight_outlayer 	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	//-----------------------------------------------------------------------------------------------------------------//
	
	always @(posedge clk) begin
		if (i_ram_enable) begin
			case (i_weight_layer)
				2'b01: // HIDDEN 1 LAYER
					begin
						if (i_rw_select) begin // read
							o_weight_valid <= 1;
							o_weight_layer <= i_weight_layer;
							o_weight_addr <= i_weight_addr;
							o_weight <= ram_weight_hidden_1[i_weight_addr];
						end
						else begin // write
							ram_weight_hidden_1[i_weight_addr] <= i_weight;
							o_weight_valid <= 0;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (i_rw_select) begin // read
							o_weight_valid <= 1;
							o_weight_layer <= i_weight_layer;
							o_weight_addr <= i_weight_addr;
							o_weight <= ram_weight_hidden_2[i_weight_addr];
						end
						else begin // write
							ram_weight_hidden_2[i_weight_addr] <= i_weight;
							o_weight_valid <= 0;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (i_rw_select) begin // read
							o_weight_valid <= 1;
							o_weight_layer <= i_weight_layer;
							o_weight_addr <= i_weight_addr;
							o_weight <= ram_weight_outlayer[i_weight_addr];
						end
						else begin // write
							ram_weight_outlayer[i_weight_addr] <= i_weight;
							o_weight_valid <= 0;
						end
					end
			endcase
		end
		else o_weight_valid <= 0;
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