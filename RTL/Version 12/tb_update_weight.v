`timescale 1ns/1ps
module tb_update_weight();

parameter DATA_WIDTH = 32;
parameter NUMBER_OF_INPUT_NODE = 2;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_1 = 32;
parameter NUMBER_OF_HIDDEN_NODE_LAYER_2 = 32;
parameter NUMBER_OF_OUTPUT_NODE = 3;
parameter ERROR_FILE 			= "main_ram_error.txt";
parameter WEIGHT_FILE_HIDDEN_1 	= "main_ram_hidden_1_weight.txt";
parameter WEIGHT_FILE_HIDDEN_2 	= "main_ram_hidden_2_weight.txt";
parameter WEIGHT_FILE_OUTPUT  	= "main_ram_output_weight.txt";
parameter k =5;

reg 							clk;
reg 							rst_n;
reg 							i_valid;
reg		[DATA_WIDTH-1:0]		i_weight;
reg 	[DATA_WIDTH-1:0]		i_error;
wire 	[DATA_WIDTH-1:0] 		o_new_weight;
wire 	 						o_valid;

reg 	[DATA_WIDTH-1:0] 			ram_weight_hidden_1		[32*3-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_weight_hidden_2		[32*33-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_weight_output		[3*33-1:0];
reg 	[DATA_WIDTH-1:0] 			ram_error				[1250:0];

reg 	[11:0]						weight_counter;
reg 	[11:0]						error_counter;
reg 	[11:0]						weight_addr;
reg 								data_valid;


initial begin
	$readmemh(ERROR_FILE			, ram_error);
	$readmemh(WEIGHT_FILE_HIDDEN_1	, ram_weight_hidden_1);
	$readmemh(WEIGHT_FILE_HIDDEN_2	, ram_weight_hidden_2);
	$readmemh(WEIGHT_FILE_OUTPUT	, ram_weight_output);
	clk 			<= 0;
	rst_n 			<= 1;
	weight_counter 	<= 'd0;
	data_valid 		<= 0;
	error_counter 	<= 'd0;
	weight_addr 	<= 'd0;
	#k#k 	data_valid <= 1;
	#(2800*k) $finish;
end

update_weight	
	#(	.DATA_WIDTH						(DATA_WIDTH)
	)
	update_weight_tb
	(	.clk				(clk),
		.rst_n				(rst_n),
		.i_valid			(i_valid),
		.i_weight			(i_weight),
		.i_error			(i_error),
		.o_new_weight		(o_new_weight),
		.o_valid			(o_valid)
	);
	
integer i;
always @(posedge clk) begin
	
	if (data_valid) begin
		if (error_counter < 99) begin
			i_valid <= 1;
			i_error <= ram_error[error_counter];
			i_weight <= ram_weight_output[weight_counter];
			error_counter <= error_counter + 1;
			if (error_counter == 98)
				weight_counter <= 'd0;
			else weight_counter <= weight_counter + 1;
		end
		else begin
			if (error_counter < 99+1056) begin
				i_valid <= 1;
				i_error <= ram_error[error_counter];
				i_weight <= ram_weight_hidden_2[weight_counter];
				error_counter <= error_counter + 1;
				if (error_counter == 99+1055)
					weight_counter <= 'd0;
				else weight_counter <= weight_counter + 1;
			end
			else begin
				if (error_counter < 99+1056+96) begin
					i_valid <= 1;
					i_error <= ram_error[error_counter];
					i_weight <= ram_weight_hidden_1[weight_counter];
					error_counter <= error_counter + 1;
					if (error_counter == 99+1056+95)
						weight_counter <= 'd0;
					else weight_counter <= weight_counter + 1;
				end
				else begin 
					i_valid <= 0;
					data_valid <= 0;
				end
			end
		end
	end
	else i_valid <= 0;

	if (o_valid) begin
		$display("new_weight :%h", o_new_weight);
		$display("addr 	:%d", weight_addr);
		$display("--------------------------------");
		weight_addr = weight_addr + 1;
	end
end
  
always @(*) begin
  #k clk <= ~clk;
end

endmodule



	
