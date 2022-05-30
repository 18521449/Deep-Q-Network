`timescale 1ns/1ps
module tb_ram_data();

parameter RAM_WIDTH = 32;
parameter LAYER_WIDTH = 2;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter DATA_FILE_INPUT	 	= "main_ram_input_data.txt";
parameter DATA_FILE_HIDDEN_1 	= "main_ram_hidden_1_data.txt";
parameter DATA_FILE_HIDDEN_2 	= "main_ram_hidden_2_data.txt";
parameter DATA_FILE_OUTPUT 		= "main_ram_output_data.txt";
parameter DATA_BUFFER_WIDTH = NUMBER_OF_INPUT_NODE + NUMBER_OF_HIDDEN_NODE_LAYER_1 + NUMBER_OF_HIDDEN_NODE_LAYER_2 + NUMBER_OF_OUTPUT_NODE;
parameter BIGEST_WIDTH = $clog2(NUMBER_OF_HIDDEN_NODE_LAYER_1);
parameter k =5;

reg							clk;
reg							i_ram_enable;
reg							i_rw_select; // 1 for read, 0 for write
reg 	[BIGEST_WIDTH-1:0]	i_data_addr;
reg		[LAYER_WIDTH-1:0]	i_layer;
reg 	[RAM_WIDTH-1:0] 	i_data;
wire  	[RAM_WIDTH-1:0] 	o_data;
wire  						o_valid;


reg [RAM_WIDTH-1:0] ram_data_input 		[NUMBER_OF_INPUT_NODE-1:0];
reg [RAM_WIDTH-1:0] ram_data_hidden_1 	[NUMBER_OF_HIDDEN_NODE_LAYER_1-1:0];
reg [RAM_WIDTH-1:0] ram_data_hidden_2 	[NUMBER_OF_HIDDEN_NODE_LAYER_2-1:0];
reg [RAM_WIDTH-1:0] ram_data_output 	[NUMBER_OF_OUTPUT_NODE-1:0];

reg [5:0] node_counter;

integer i;
initial begin
	$readmemh(DATA_FILE_INPUT		, ram_data_input);
	$readmemh(DATA_FILE_HIDDEN_1	, ram_data_hidden_1);
	$readmemh(DATA_FILE_HIDDEN_2	, ram_data_hidden_2);
	$readmemh(DATA_FILE_OUTPUT		, ram_data_output);
	clk 			<= 0;
	i_ram_enable 	<= 0;
	node_counter 	<= 'd0;
	for (i=0; i<NUMBER_OF_INPUT_NODE; i=i+1) begin
		#k#k 	i_ram_enable <= 1;
				i_rw_select <= 0;
				i_data_addr <= node_counter;
				i_layer <= 'd0;
				i_data <= ram_data_input[i];
				node_counter <= node_counter + 1;
	end
	#k#k 	i_ram_enable <= 0;
			node_counter <= 'd0;
	for (i=0; i<NUMBER_OF_HIDDEN_NODE_LAYER_1; i=i+1) begin
		#k#k 	i_ram_enable <= 1;
				i_rw_select <= 0;
				i_data_addr <= node_counter;
				i_layer <= 'd1;
				i_data <= ram_data_hidden_1[i];
				node_counter <= node_counter + 1;
	end
	#k#k 	i_ram_enable <= 0;
			node_counter <= 'd0;
	for (i=0; i<NUMBER_OF_HIDDEN_NODE_LAYER_2; i=i+1) begin
		#k#k 	i_ram_enable <= 1;
				i_rw_select <= 0;
				i_data_addr <= node_counter;
				i_layer <= 'd2;
				i_data <= ram_data_hidden_2[i];
				node_counter <= node_counter + 1;
	end
	#k#k 	i_ram_enable <= 0;
			node_counter <= 'd0;
	for (i=0; i<NUMBER_OF_OUTPUT_NODE; i=i+1) begin
		#k#k 	i_ram_enable <= 1;
				i_rw_select <= 0;
				i_data_addr <= node_counter;
				i_layer <= 'd3;
				i_data <= ram_data_output[i];
				node_counter <= node_counter + 1;
	end
	#k#k 	i_ram_enable <= 0;
			node_counter <= 'd0;
	for (i=0; i<NUMBER_OF_HIDDEN_NODE_LAYER_1; i=i+1) begin
		#k#k 	i_ram_enable <= 1;
				i_rw_select <= 1;
				i_data_addr <= node_counter;
				i_layer <= 'd2;
				node_counter <= node_counter + 1;
	end
	#k#k 	i_ram_enable <= 0;
	#(100*k) $finish;
end

ram_data	
	#(	.RAM_WIDTH						(RAM_WIDTH),
		.LAYER_WIDTH					(LAYER_WIDTH),
		.NUMBER_OF_INPUT_NODE			(NUMBER_OF_INPUT_NODE),
		.NUMBER_OF_HIDDEN_NODE_LAYER_1	(NUMBER_OF_HIDDEN_NODE_LAYER_1),
		.NUMBER_OF_HIDDEN_NODE_LAYER_2	(NUMBER_OF_HIDDEN_NODE_LAYER_2),
		.NUMBER_OF_OUTPUT_NODE			(NUMBER_OF_OUTPUT_NODE)
	)
	ram_data_tb
	(	.clk			(clk),
		.i_ram_enable	(i_ram_enable),
		.i_rw_select	(i_rw_select), // 1 for read, 0 for write
		.i_data_addr	(i_data_addr),
		.i_layer		(i_layer),
		.i_data			(i_data),
		.o_data			(o_data),
		.o_valid		(o_valid)
	);

always @(posedge clk) begin
	if (o_valid) begin
		$display("data node :%h", o_data);
		$display("addr node :%d", node_counter);
		$display("--------------------------------");
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
