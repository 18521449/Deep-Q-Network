`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:40:18 PM
// Design Name: 
// Module Name: adder_sub_for_floating_point32
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


//module adder_sub_for_floating_point32 // 1 CLOCK
//(
////    input               clk, rstn, valid_in,
////    input               swap, signA, signB,
////    input   [23:0]      mantise_M, mantise_m,
////    output              valid_out, sign,
////    output  [24:0]      adder_value 
//    input               clk, rstn, valid_in_init,
//    input               swap_init, signA_init, signB_init,
//    input   [23:0]      mantise_M_init, mantise_m_init,
//    output              valid_out, sign,
//    output  [24:0]      adder_value 
//);

//    reg                  valid_in, swap, signA, signB;
//    reg   [23:0]         mantise_M, mantise_m;    
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//                valid_in    <=  'b0;
//                swap        <=  'b0;
//                signA       <=  'b0;
//                signB       <=  'b0;
//                mantise_M   <=  'b0;
//                mantise_m   <=  'b0;   
//        end
//        else begin
//            valid_in<=  valid_in_init;
//            if (valid_in_init) begin
//                valid_in    <=  valid_in_init;
//                swap        <=  swap_init;
//                signA       <=  signA_init;
//                signB       <=  signB_init;
//                mantise_M   <=  mantise_M_init;
//                mantise_m   <=  mantise_m_init;   
//            end
//            else begin
//                valid_in    <=  valid_in;
//                swap        <=  swap;
//                signA       <=  signA;
//                signB       <=  signB;
//                mantise_M   <=  mantise_M;
//                mantise_m   <=  mantise_m; 
//            end
//        end
//    end


//    wire                checkSign, checkMantise, controlAdder; 
//    reg                 valid_temp, sign_temp;
//    reg     [24:0]      temp_adder_value;
    
////    assign  checkSign           =   ((~swap & signA) | (swap & signB)); // KARNAUGH
//    assign  checkSign           =   swap?   signB : signA;
//    assign  controlAdder        =   signA ^ signB;
//    assign  checkMantise        =   (mantise_M<mantise_m)? 1'b1 : 1'b0;
    
//    always @ (posedge clk or negedge rstn) begin
//        if(!rstn) begin
//            valid_temp          <=  'b0;
//            temp_adder_value    <=  'b0;
//            sign_temp           <=  'b0;
//        end
//        else begin
//            //--- STAGE 4
//            valid_temp    <=  valid_in;
//            if (valid_in) begin
//                sign_temp   <= checkSign;
//                if (controlAdder)
//                    if (checkMantise)
//                        temp_adder_value    <= {1'b0, mantise_m}  - {1'b0, mantise_M};
//                    else    
//                        temp_adder_value    <= {1'b0, mantise_M}  - {1'b0, mantise_m};
//                else
//                    temp_adder_value    <= {1'b0, mantise_m}  + {1'b0, mantise_M};         
//            end
//            else begin
//                sign_temp    <=  sign_temp;
//                temp_adder_value     <=  temp_adder_value;
//            end
//        end
//    end
    
//    assign  valid_out   =   valid_temp;
//    assign  sign        =   sign_temp;
//    assign  adder_value =   temp_adder_value;
    
//endmodule



module adder_sub_for_floating_point32 // 1 CLOCK
(
    input               clk, rstn, valid_in,
    input               signA, signB,
    input   [23:0]      mantise_M, mantise_m,
    output              valid_out, sign,
    output  [24:0]      adder_value 
//    input               clk, rstn, valid_in_init,
//    input               signA_init, signB_init,
//    input   [23:0]      mantise_M_init, mantise_m_init,
//    output              valid_out, sign,
//    output  [24:0]      adder_value 
);

//    reg                  valid_in, signA, signB;
//    reg   [23:0]         mantise_M, mantise_m;    
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//                valid_in    <=  'b0;
//                signA       <=  'b0;
//                signB       <=  'b0;
//                mantise_M   <=  'b0;
//                mantise_m   <=  'b0;   
//        end
//        else begin
//            valid_in<=  valid_in_init;
//            if (valid_in_init) begin
//                signA       <=  signA_init;
//                signB       <=  signB_init;
//                mantise_M   <=  mantise_M_init;
//                mantise_m   <=  mantise_m_init;   
//            end
//            else begin
//                signA       <=  signA;
//                signB       <=  signB;
//                mantise_M   <=  mantise_M;
//                mantise_m   <=  mantise_m; 
//            end
//        end
//    end


    wire                signCal, lessThan, different; 
    wire    [24:0]      addAB, subAB, subBA;
    reg                 valid_temp, sign_temp;
    reg     [24:0]      temp_adder_value;
    
    assign  different       =   signA ^ signB;
    assign  lessThan        =   ({1'b0, mantise_M} < {1'b0, mantise_m})? 1'b1 : 1'b0;
    assign  signCal         =   (different)? ((lessThan)? signB : signA) : signA;  
    
    assign  addAB           =   {1'b0, mantise_M} + {1'b0, mantise_m};
    assign  subAB           =   {1'b0, mantise_M} - {1'b0, mantise_m};
    assign  subBA           =   {1'b0, mantise_m} - {1'b0, mantise_M};
    
    always @ (posedge clk or negedge rstn) begin
        if(!rstn) begin
            valid_temp          <=  'b0;
            temp_adder_value    <=  'b0;
            sign_temp           <=  'b0;
        end
        else begin
            //--- STAGE 4
            valid_temp    <=  valid_in;
            if (valid_in) begin
                sign_temp   <= signCal;
                if (!different) begin
                    temp_adder_value      =   addAB;
                end
                else begin
                    if (lessThan)
                        temp_adder_value  =   subBA;
                    else
                        temp_adder_value  =   subAB;
                end        
            end
            else begin
                sign_temp           <=  sign_temp;
                temp_adder_value    <=  temp_adder_value;
            end
        end
    end
    
    assign  valid_out   =   valid_temp;
    assign  sign        =   sign_temp;
    assign  adder_value =   temp_adder_value;
    
endmodule
