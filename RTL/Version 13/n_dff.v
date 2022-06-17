`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2022 18:05:03
// Design Name: 
// Module Name: n_dff
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


module n_dff // 1 CLOCK
#(
    parameter DATA_WIDTH  =   32
)
(
    input                       clk,
    input                       rstn, 
    input                       en,
    input   [DATA_WIDTH-1:0]    in_data,
    output  [DATA_WIDTH-1:0]    out_data
);
    reg     [DATA_WIDTH-1:0]    X;
        
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            X   <=  1'b0;
        end
        else begin
            if(en)  
                X   <=  in_data;
            else 
                X   <=  X;    
        end
    end
    
    assign  out_data =   X;
endmodule