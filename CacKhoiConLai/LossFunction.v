module LossFunction (
    input clk, 
    input rst_n,
    input valid_in, 
    input [31:0] gamma, 
    input [31:0] Qmax,
    input [31:0] reward,
    input [31:0] Q,
    
    output valid_out, 
    output  [31:0] TD
    
    );
    
	 reg o_valid;
	 reg [31:0] o_data;
    reg [31:0] reg_gamma, reg_Qmax,reg_reward, reg_Q;

    wire o_valid_mul,o_valid_add,o_valid_sub; 
    wire [31:0] o_mul, o_add, o_sub;
    
    //gamma*Q'max
    multiplier_floating_point32 mul // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(valid_in),
				.inA(gamma), 
				.inB(Qmax),
				.valid_out(o_valid_mul),
				.out_data(o_mul));
				
	//reward + gamma*Q'max			
    adder_floating_point32 add // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(o_valid_mul),
				.inA(o_mul), 
				.inB(reg_reward),
				.valid_out(o_valid_add),
				.out_data(o_add));
				
	//(reward + gamma*Q'max) - Q	
    adder_floating_point32 sub // 7 CLOCK
			(	.clk(clk),
				.rstn(rst_n), 
				.valid_in(o_valid_add),
				.inA(o_add), 
				.inB({~reg_Q[31], reg_Q[30:0]}),
				.valid_out(o_valid_sub),
				.out_data(o_sub));
				
				
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            o_valid   <= 'b0;
            o_data          <= 'b0;
        end 
        else begin 
				o_valid <= o_valid_sub;
				o_data 		 <= o_sub;
            if(valid_in) begin 
                reg_reward <= reward; 
                reg_Q <= Q;
            end 
        end 
    end 

	 assign valid_out = o_valid;
	 assign TD = o_data; 
endmodule
