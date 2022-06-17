`timescale 1ns/1ps
module block_ram_replay
	#(	parameter DATA_WIDTH 		= 32,
		parameter MEMORY_WIDTH		= 10000,
		parameter ACTION_WIDTH		= 2
	)
	(	clk,
		i_valid,
		i_rw_select, // 0: write, 1: read
		i_addr,
		i_current_state_0,
		i_current_state_1,
		i_action,
		i_reward,
		i_next_state_0,
		i_next_state_1,
		i_done,
		o_valid,	
		o_current_state_0,
		o_current_state_1,
		o_action,
		o_reward,
		o_next_state_0,
		o_next_state_1,
		o_done
	);
	
	localparam MEMORY_ADDR_WIDTH = $clog2(MEMORY_WIDTH);
	
	//------------------------input and output port-----------------------//
	input										clk;
	input										i_valid;
	input 										i_rw_select;
	input		[MEMORY_ADDR_WIDTH-1:0]			i_addr;
	input		[DATA_WIDTH-1:0]				i_current_state_0;
	input		[DATA_WIDTH-1:0]				i_current_state_1;
	input		[ACTION_WIDTH-1:0]				i_action;
	input		[DATA_WIDTH-1:0]				i_reward;
	input		[DATA_WIDTH-1:0]				i_next_state_0;
	input		[DATA_WIDTH-1:0]				i_next_state_1;
	input										i_done;
	output reg 									o_valid;
	output reg	[DATA_WIDTH-1:0]				o_current_state_0;
	output reg	[DATA_WIDTH-1:0]				o_current_state_1;
	output reg	[ACTION_WIDTH-1:0]				o_action;
	output reg	[DATA_WIDTH-1:0]				o_reward;
	output reg	[DATA_WIDTH-1:0]				o_next_state_0;
	output reg	[DATA_WIDTH-1:0]				o_next_state_1;
	output reg									o_done;
	//--------------------------------------------------------------------//
	
	//----------------------------------------------------------------------//
	(* RAM_STYLE="BLOCK" *)
	reg [DATA_WIDTH-1:0] 		ram_current_state_0 	[MEMORY_WIDTH-1:0];
	reg [DATA_WIDTH-1:0] 		ram_current_state_1 	[MEMORY_WIDTH-1:0];
	reg [ACTION_WIDTH-1:0] 		ram_action 				[MEMORY_WIDTH-1:0];
	reg [DATA_WIDTH-1:0] 		ram_reward 				[MEMORY_WIDTH-1:0];
	reg [DATA_WIDTH-1:0] 		ram_next_state_0		[MEMORY_WIDTH-1:0];
	reg [DATA_WIDTH-1:0] 		ram_next_state_1		[MEMORY_WIDTH-1:0];
	reg 						ram_done				[MEMORY_WIDTH-1:0];			
	//----------------------------------------------------------------------//
	
	integer i;
	always @(posedge clk) begin
		if (i_valid) begin
			if (i_rw_select) begin	// read
				o_valid				<= 1;
				o_current_state_0 	<= ram_current_state_0	[i_addr];
				o_current_state_1 	<= ram_current_state_1	[i_addr];
				o_action			<= ram_action			[i_addr];
				o_reward			<= ram_reward			[i_addr];
				o_next_state_0		<= ram_next_state_0		[i_addr];
				o_next_state_1		<= ram_next_state_1		[i_addr];
				o_done				<= ram_done				[i_addr];
			end
			else begin	// write
				ram_current_state_0	[i_addr] <= i_current_state_0;
				ram_current_state_1	[i_addr] <= i_current_state_1;
				ram_action			[i_addr] <= i_action;
				ram_reward			[i_addr] <= i_reward;
				ram_next_state_0	[i_addr] <= i_next_state_0;
				ram_next_state_1	[i_addr] <= i_next_state_1;
				ram_done			[i_addr] <= i_done;
			end
		end
		else o_valid <= 0;
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