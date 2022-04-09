`timescale 1ns/1ps
module update_weight_layer
	#(	parameter DATA_WIDTH 						= 32,
		parameter ADDRESS_WIDTH 					= 11,
		parameter WEIGHT_FILE 						= "main_ram_output_weight.txt",
		parameter DATA_POINT_FILE 					= "main_ram_hidden_2_data.txt",
		parameter DELTA_FILE 						= "main_ram_output_delta.txt",
		parameter NEW_WEIGHT_FILE					= "main_ram_output_weight_new.txt",
		parameter NUMBER_OF_FORWARD_NODE 			= 3,
		parameter NUMBER_OF_BACK_NODE				= 32,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F
	)
	(	clk,
		rst_n,
		i_valid,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
output reg 							o_valid;
//---------------------------------------------------//

//-------------------------------------------------------------------------------------//
wire [DATA_WIDTH-1:0]	weight			[(NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE-1:0];
wire [DATA_WIDTH-1:0]	data_point		[NUMBER_OF_BACK_NODE:0];
wire [DATA_WIDTH-1:0]	delta			[NUMBER_OF_FORWARD_NODE-1:0];
wire [DATA_WIDTH-1:0]	new_weight		[(NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
reg [DATA_WIDTH-1:0] 	ram_new_weight	[(NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE-1:0];
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire [((NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE)-1:0] 	valid_out;
wire [((NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE)-1:0]		valid_out_ram_weight;			
wire [NUMBER_OF_BACK_NODE-1:0]									valid_out_ram_point;
wire [NUMBER_OF_FORWARD_NODE-1:0]								valid_out_ram_delta;
reg 															write_file;
wire 															valid_in;
//--------------------------------------------------------------------------------------//

genvar i;
generate 
	for (i=0; i<((NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE); i=i+1) begin: get_weight_generate
		ram
		#(
			.RAM_WIDTH			(DATA_WIDTH),
			.RAM_ADDR_BITS		(ADDRESS_WIDTH),
			.DATA_FILE			(WEIGHT_FILE),
			.ADDRESS			(i)
		)
		ram_weight_node
		(
			.clk				(clk),
			.rst_n				(rst_n),
			.ram_enable			(i_valid),
			.write_enable		(1'b0),
			.i_data				(),
			.o_data				(weight[i]),
			.o_valid			(valid_out_ram_weight[i])
		);
	end
endgenerate

genvar j;
generate 
	for (j=0; j<NUMBER_OF_BACK_NODE; j=j+1) begin: get_point_generate
		ram
		#(
			.RAM_WIDTH			(DATA_WIDTH),
			.RAM_ADDR_BITS		(ADDRESS_WIDTH),
			.DATA_FILE			(DATA_POINT_FILE),
			.ADDRESS			(j)
		)
		ram_data_point
		(
			.clk				(clk),
			.rst_n				(rst_n),
			.ram_enable			(i_valid),
			.write_enable		(1'b0),
			.i_data				(),
			.o_data				(data_point[j]),
			.o_valid			(valid_out_ram_point[j])
		);
	end
endgenerate

genvar k;
generate 
	for (k=0; k<NUMBER_OF_FORWARD_NODE; k=k+1) begin: get_delta_generate
		ram
		#(
			.RAM_WIDTH			(DATA_WIDTH),
			.RAM_ADDR_BITS		(ADDRESS_WIDTH),
			.DATA_FILE			(DELTA_FILE),
			.ADDRESS			(k)
		)
		ram_delta
		(
			.clk				(clk),
			.rst_n				(rst_n),
			.ram_enable			(i_valid),
			.write_enable		(1'b0),
			.i_data				(),
			.o_data				(delta[k]),
			.o_valid			(valid_out_ram_delta[k])
		);
	end
endgenerate

assign valid_in = (&valid_out_ram_weight) & (&valid_out_ram_point) & (&valid_out_ram_delta);
assign data_point [NUMBER_OF_BACK_NODE] = 'h3F800000;

genvar m,n;
generate
	for (m=0; m<NUMBER_OF_FORWARD_NODE; m=m+1) begin: forward_node_generate
		for (n=0; n<NUMBER_OF_BACK_NODE+1; n=n+1) begin: back_node_generate
			update_weight_point
				#(	.DATA_WIDTH		(DATA_WIDTH),
					.LEARNING_RATE	(LEARNING_RATE)	//0.002
				)
				update_weight_point_gen
				(	.clk			(clk),
					.rst_n			(rst_n),
					.i_valid		(valid_in),
					.i_old_weight	(weight[m*(NUMBER_OF_BACK_NODE+1)+n]),
					.i_data_point	(data_point[n]),
					.i_delta		(delta[m]),
					.o_new_weight	(new_weight[m*(NUMBER_OF_BACK_NODE+1)+n]),
					.o_valid		(valid_out[m*(NUMBER_OF_BACK_NODE+1)+n])
				);
		end
	end
endgenerate

integer l;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
	end
	else begin
		for (l=0; l<((NUMBER_OF_BACK_NODE+1)*NUMBER_OF_FORWARD_NODE); l=l+1) begin
			if (valid_out[l]) begin
				ram_new_weight[l] <= new_weight[l];
			end
		end
		if (&valid_out) begin
			write_file <= 1;
			#1 $writememh(NEW_WEIGHT_FILE, ram_new_weight);
		end
		else write_file <= 0;
		if (write_file) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end

endmodule
