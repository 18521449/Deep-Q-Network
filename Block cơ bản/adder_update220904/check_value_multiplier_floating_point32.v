`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2022 05:24:05 PM
// Design Name: 
// Module Name: check_value_multiplier_floating_point32
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


module check_value_multiplier_floating_point32
(
    input           clk, rstn,
    input   [31:0]  inA, inB,
//    input                       clk, rstn,
//    input   [DATA_WIDTH-1:0]    inA_init, inB_init,
    output  reg     zero_flag, inf_flag
    
);
    
//    reg    [DATA_WIDTH-1:0]    inA, inB;
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            inA         <=  'b0;
//            inB         <=  'b0;
//        end
//        else begin
//            inA     <=  inA_init;
//            inB     <=  inB_init;
//        end
//    end
    
    wire    inf_flagA, inf_flagB;
    wire    zero_flagA, zero_flagB;
    
    assign inf_flagA  = (inA[30:23]==8'b1111_1111)? 1'b1 : 1'b0;
    assign inf_flagB  = (inB[30:23]==8'b1111_1111)? 1'b1 : 1'b0;
    
    assign zero_flagA = (inA==32'b0)?        1'b1 : 1'b0;
    assign zero_flagB = (inB==32'b0)?        1'b1 : 1'b0;
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            inf_flag    <=  'b0;
            zero_flag   <=  'b0;
        end
        else begin
            inf_flag    <=  inf_flagA | inf_flagB;
            zero_flag   <=  zero_flagA | zero_flagB;      
        end
    end
endmodule