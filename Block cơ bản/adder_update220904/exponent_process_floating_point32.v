`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2022 06:27:38 PM
// Design Name: 
// Module Name: exponent_process_floating_point32
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


module exponent_process_floating_point32 // 6 CLOCK WITH SIGNAL ASYN high_bit_from_mantise_process
(
    input                   clk, rstn, valid_in,
    input                   high_bit_from_mantise_process,
    input       [7:0]       exponentA, exponentB,
    output                  valid_out,
    output                  zero_flag_from_exponent, inf_flag_from_exponent,
    output  reg [7:0]       exponent
);   
    reg     [5:0]       valid_stage;
    reg     [4:0]       zero_flag;
    
    reg     [9:0]       sum_exponent;
    reg     [9:0]       sum_exponent_sub_127    [2:0];            
    reg     [9:0]       sum_exponent_sub_127_add_1;
    reg                 inf_flag;
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
                valid_stage                 <=  'b0;
                sum_exponent                <=  'b0;
                zero_flag     <=  'b0;
                inf_flag      <=  'b0;
                sum_exponent_sub_127[0]     <=  'b0;
                sum_exponent_sub_127[1]     <=  'b0;
                sum_exponent_sub_127[2]     <=  'b0;
                sum_exponent_sub_127_add_1  <=  'b0;
                exponent                    <=  'b0;
        end
        else begin
            // STAGE 1
                valid_stage[0]              <=  valid_in;  
            if (valid_in) begin
                sum_exponent                <=  {2'b0, exponentA} + {2'b0 + exponentB};
            end
            else begin
                sum_exponent                <=  sum_exponent;
            end
            
            // STAGE 2
                valid_stage[1]              <=  valid_stage[0];
            if (valid_stage[0]) begin
                {zero_flag[0], sum_exponent_sub_127[0]}  <=   sum_exponent - 10'd127;
            end
            else begin
                {zero_flag[0], sum_exponent_sub_127[0]}  <=  {zero_flag[0], sum_exponent_sub_127[0]};
            end
            
            // STAGE 3
                valid_stage[2]              <=  valid_stage[1];
            if (valid_stage[1]) begin
                {zero_flag[1], sum_exponent_sub_127[1]}  <=   {zero_flag[0], sum_exponent_sub_127[0]};
            end
            else begin
                {zero_flag[1], sum_exponent_sub_127[1]}  <=   {zero_flag[1], sum_exponent_sub_127[1]};
            end    
            
            // STAGE 4
                valid_stage[3]              <=  valid_stage[2];
            if (valid_stage[2]) begin
                {zero_flag[2], sum_exponent_sub_127[2]}  <=   {zero_flag[1], sum_exponent_sub_127[1]};
            end
            else begin
                {zero_flag[2], sum_exponent_sub_127[2]}  <=   {zero_flag[2], sum_exponent_sub_127[2]};
            end    
                
            // STAGE 5
                valid_stage[4]              <=  valid_stage[3];
            if (valid_stage[3]) begin
                zero_flag[3]  <=  zero_flag[2];
                if (high_bit_from_mantise_process)
                    sum_exponent_sub_127_add_1    <=  sum_exponent_sub_127[2] + 1'b1;
                else
                    sum_exponent_sub_127_add_1    <=  sum_exponent_sub_127[2];
            end
            else begin
                {zero_flag[3], sum_exponent_sub_127_add_1}  <=   {zero_flag[3], sum_exponent_sub_127_add_1};
            end 
            
            // STAGE 6
                valid_stage[5]              <=  valid_stage[4];
            if (valid_stage[4]) begin
                zero_flag[4]  <=  zero_flag[3];
                if (sum_exponent_sub_127_add_1 > 10'd254)
                    inf_flag  <=  1'b1;
                else
                    inf_flag  <=  1'b0;
                exponent    <=  sum_exponent_sub_127_add_1[7:0];
            end
            else begin
                {zero_flag[4], inf_flag, exponent}  <=   {zero_flag[4], inf_flag, exponent};
            end 
        end      
    end
    
    assign  valid_out               =   valid_stage[5];
    assign  zero_flag_from_exponent =   zero_flag[4];
    assign  inf_flag_from_exponent  =   inf_flag;
endmodule