`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:38:05 PM
// Design Name: 
// Module Name: different_exponent
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
module different_exponent // 2 CLOCK
(
    input               clk, rstn, valid_in,
    input   [7:0]       exponentA, exponentB,
    output              valid_out, sign,
    output  [7:0]       different, larger_exponent      
//    input               clk, rstn, valid_in_init,
//    input   [7:0]       exponentA_init, exponentB_init,
//    output              valid_out, sign,
//    output  [7:0]       different, larger_exponent  
);      
    
//    reg                   valid_in;
//    reg   [7:0]          exponentA, exponentB;    
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            exponentA         <=  'b0;
//            exponentB         <=  'b0;
//            valid_in    <=  'b0;
//        end
//        else begin
//            valid_in<=  valid_in_init;
//            if (valid_in_init) begin
//                exponentA     <=  exponentA_init;
//                exponentB     <=  exponentB_init;
//            end
//            else begin
//                exponentA     <=  exponentA;
//                exponentB     <=  exponentB;
//            end
//        end
//    end
    

    wire                temp_carry_sub;
    wire    [7:0]       temp_value_sub;
    assign  {temp_carry_sub, temp_value_sub}  =   {1'b0, exponentA} - {1'b0, exponentB};
    
    reg                 valid_temp, carry_sub;
    reg     [7:0]       value_sub, exponent_max;
//    assign  exponent_max            =   carry_sub? exponentB : exponentA;
    
    reg                 temp_valid_out, temp_sign;
    reg     [7:0]       temp_larger_exponent, temp_different;
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_temp                  <=  'b0;
            carry_sub                   <=  'b0;
            value_sub                   <=  'b0;
            exponent_max                <=  'b0;
            
            temp_valid_out              <=  'b0;
            temp_sign                   <=  'b0;
            temp_larger_exponent        <=  'b0;
            temp_different              <=  'b0;  
                
        end
        else begin
            // STAGE 1 
            valid_temp      <=  valid_in;
            if (valid_in) begin:    STAGE1_VALID
                carry_sub                   <=  temp_carry_sub;
                value_sub                   <=  temp_value_sub;
                if (temp_carry_sub)
                    exponent_max          <=  exponentB;
                else
                    exponent_max          <=  exponentA;  
            end
            else begin:    STAGE1_NOT_VALID
                carry_sub                   <=  carry_sub;
                value_sub                   <=  value_sub;
                exponent_max                <=  exponent_max;
            end
            // STAGE 2
            temp_valid_out  <=  valid_temp;
            if (valid_temp) begin:    STAGE2_VALID
                temp_sign                   <=  carry_sub;
                temp_larger_exponent        <=  exponent_max;
                if (carry_sub)
                    temp_different          <=  -value_sub;
                else
                    temp_different          <=  value_sub;                    
            end
            else begin:    STAGE2_NOT_VALID
                temp_sign                   <=  temp_sign;
                temp_larger_exponent        <=  temp_larger_exponent;
                temp_different              <=  temp_different;            
            end
        end
    end
    assign  valid_out               =   temp_valid_out;
    assign  sign                    =   temp_sign;
    assign  different               =   temp_different;
    assign  larger_exponent         =   temp_larger_exponent;  
endmodule
