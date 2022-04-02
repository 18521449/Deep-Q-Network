`timescale 1ns/1ps
module ram
	#(
		parameter RAM_WIDTH 		= 32,
		parameter RAM_ADDR_BITS 	= 5,
		parameter DATA_FILE 		= "D:/DoAn/DQN_RTL/Target_net/Target_net/target_ram_hidden_1_weight.txt",
		parameter ADDRESS			= 0
	)
	(
	input							clk,
	input 							rst_n,
	input							ram_enable,
	input							write_enable,
	input 		[RAM_WIDTH-1:0] 	i_data,
	output reg 	[RAM_WIDTH-1:0] 	o_data
	);
	
	reg valid_out;
   
   (* RAM_STYLE="BLOCK" *)
   reg [RAM_WIDTH-1:0] ram_name [(2**RAM_ADDR_BITS)-1:0];


   //  The forllowing code is only necessary if you wish to initialize the RAM 
   //  contents via an external file (use $readmemb for binary data)
   // initial
      // $readmemh(DATA_FILE, ram_name);

	integer i;
   always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// for (i=0; i< (2**RAM_ADDR_BITS); i=i+1) begin
				// ram_name[i] <= 'd0;
			// end
		end
		else begin
			if (ram_enable) begin
				$readmemh(DATA_FILE, ram_name);
				if (write_enable) begin
					ram_name[ADDRESS] <= i_data;
				end
				#1 o_data <= ram_name[ADDRESS];
			end
		end

	end
endmodule