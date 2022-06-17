`timescale 1ns/1ps
module replay_memory
	#(	parameter DATA_WIDTH 		= 32,
		parameter MEMORY_WIDTH		= 10000,
		parameter BATCH_SIZE		= 128,
		parameter ACTION_WIDTH		= 2
	)
	(	clk,
		rst_n,
		i_valid,
		i_current_state_0,
		i_current_state_1,
		i_action,
		i_reward,
		i_next_state_0,
		i_next_state_1,
		i_done,
		i_main_net_done,
		o_valid,	
		o_current_state_0,
		o_current_state_1,
		o_action,
		o_reward,
		o_next_state_0,
		o_next_state_1,
		o_done,
		o_train_mode,
		o_update_request
	);
	
	localparam MEMORY_ADDR_WIDTH = $clog2(MEMORY_WIDTH);
	localparam MINI_BATCH_WIDTH = $clog2(BATCH_SIZE);
	
	//------------------------input and output port-----------------------//
	input										clk;
	input 										rst_n;
	input										i_valid;
	input		[DATA_WIDTH-1:0]				i_current_state_0;
	input		[DATA_WIDTH-1:0]				i_current_state_1;
	input		[ACTION_WIDTH-1:0]				i_action;
	input		[DATA_WIDTH-1:0]				i_reward;
	input		[DATA_WIDTH-1:0]				i_next_state_0;
	input		[DATA_WIDTH-1:0]				i_next_state_1;
	input										i_done;
	input										i_main_net_done;
	output  									o_valid;
	output 		[DATA_WIDTH-1:0]				o_current_state_0;
	output 		[DATA_WIDTH-1:0]				o_current_state_1;
	output 		[ACTION_WIDTH-1:0]				o_action;
	output  	[DATA_WIDTH-1:0]				o_reward;
	output  	[DATA_WIDTH-1:0]				o_next_state_0;
	output  	[DATA_WIDTH-1:0]				o_next_state_1;
	output  									o_done;
	output reg									o_train_mode;
	output reg 									o_update_request;
	//--------------------------------------------------------------------//
	
	//----------------------------------------------------------------------//
	reg 										finite_state_machine;
	//----------------------------------------------------------------------//
	
	//----------------------------------------------------------------------//
	reg 										ram_i_valid;
	reg 										ram_i_rw_select;
	reg 		[MEMORY_ADDR_WIDTH-1:0]			ram_i_addr;
	reg			[DATA_WIDTH-1:0]				ram_i_current_state_0;
	reg			[DATA_WIDTH-1:0]				ram_i_current_state_1;
	reg			[ACTION_WIDTH-1:0]				ram_i_action;
	reg			[DATA_WIDTH-1:0]				ram_i_reward;
	reg			[DATA_WIDTH-1:0]				ram_i_next_state_0;
	reg			[DATA_WIDTH-1:0]				ram_i_next_state_1;
	reg											ram_i_done;
	reg 		[MEMORY_ADDR_WIDTH-1:0]			counter_write_addr;
	reg 		[MINI_BATCH_WIDTH-1:0]			mini_batch_counter;
	reg 										ram_full_flags;
	reg 										read_enable;
	reg 										ready_for_train;
	//----------------------------------------------------------------------//
	
	//----------------------------------------------------------------------//
	reg 										random_i_enable;
	wire 		[MEMORY_ADDR_WIDTH-1:0]			random_read_addr;
	wire 		[23-1:0]						random_o_data;	
	//----------------------------------------------------------------------//
	
	
	random_galois_23bit random_23bit_block
	(	.clk			(clk),
		.rst_n			(rst_n),
		.i_enable		(random_i_enable),
		.o_random_data	(random_o_data)
	);
	
	assign random_read_addr = random_o_data [MEMORY_ADDR_WIDTH-1:0];
	
	block_ram_replay 
	#(	.DATA_WIDTH				(DATA_WIDTH),
		.MEMORY_WIDTH			(MEMORY_WIDTH),
		.ACTION_WIDTH			(ACTION_WIDTH)
	)
	ram_replay_block
	(	.clk					(clk),
		.i_valid				(ram_i_valid),
		.i_rw_select			(ram_i_rw_select), // 0: write, 1: read
		.i_addr					(ram_i_addr),
		.i_current_state_0		(ram_i_current_state_0),
		.i_current_state_1		(ram_i_current_state_1),
		.i_action				(ram_i_action),
		.i_reward				(ram_i_reward),
		.i_next_state_0			(ram_i_next_state_0),
		.i_next_state_1			(ram_i_next_state_1),
		.i_done					(ram_i_done),
		.o_valid				(o_valid),	
		.o_current_state_0		(o_current_state_0),
		.o_current_state_1		(o_current_state_1),
		.o_action				(o_action),
		.o_reward				(o_reward),
		.o_next_state_0			(o_next_state_0),
		.o_next_state_1			(o_next_state_1),
		.o_done					(o_done)
	);
	
	initial begin
		counter_write_addr 	<= 'd0;
		ready_for_train 	<= 0;
		ram_full_flags		<= 0;
		o_train_mode		<= 0;
	end
	
	integer i;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			ram_full_flags 		<= 0;
			counter_write_addr 	<= 'd0;
			ready_for_train 	<= 0;
		end
		else begin
		
			// FINITE STATE MACHINE
			case(finite_state_machine)
				1'b0: // interactive mode
					begin 
						ram_i_valid 			<= i_valid;
						ram_i_rw_select 		<= 0;
						ram_i_addr				<= counter_write_addr;
						ram_i_current_state_0 	<= i_current_state_0;
						ram_i_current_state_1 	<= i_current_state_1;
						ram_i_action			<= i_action;
						ram_i_reward			<= i_reward;
						ram_i_next_state_0		<= i_next_state_0;
						ram_i_next_state_1		<= i_next_state_1;
						ram_i_done				<= i_done;
						
						if (i_done & ready_for_train) begin					// Train mode
							mini_batch_counter <= 'd0;
							read_enable	  <= 1;
							o_train_mode  <= 1;
							finite_state_machine <= 1'b1;
						end
						else o_train_mode <= 0;
						
						if (i_valid) begin
							if (counter_write_addr < 'd10000) begin
								counter_write_addr 	<= counter_write_addr + 1;
							end
							else begin
								counter_write_addr 	<= 'd0;
								ram_full_flags 		<= 1;
							end
						end
						
						if (counter_write_addr > 'd998) begin
							ready_for_train <= 1;
						end
						
					end
				1'b1: // train mode
					begin

						if (read_enable) begin
							random_i_enable <= 1;
							
							if (ram_full_flags) begin
							
								if (random_read_addr < 'd10000) begin
									ram_i_valid			<= 1;
									ram_i_rw_select 	<= 1;
									ram_i_addr			<= random_read_addr;
									read_enable 		<= 0;
									mini_batch_counter	<= mini_batch_counter + 1;
								end
								else ram_i_valid	<= 0;
								
							end
							else begin
							
								if (random_read_addr < counter_write_addr) begin
									ram_i_valid			<= 1;
									ram_i_rw_select 	<= 1;
									ram_i_addr			<= random_read_addr;
									read_enable 		<= 0;
									mini_batch_counter 	<= mini_batch_counter + 1;
								end
								else ram_i_valid	<= 0;
								
							end
						end
						else begin
							random_i_enable <= 0;
							ram_i_valid	<= 0;
						end
						
						if (i_main_net_done) begin
							if (mini_batch_counter < BATCH_SIZE) begin
								read_enable <= 1;
								o_update_request <= 0;
							end
							else begin
								mini_batch_counter 	 <= 'd0;
								o_train_mode 		 <= 0;
								read_enable 		 <= 0;
								o_update_request 	 <= 1;
								finite_state_machine <= 1'b0;
							end
						end
						
					end
				default: finite_state_machine <= 1'b0;
			endcase
			
		end
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