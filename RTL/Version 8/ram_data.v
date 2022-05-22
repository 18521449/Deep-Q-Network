module ram_data
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
	i_data_addr,
	i_layer,
	i_data,
	o_data,
	o_valid
	);
	localparam BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
	
	
	input							clk;
	input							i_ram_enable;
	input							i_rw_select; // 1 for read, 0 for write
	input 		[BIGEST_WIDTH-1:0]	i_data_addr;
	input		[LAYER_WIDTH-1:0]	i_layer;
	input 		[DATA_WIDTH-1:0] 	i_data;
	output reg 	[DATA_WIDTH-1:0] 	o_data;
	output reg 						o_valid;
	
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] ram_data_inlayer 	[NUMBER_OF_INPUT_NODE-1:0];
	reg [DATA_WIDTH-1:0] ram_data_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0];
	reg [DATA_WIDTH-1:0] ram_data_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0];
	reg [DATA_WIDTH-1:0] ram_data_outlayer 	[NUMBER_OF_OUTPUT_NODE-1:0];

	always @(posedge clk) begin
		if (i_ram_enable) begin
			case (i_layer)
				2'b00: // INPUT LAYER
					begin
						if (i_rw_select) begin // read
							o_data <= ram_data_inlayer[i_data_addr];
							o_valid <= 1;
						end
						else begin // write
							ram_data_inlayer[i_data_addr] <= i_data;
							o_valid <= 0;
						end
					end
				2'b01: // HIDDEN 1 LAYER
					begin
						if (i_rw_select) begin // read
							o_data <= ram_data_hidden_1[i_data_addr];
							o_valid <= 1;
						end
						else begin // write
							ram_data_hidden_1[i_data_addr] <= i_data;
							o_valid <= 0;
						end
					end
				2'b10: // HIDDEN 2 LAYER
					begin
						if (i_rw_select) begin // read
							o_data <= ram_data_hidden_2[i_data_addr];
							o_valid <= 1;
						end
						else begin // write
							ram_data_hidden_2[i_data_addr] <= i_data;
							o_valid <= 0;
						end
					end
				2'b11: // OUTPUT LAYER
					begin
						if (i_rw_select) begin // read
							o_data <= ram_data_outlayer[i_data_addr];
							o_valid <= 1;
						end
						else begin // write
							ram_data_outlayer[i_data_addr] <= i_data;
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