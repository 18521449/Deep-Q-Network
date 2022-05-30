`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2022 02:59:13 PM
// Design Name: 
// Module Name: adder_floating_point32
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
/*
interface

adder_floating_point32
(
    .clk        (), 
    .rstn       (), 
    .valid_in   (),
    .inA        (), 
    .inB        (),
    .valid_out  (),
    .out_data   ()
);

*/

(* use_dsp="yes" *)
module adder_floating_point32  // 7 CLOCK
(
    input               clk, 
    input               rstn, 
    input               valid_in,
    input   [31:0]      inA, 
    input   [31:0]      inB,
    output              valid_out,
    output  [31:0]      out_data
);
    // UNPACK
    wire                signA, signB;
    wire    [7:0]       exponentA, exponentB;
    wire    [23:0]      mantiseA, mantiseB;
    
    assign  signA       =   inA[31];
    assign  signB       =   inB[31];
    assign  exponentA   =   inA[30:23];
    assign  exponentB   =   inB[30:23];
    assign  mantiseA    =   {1'b1, inA[22:0]};
    assign  mantiseB    =   {1'b1, inB[22:0]};
    
    wire    [1:0]       signA_temp, signB_temp;
    wire    [23:0]      mantiseA_buffer, mantiseB_buffer;
    
    
    delay_value#( 1, 2) DELAY_SIGN_A_1    ( .clk(clk), .rstn(rstn), .in_data(signA), .out_data(signA_temp[0]));
    delay_value#( 1, 2) DELAY_SIGN_B_1    ( .clk(clk), .rstn(rstn), .in_data(signB), .out_data(signB_temp[0]));
    ///// SIGN
    delay_value#( 24, 2) DELAY_MANTISE_A  ( .clk(clk), .rstn(rstn), .in_data(mantiseA), .out_data(mantiseA_buffer));
    delay_value#( 24, 2) DELAY_MANTISE_B  ( .clk(clk), .rstn(rstn), .in_data(mantiseB), .out_data(mantiseB_buffer));
    ///// EXPONENT    
    
    wire                valid_out_de, swap;
    wire    [7:0]       different, larger_exponent, temp_larrger_exponent;
    
    //---STAGE 1->2
    different_exponent // 2 CLOCK
    DIFFERENT_EXPONENT (
        .clk(clk), .rstn(rstn), .valid_in(valid_in),
        .exponentA(exponentA), .exponentB(exponentB),
        .valid_out(valid_out_de), .sign(swap),
        .different(different), .larger_exponent(larger_exponent)  
    );
    
    delay_value#( 8, 2) DELAY_LARGER_EXPONENT ( .clk(clk), .rstn(rstn), .in_data(larger_exponent), .out_data(temp_larrger_exponent));
    //---END STAGE 2
    ///// MANTISE 
    //---STAGE 3
    wire                valid_out_shift;
    wire                signA_buffer, signB_buffer;
    wire    [23:0]      inShift;
    wire    [23:0]      elementFirst_temp, elementFirst, elementSecond;
    
    assign  signA_temp[1]       =   swap? signB_temp[0] : signA_temp[0];
    assign  signB_temp[1]       =   swap? signA_temp[0] : signB_temp[0];
    
    delay_value#( 1, 1) DELAY_SIGN_A_2    ( .clk(clk), .rstn(rstn), .in_data(signA_temp[1]), .out_data(signA_buffer));
    delay_value#( 1, 1) DELAY_SIGN_B_2    ( .clk(clk), .rstn(rstn), .in_data(signB_temp[1]), .out_data(signB_buffer));
    
    assign  inShift             =   swap? mantiseA_buffer : mantiseB_buffer;
    assign  elementFirst_temp   =   swap? mantiseB_buffer : mantiseA_buffer;
    
    delay_value#( 24, 1) DELAY_ELEMENT_FIRST    ( .clk(clk), .rstn(rstn), .in_data(elementFirst_temp), .out_data(elementFirst));
    
    right_shifter32 // 1 CLOCK
    RIGHT_SHIFTER32 (
        .clk(clk), .rstn(rstn), .valid_in(valid_out_de),
        .shift(different),
        .in_data(inShift),
        .valid_out(valid_out_shift),
        .out_data(elementSecond)
    );
    //---END STAGE 3
    //--- STAGE 4-5
    wire                valid_out_add, sign_temp;
    wire    [24:0]      adder_value;
    
    adder_sub_for_floating_point32 // 2 CLOCK
    ADD_SUB_INSIDE (
        .clk(clk), .rstn(rstn), .valid_in(valid_out_shift),
        .signA(signA_buffer), .signB(signB_buffer),
        .mantise_M(elementFirst), .mantise_m(elementSecond),
        .valid_out(valid_out_add), .sign(sign_temp),
        .adder_value(adder_value) 
    );
    //---END STAGE 5
    //--- STAGE 6-7
    normalized_floating_point32
    NORM_VALUE_ADDER (
        .clk(clk), .rstn(rstn), .valid_in(valid_out_add), .sign(sign_temp),
        .larger_exponent(temp_larrger_exponent),
        .mantise_temp(adder_value),
        .valid_out(valid_out),
        .out_data(out_data)  
    );
    //---END STAGE 7
endmodule

//module normalized_floating_point32 ////// BAD RESOURCE AND FREQUENCE
//(
////    input               clk, rstn, valid_in, sign,
////    input   [7:0]       larger_exponent,
////    input   [24:0]      mantise_temp,
////    output              valid_out,
////    output  [31:0]      out_data    
//    input               clk, rstn, valid_in_init, sign_init,
//    input   [7:0]       larger_exponent_init,
//    input   [24:0]      mantise_temp_init,
//    output              valid_out,
//    output  [31:0]      out_data    
//);

//    reg                 valid_in, sign;
//    reg     [7:0]       larger_exponent;
//    reg     [24:0]      mantise_temp;    
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//                valid_in            <=  'b0;
//                sign                <=  'b0;
//                larger_exponent     <=  'b0;
//                mantise_temp        <=  'b0;
//        end
//        else begin
//            valid_in    <=  valid_in_init;
//            if (valid_in_init) begin
//                valid_in            <=  valid_in_init;
//                sign                <=  sign_init;
//                larger_exponent     <=  larger_exponent_init;
//                mantise_temp        <=  mantise_temp_init;
//            end
//            else begin
//                valid_in            <=  valid_in;
//                sign                <=  sign;
//                larger_exponent     <=  larger_exponent;
//                mantise_temp        <=  mantise_temp;
//            end
//        end
//    end



//    reg     [1:0]       valid_temp;
//    reg     [1:0]       sign_temp;
//    reg     [7:0]       exponent_temp   [1:0];
//    wire    [7:0]       exponent_sel;
    
//    wire    [23:0]      mantise_sel;
    
//    reg     [7:0]       delta_exponent;
//    reg     [23:0]      real_mantise_temp;
    
//    reg     [23:0]      real_mantise;
    
//    generate 
//        assign  mantise_sel    =   mantise_temp[24]?       mantise_temp[24:1]            : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[23]?       mantise_temp[23:0]            : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[22]?       {mantise_temp[22:0], 1'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[21]?       {mantise_temp[21:0], 2'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[20]?       {mantise_temp[20:0], 3'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[19]?       {mantise_temp[19:0], 4'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[18]?       {mantise_temp[18:0], 5'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[17]?       {mantise_temp[17:0], 6'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[16]?       {mantise_temp[16:0], 7'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[15]?       {mantise_temp[15:0], 8'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[14]?       {mantise_temp[14:0], 9'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[13]?       {mantise_temp[13:0], 10'b0}   : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[12]?       {mantise_temp[12:0], 11'b0}   : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[11]?       {mantise_temp[11:0], 12'b0}   : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[10]?       {mantise_temp[10:0], 13'b0}   : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[9]?        {mantise_temp[9:0], 14'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[8]?        {mantise_temp[8:0], 15'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[7]?        {mantise_temp[7:0], 16'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[6]?        {mantise_temp[6:0], 17'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[5]?        {mantise_temp[5:0], 18'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[4]?        {mantise_temp[4:0], 19'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[3]?        {mantise_temp[3:0], 20'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[2]?        {mantise_temp[2:0], 21'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[1]?        {mantise_temp[1:0], 22'b0}    : 24'hZ;
//        assign  mantise_sel    =   mantise_temp[0]?        {mantise_temp[0],   23'b0}    : 24'hZ;
//        assign  mantise_sel    =   {mantise_temp=='b0}?    {24'b0}                       : 24'hZ;
        
        
//        assign  exponent_sel     =   mantise_temp[24]?       8'b1000_000 : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[23]?       8'd0        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[22]?       8'd1        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[21]?       8'd2        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[20]?       8'd3        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[19]?       8'd4        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[18]?       8'd5        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[17]?       8'd6        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[16]?       8'd7        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[15]?       8'd8        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[14]?       8'd9        : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[13]?       8'd10       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[12]?       8'd11       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[11]?       8'd12       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[10]?       8'd13       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[9]?        8'd14       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[8]?        8'd15       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[7]?        8'd16       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[6]?        8'd17       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[5]?        8'd18       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[4]?        8'd19       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[3]?        8'd20       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[2]?        8'd21       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[1]?        8'd22       : 24'hZ;
//        assign  exponent_sel     =   mantise_temp[0]?        8'd23       : 24'hZ;
//        assign  exponent_sel     =   (mantise_temp==8'b0)?   8'b0100_000 : 24'hZ;
        
//    endgenerate
    

//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            exponent_temp[0]    <=  'b0;
//            valid_temp          <=  'b0;
//            delta_exponent      <=  'b0;
//            real_mantise_temp   <=  'b0;
            
//            exponent_temp[1]    <=  'b0;
//            real_mantise        <=  'b0;
//        end
//        else begin
//            valid_temp[0]       <=  valid_in;
//            if (valid_in) begin 
//                sign_temp[0]        <=  sign;
//                exponent_temp[0]    <=  larger_exponent;
//                delta_exponent      <=  exponent_sel;
//                real_mantise_temp   <=  mantise_sel;
//            end
//            else begin
//                sign_temp[0]        <=  sign_temp[0];
//                exponent_temp[0]    <=  exponent_temp[0];
//                delta_exponent      <=  delta_exponent;
//                real_mantise_temp   <=  real_mantise_temp;
//            end
            
//            valid_temp[1]   <=  valid_temp[0];
//            if (valid_temp[0]) begin
//                sign_temp[1]            <=  sign_temp[0];
//                real_mantise            <=  real_mantise_temp;
//                if (exponent_temp[0]==8'b1111_1111)
//                    exponent_temp[1]    <=  exponent_temp[0];
//                else if (delta_exponent[7]==1'b1)
//                    exponent_temp[1]    <=  exponent_temp[0] +  1'b1;  
//                else if (delta_exponent[6]==1'b1)
//                    exponent_temp[1]    <=  'b0;
//                else if (delta_exponent[6]<8'd32)
//                    exponent_temp[1]    <=  exponent_temp[0] - delta_exponent;  
//            end
//            else begin
//                sign_temp[1]        <=  sign_temp[1];
//                real_mantise        <=  real_mantise;
//                exponent_temp[1]    <=  exponent_temp[1];
//            end
//        end
//    end
    
//    assign  valid_out   =   valid_temp[1];
//    assign  out_data     =   {sign_temp[1], exponent_temp[1], real_mantise[22:0]};
//endmodule


//module two_complement // MACH TO HOP
//#(
//    NUMBER_BIT  =   8
//)
//(
//    input   [NUMBER_BIT-1:0]    in_data,
//    output  [NUMBER_BIT-1:0]    out_data
//);

//    assign  out_data     =   - in_data;
//endmodule
