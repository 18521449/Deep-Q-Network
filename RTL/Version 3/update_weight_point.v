`timescale 1ns/1ps
module update_weight_point
	#(	parameter DATA_WIDTH 						= 32,
		parameter [DATA_WIDTH-1:0] LEARNING_RATE 	= 'h3B03126F	//0.002
	)
	(	clk,
		rst_n,
		i_valid,
		i_old_weight,
		i_data_point,
		i_delta,
		o_new_weight,
		o_valid
	);
//-----------------input and output port-------------//
input 								clk;
input 								rst_n;
input 								i_valid;
input 		[DATA_WIDTH-1:0]		i_old_weight;
input 		[DATA_WIDTH-1:0]		i_data_point;
input 		[DATA_WIDTH-1:0]		i_delta;
output 		[DATA_WIDTH-1:0] 		o_new_weight;
output 	 							o_valid;
//---------------------------------------------------//


//--------------------------------------------------------------------------------------//
wire 		[DATA_WIDTH-1:0]		error;
wire 		[DATA_WIDTH-1:0]		data_out_lr;
reg 		[DATA_WIDTH-1:0]		old_weight;
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
wire valid_out_error, valid_out_lr;
//--------------------------------------------------------------------------------------//

multiplier_floating_point32 mul_node // 7 CLOCK
	(	.clk		(clk),
		.rstn		(rst_n), 
		.valid_in	(i_valid),
		.inA		(i_delta), 
		.inB		(i_data_point),
		.valid_out	(valid_out_error),
		.out_data	(error));

multiplier_floating_point32 mul_lr // 7 CLOCK
	(	.clk		(clk),
		.rstn		(rst_n), 
		.valid_in	(valid_out_error),
		.inA		(error), 
		.inB		(LEARNING_RATE),
		.valid_out	(valid_out_lr),
		.out_data	(data_out_lr));
		
adder_floating_point32 sub_weight // 7 CLOCK
	(	.clk		(clk),
		.rstn		(rst_n), 
		.valid_in	(valid_out_lr),
		.inA		(old_weight), 
		.inB		({~data_out_lr[DATA_WIDTH-1], data_out_lr[DATA_WIDTH-2:0]}),
		.valid_out	(o_valid),
		.out_data	(o_new_weight));


integer n;
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		old_weight <= 'd0;
	end
	else begin
		if (i_valid) begin
			old_weight <= i_old_weight;
		end
	end
end

endmodule
