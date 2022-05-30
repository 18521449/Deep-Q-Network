module ram_error
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
		i_error_layer,
		i_error_addr,
		i_error,
		o_error_valid,
		o_error_layer,
		o_error_addr,
		o_error
	);
	
	localparam WEIGHT_COUNTER_WIDTH 	= 11;
	
	//------------------------input and output port-----------------------//
	input										clk;
	input										i_ram_enable;
	input										i_rw_select; // 1 for read, 0 for write
	input		[LAYER_WIDTH-1:0]				i_error_layer;
	input 		[WEIGHT_COUNTER_WIDTH-1:0]		i_error_addr;
	input 		[DATA_WIDTH-1:0] 				i_error;
	output reg									o_error_valid;
	output reg	[LAYER_WIDTH-1:0]				o_error_layer;
	output reg	[WEIGHT_COUNTER_WIDTH-1:0]		o_error_addr;
	output reg 	[DATA_WIDTH-1:0] 				o_error;
	//--------------------------------------------------------------------//
	
	//-----------------------------------------------------------------------------------------------------------------//
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_error_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1*(NUMBER_OF_INPUT_NODE+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_error_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2*(NUMBER_OF_HIDDEN_NODE_LAYER_1+1)-1:0];
	reg [DATA_WIDTH-1:0] ram_error_outlayer 	[NUMBER_OF_OUTPUT_NODE*(NUMBER_OF_HIDDEN_NODE_LAYER_2+1)-1:0];
	//-----------------------------------------------------------------------------------------------------------------//
	
	always @(posedge clk) begin
		if (i_ram_enable) begin
			case (i_error_layer)
				2'b01: // HIDDEN 1 LAYER
					begin
						if (i_rw_select) begin // read
							o_error_valid <= 1;
							o_error_layer <= i_error_layer;
							o_error_addr <= i_error_addr;
							o_error <= ram_error_hidden_1[i_error_addr];
						end
						else begin // write
							ram_error_hidden_1[i_error_addr] <= i_error;
							o_error_valid <= 0;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (i_rw_select) begin // read
							o_error_valid <= 1;
							o_error_layer <= i_error_layer;
							o_error_addr <= i_error_addr;
							o_error <= ram_error_hidden_2[i_error_addr];
						end
						else begin // write
							ram_error_hidden_2[i_error_addr] <= i_error;
							o_error_valid <= 0;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (i_rw_select) begin // read
							o_error_valid <= 1;
							o_error_layer <= i_error_layer;
							o_error_addr <= i_error_addr;
							o_error <= ram_error_outlayer[i_error_addr];
						end
						else begin // write
							ram_error_outlayer[i_error_addr] <= i_error;
							o_error_valid <= 0;
						end
					end
			endcase
		end
		else o_error_valid <= 0;
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