module target_net_memory
	#( 	parameter DATA_WIDTH = 32,
		parameter MEM_WIDTH = 5,
		parameter NODE_WIDTH_INPUT = 2,
		parameter NODE_WIDTH_HIDDEN_1 = 32,
		parameter NODE_WIDTH_HIDDEN_2 = 32,
		parameter NODE_WIDTH_OUTPUT = 3,
		parameter CURRENT_LAYER = 1, 		// HIDDEN_1 = 1 || HIDDEN_2 = 2 || OUTPUT = 3
		parameter NODE_WIDTH_CURRENT = 32)
	(	clk,
		rst_n,
		i_mem_enable,
		i_rw_mem, 			// 1 for read, 0 for write
		i_update_weight, 	// 1 for update weight, 0 for non update weight -> update data only
		i_addr,				// addr for (update data) or (read data & weight)
		i_data,
		i_weight,
		i_bias,
		o_data,
		o_weight,
		o_bias,
		o_valid
	);
	
	//----------------------input and output port-------------------------//
	input 													clk;
	input 													rst_n;
	input													i_mem_enable;
	input 													i_rw_mem;
	input													i_update_weight;
	input 		[MEM_WIDTH-1:0]								i_addr;
	input 		[DATA_WIDTH-1:0] 							i_data;	
	input 		[DATA_WIDTH*NODE_WIDTH_CURRENT-1:0] 		i_weight;
	input 		[DATA_WIDTH-1:0] 							i_bias;
	output reg	[DATA_WIDTH*NODE_WIDTH_INPUT-1:0] 			o_data;
	output reg	[DATA_WIDTH*NODE_WIDTH_INPUT-1:0]			o_weight;
	output reg	[DATA_WIDTH-1:0]							o_bias;
	output reg 												o_valid;
	//--------------------------------------------------------------------//
	
	
	//--------------------------------MEMORY FOR HIDDEN 1 LAYER----------------------------------//
	reg [DATA_WIDTH-1:0] 						ram_hidden_1_data		[NODE_WIDTH_HIDDEN_1-1:0];
	reg [DATA_WIDTH*NODE_WIDTH_INPUT-1:0] 		ram_hidden_1_weight		[NODE_WIDTH_HIDDEN_1-1:0];
	reg [DATA_WIDTH-1:0]						ram_hidden_1_bias		[NODE_WIDTH_HIDDEN_1-1:0];
	//-------------------------------------------------------------------------------------------//
	
	//--------------------------------MEMORY FOR HIDDEN 2 LAYER----------------------------------//
	reg [DATA_WIDTH-1:0] 						ram_hidden_2_data		[NODE_WIDTH_HIDDEN_2-1:0];
	reg [DATA_WIDTH*NODE_WIDTH_HIDDEN_1-1:0] 	ram_hidden_2_weight		[NODE_WIDTH_HIDDEN_2-1:0];
	reg [DATA_WIDTH-1:0]						ram_hidden_2_bias		[NODE_WIDTH_HIDDEN_2-1:0];
	//-------------------------------------------------------------------------------------------//
	
	//----------------------------------MEMORY FOR OUTPUT LAYER----------------------------------//
	reg [DATA_WIDTH-1:0]						ram_output_data			[NODE_WIDTH_OUTPUT-1:0];
	reg [DATA_WIDTH*NODE_WIDTH_HIDDEN_2-1:0] 	ram_output_weight		[NODE_WIDTH_OUTPUT-1:0];
	reg [DATA_WIDTH-1:0]						ram_output_bias			[NODE_WIDTH_OUTPUT-1:0];
	//-------------------------------------------------------------------------------------------//
	
	integer i;
	always @(posedge clk or negedge rst_n) begin
		
		//If reset is turn on
		if (!rst_n) begin
			for (i=0; i<NODE_WIDTH_HIDDEN_1; i=i+1) begin
				ram_hidden_1_data[i] <= 'd0;
				ram_hidden_1_weight[i]	<= 'd0;
				ram_hidden_1_bias[i] <= 'd0;		
			end
			for (i=0; i<NODE_WIDTH_HIDDEN_2; i=i+1) begin
				ram_hidden_2_data[i] <= 'd0;
				ram_hidden_2_weight[i]	<= 'd0;
				ram_hidden_2_bias[i] <= 'd0;		
			end
			for (i=0; i<NODE_WIDTH_OUTPUT; i=i+1) begin
				ram_output_data[i] <= 'd0;
				ram_output_weight[i] <= 'd0;
				ram_output_bias[i] <= 'd0;		
			end
		end
		
		else begin // else no reset
			
			// If mem enable = 1, turn on memory
			if (i_mem_enable) begin
			
				// If read memory to target net
				if (i_rw_mem) begin
					
					// Choose Current layer need update
					case (CURRENT_LAYER)
					
						// HIDDEN_1 LAYER
						'd1: begin
								o_data <= ram_hidden_1_data[i_addr];
								o_weight <= ram_hidden_1_weight[i_addr];
								o_bias <= ram_hidden_1_bias[i_addr];
							end
							
						// HIDDEN_2 LAYER
						'd2: begin	
								o_data <= ram_hidden_2_data[i_addr];
								o_weight <= ram_hidden_2_weight[i_addr];
								o_bias <= ram_hidden_2_bias[i_addr];
							end
						
						// OUTPUT LAYER
						'd3: begin	
								o_data <= ram_output_data[i_addr];
								o_weight <= ram_output_weight[i_addr];
								o_bias <= ram_output_bias[i_addr];
							end
					endcase
				end
				
				// Else write data to memory 
				else begin
				
					// If update weight -> write weight only
					if (i_update_weight) begin
						
						// Choose Current layer need update
						case (CURRENT_LAYER)
						
							// HIDDEN_1 LAYER
							'd1: begin
									ram_hidden_1_weight[i_addr] <= i_weight;
									ram_hidden_1_bias[i_addr] <= i_bias;
								end
								
							// HIDDEN_2 LAYER
							'd2: begin	
									ram_hidden_2_weight[i_addr] <= i_weight;
									ram_hidden_2_bias[i_addr] <= i_bias;
								end
								
							// OUTPUT LAYER
							'd3: begin	
									ram_output_weight[i_addr] <= i_weight;
									ram_output_bias[i_addr] <= i_bias;
								end
						endcase
						
					end
					
					// If no update weight -> update data only
					else begin 
					
						// Choose Current layer need update
						case (CURRENT_LAYER)
							
							// HIDDEN_1 LAYER
							'd1: ram_hidden_1_data[i_addr] <= i_data;
							
							// HIDDEN_2 LAYER
							'd2: ram_hidden_2_data[i_addr] <= i_data;		
								
							// OUTPUT LAYER
							'd3: ram_output_data[i_addr] <= i_data;
						endcase
					end
				
				end // end esle (if (i_rw_mem)) -> write
			end // end enable
		end // end else (if (!rst_n)) -> no reset
	end	// end always
	
endmodule