module ann_loss_function 
	#(	parameter DATA_WIDTH 				= 32,
		parameter [DATA_WIDTH-1:0]	GAMMA	= 'h3F4CCCCD
	)
	(	clk,
		rst_n,
		i_q_max_valid,
		i_q_max,
		i_reward_valid,
		i_reward,
		i_done,
		o_loss_value,
		o_loss_value_valid
   );
    
   //-----------------input and output port-------------//
	input 								clk;
	input 								rst_n;
	input 								i_q_max_valid;
	input 		[DATA_WIDTH-1:0]		i_q_max;
	input 								i_reward_valid;
	input 		[DATA_WIDTH-1:0]		i_reward;
	input 								i_done;
	output reg	[DATA_WIDTH-1:0] 		o_loss_value;
	output reg							o_loss_value_valid;
	//---------------------------------------------------//
   
	//---------------------------------------------------//
	wire 		[DATA_WIDTH-1:0]		data_out_mul;
	wire 								valid_out_mul;
	wire 		[DATA_WIDTH-1:0]		loss_value;
	wire 								loss_value_valid;
	reg 		[DATA_WIDTH-1:0]		data_out_mul_reg;
	reg 		[DATA_WIDTH-1:0]		reward;
	reg 								reward_active;
	reg 								q_max_active;
	reg 								done;
	reg 								valid_in_add;
	//---------------------------------------------------//
    
    //gamma*Q'max
	multiplier_floating_point32 mul // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(i_q_max_valid),
			.inA			(i_q_max), 
			.inB			(GAMMA),
			.valid_out		(valid_out_mul),
			.out_data		(data_out_mul));
		
	//reward + gamma*Q'max			
   adder_floating_point32 add // 7 CLOCK
		(	.clk			(clk),
			.rstn			(rst_n), 
			.valid_in		(valid_in_add),
			.inA			(data_out_mul_reg), 
			.inB			(reward),
			.valid_out		(loss_value_valid),
			.out_data		(loss_value));

	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin 
			done 				<= 0;
			reward 				<= 'd0;
			data_out_mul_reg 	<= 'd0;
			reward_active 		<= 0;
			q_max_active 		<= 0;
		end 
		else begin 
			if (i_reward_valid) begin
				reward 			<= i_reward;
				done			<= i_done;
				reward_active 	<= 1;
			end
			
			if (valid_out_mul) begin
				data_out_mul_reg 	<= data_out_mul;
				q_max_active 		<= 1;
			end
			
			if (reward_active & q_max_active) begin
				valid_in_add 	<= 1;
				reward_active 	<= 0;
				q_max_active 	<= 0;
			end
			else valid_in_add <= 0;
			
			if (loss_value_valid) begin
				o_loss_value_valid <= 1;
				if (done)
					o_loss_value <= reward;
				else o_loss_value <= loss_value;
			end
			else o_loss_value_valid <= 0;
		end 
	end 

endmodule