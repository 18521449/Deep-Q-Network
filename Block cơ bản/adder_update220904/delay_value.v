`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:46:18 PM
// Design Name: 
// Module Name: delay_Value
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


module delay_value // NUM_CLOCK CLOCK
#(
    DATA_WIDTH  =   32,
    NUM_CLOCK   =   2    
)
(
    input                       clk, rstn,
    input   [DATA_WIDTH-1:0]    in_data,
    output  [DATA_WIDTH-1:0]    out_data
);
    wire    [DATA_WIDTH-1:0]    buffer_value    [NUM_CLOCK-1:0];

    genvar i;
    generate 
        for (i=0; i<NUM_CLOCK; i=i+1) begin: DELAY
            if (i==0)
                n_dff
                #(
                    DATA_WIDTH
                ) REG (
                    .clk(clk), .rstn(rstn), .en(1'b1),
                    .in_data(in_data),
                    .out_data(buffer_value[0])
                );
             else
                n_dff
                #(
                    DATA_WIDTH
                ) REG (
                    .clk(clk), .rstn(rstn), .en(1'b1),
                    .in_data(buffer_value[i-1]),
                    .out_data(buffer_value[i])
                );
        end
        
        assign  out_data     =   buffer_value[NUM_CLOCK-1];
    endgenerate
    
endmodule