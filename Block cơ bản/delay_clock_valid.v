`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2022 18:11:13
// Design Name: 
// Module Name: delay_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module delay_clock
#(
    parameter DATA_WIDTH = 1,
	parameter N_CLOCKs = 4
)
(
    input clk,
	input rstn,
	input en,
	input [DATA_WIDTH-1:0] in,
	output [DATA_WIDTH-1:0] out
);
	//Registers for delay n clock(s)
	wire [DATA_WIDTH-1:0] tmp [0 : N_CLOCKs-1];
	//assign statement
	assign out = tmp[N_CLOCKs-1];

	//Generate instances
	genvar i;
	generate
        for (i = 0; i < N_CLOCKs; i=i+1) begin
            if(i == 0)  begin 
                n_dff
                #(
                    .NUMBER_BIT(DATA_WIDTH)
                ) register_nbit_
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(en),
                    .in(in),
                    .out(tmp[i])
                );
            end else begin 
                n_dff 
                #(
                    .NUMBER_BIT(DATA_WIDTH)
                ) register_nbit_
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(en),
                    .in(tmp[i-1]),
                    .out(tmp[i])
                );
            end
        end
	endgenerate
endmodule