module ram
	#(
		parameter RAM_WIDTH 		= 32,
		parameter RAM_ADDR_BITS 	= 5,
		parameter DATA_FILE 		= "target_ram_hidden_1_weight.txt",
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
	
   
   (* RAM_STYLE="BLOCK" *)
   reg [RAM_WIDTH-1:0] ram_name [(2**RAM_ADDR_BITS)-1:0];


   //  The forllowing code is only necessary if you wish to initialize the RAM 
   //  contents via an external file (use $readmemb for binary data)
   initial
      $readmemb(DATA_FILE, ram_name);

	integer i;
   always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// for (i=0; i< (2**RAM_ADDR_BITS); i=i+1) begin
				// ram_name[i] <= 'd0;
			// end
		end
		else begin
			if (ram_enable) begin
				if (write_enable) begin
					ram_name[ADDRESS] <= i_data;
					$writememb(DATA_FILE, ram_name);
				end
				o_data <= ram_name[ADDRESS];
			end
		end
	end
endmodule