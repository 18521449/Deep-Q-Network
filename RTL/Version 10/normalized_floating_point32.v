`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:41:28 PM
// Design Name: 
// Module Name: normalized_floating_point32
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

module normalized_floating_point32 // 2 CLOCK
(
    input                   clk, rstn, valid_in, sign,
    input       [7:0]       larger_exponent,
    input       [24:0]      mantise_temp,
    output                  valid_out,
    output      [31:0]      out_data    
//    input               clk, rstn, valid_in_init, sign_init,
//    input   [7:0]       larger_exponent_init,
//    input   [24:0]      mantise_temp_init,
//    output              valid_out,
//    output  [31:0]      out_data    
);

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
    
    wire            sign_buffer;
    wire    [7:0]   larger_exponent_buffer;
    wire    [24:0]  mantise_buffer;
    
    delay_value#( 1, 2)  DELAY_SIGN     ( .clk(clk), .rstn(rstn), .in_data(sign), .out_data(sign_buffer));
    delay_value#( 8, 2)  DELAY_EXPONENT ( .clk(clk), .rstn(rstn), .in_data(larger_exponent), .out_data(larger_exponent_buffer));
    delay_value#( 25, 2) DELAY_MANTISE  ( .clk(clk), .rstn(rstn), .in_data(mantise_temp), .out_data(mantise_buffer));

    // STAGE 1
    wire            valid_out_LOD;
    wire    [24:0]  out_LOD;
    
    leading_one_detector
    #(
        25
    ) LOD (
        .clk(clk), .rstn(rstn), .valid_in(valid_in),
        .in_data(mantise_temp),
        .valid_out(valid_out_LOD),      
        .out_data(out_LOD)    
    );   
    
    // STAGE 2
    wire            valid_out_encoder;
    wire    [7:0]   out_encoder;
    
    encoder_25_for_floating_point32
    ENCODER (
        .clk(clk), .rstn(rstn), .valid_in(valid_out_LOD),
        .in_data(out_LOD),
        .valid_out(valid_out_encoder),
        .out_data(out_encoder)
    );
    
    // STAGE 3
    reg             sign_stage3, temp_valid_out;
    reg     [7:0]   exponent;
    reg     [23:0]  mantise;
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            temp_valid_out  <=  'b0;
            sign_stage3     <=  'b0;
            exponent        <=  'b0;
            mantise         <=  'b0;
        end
        else begin
            temp_valid_out   <=  valid_out_encoder;
            if (valid_out_encoder) begin
                sign_stage3        <=  sign_buffer;
                // INFINITE
                if (larger_exponent_buffer==8'b1111_1111) begin
                    exponent    <=  larger_exponent_buffer;
                    mantise     <=  'b0;
                end
                // SHIFT RIGHT
                else if (out_encoder[7]==1'b1) begin
                    exponent    <=  larger_exponent_buffer + 1'b1;
                    mantise     <=  mantise_buffer[24:1];
                end
                // ZERO
                else if (out_encoder[6]==1'b1) begin
                    exponent    <=  'b0;
                    mantise     <=  'b0;
                end
                // SHIFT LEFT
                else begin
                    exponent    <=  larger_exponent_buffer - out_encoder;
                    mantise     <=  mantise_buffer[23:0] << out_encoder;
                end
            end
            else begin
                sign_stage3     <=  sign_stage3;
                exponent        <=  exponent;
                mantise         <=  mantise;
            end
        end
    end
    
    assign  valid_out   = temp_valid_out;
    assign  out_data     = {sign_stage3, exponent, mantise[22:0]};
    
endmodule
//module normalized_floating_point32 // 2 CLOCK -> NOT GOOD FOR IMPLEMENT
//(
//    input               clk, rstn, valid_in, sign,
//    input   [7:0]       larger_exponent,
//    input   [24:0]      mantise_temp,
//    output              valid_out,
//    output  [31:0]      out_data    
////    input               clk, rstn, valid_in_init, sign_init,
////    input   [7:0]       larger_exponent_init,
////    input   [24:0]      mantise_temp_init,
////    output              valid_out,
////    output  [31:0]      out_data    
//);

////    reg                 valid_in, sign;
////    reg     [7:0]       larger_exponent;
////    reg     [24:0]      mantise_temp;    
    
////    always @ (posedge clk or negedge rstn) begin
////        if (!rstn) begin
////                valid_in            <=  'b0;
////                sign                <=  'b0;
////                larger_exponent     <=  'b0;
////                mantise_temp        <=  'b0;
////        end
////        else begin
////            valid_in    <=  valid_in_init;
////            if (valid_in_init) begin
////                valid_in            <=  valid_in_init;
////                sign                <=  sign_init;
////                larger_exponent     <=  larger_exponent_init;
////                mantise_temp        <=  mantise_temp_init;
////            end
////            else begin
////                valid_in            <=  valid_in;
////                sign                <=  sign;
////                larger_exponent     <=  larger_exponent;
////                mantise_temp        <=  mantise_temp;
////            end
////        end
////    end



//    reg     [1:0]       valid_temp;
//    reg     [1:0]       sign_temp;
//    reg     [7:0]       exponent_temp   [1:0];
    
//    reg     [7:0]       delta_exponent;
//    reg     [23:0]      real_mantise_temp;
    
//    reg     [23:0]      real_mantise;
    

//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            exponent_temp[0]    <=  'b0;
//            sign_temp           <=  'b0;
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
//                // LEFT ONE
//                if (mantise_temp[24]) begin
//                    delta_exponent      <=  8'b1000_0000;
//                    real_mantise_temp   <=  mantise_temp[24:1];
//                end
//                // EXACTLY
//                else if (mantise_temp[23]) begin
//                    delta_exponent      <=  8'd0;
//                    real_mantise_temp   <=  mantise_temp[23:0];
//                end
//                // RIGHT ONE
//                else if (mantise_temp[22]) begin
//                    delta_exponent      <=  8'd1;
//                    real_mantise_temp   <=  {mantise_temp[22:0], 1'b0};
//                end
//                // RIGHT TWO
//                else if (mantise_temp[21]) begin
//                    delta_exponent      <=  8'd2;
//                    real_mantise_temp   <=  {mantise_temp[21:0], 2'b0};
//                end
//                // RIGHT THREE
//                else if (mantise_temp[20]) begin
//                    delta_exponent      <=  8'd3;
//                    real_mantise_temp   <=  {mantise_temp[20:0], 3'b0};
//                end
//                // RIGHT FOUR
//                else if (mantise_temp[19]) begin
//                    delta_exponent      <=  8'd4;
//                    real_mantise_temp   <=  {mantise_temp[19:0], 4'b0};
//                end
//                // RIGHT FIVE
//                else if (mantise_temp[18]) begin
//                    delta_exponent      <=  8'd5;
//                    real_mantise_temp   <=  {mantise_temp[18:0], 5'b0};
//                end
//                // RIGHT SIX
//                else if (mantise_temp[17]) begin
//                    delta_exponent      <=  8'd6;
//                    real_mantise_temp   <=  {mantise_temp[17:0], 6'b0};
//                end
//                // RIGHT SEVEN
//                else if (mantise_temp[16]) begin
//                    delta_exponent      <=  8'd7;
//                    real_mantise_temp   <=  {mantise_temp[16:0], 7'b0};
//                end
//                // RIGHT EIGHT
//                else if (mantise_temp[15]) begin
//                    delta_exponent      <=  8'd8;
//                    real_mantise_temp   <=  {mantise_temp[15:0], 8'b0};
//                end
//                // RIGHT NIGHT
//                else if (mantise_temp[14]) begin
//                    delta_exponent      <=  8'd9;
//                    real_mantise_temp   <=  {mantise_temp[14:0], 9'b0};
//                end
//                // RIGHT TEN
//                else if (mantise_temp[13]) begin
//                    delta_exponent      <=  8'd10;
//                    real_mantise_temp   <=  {mantise_temp[13:0], 10'b0};
//                end
//                // RIGHT ELEVEN
//                else if (mantise_temp[12]) begin
//                    delta_exponent      <=  8'd11;
//                    real_mantise_temp   <=  {mantise_temp[12:0], 11'b0};
//                end
//                // RIGHT TWELE
//                else if (mantise_temp[11]) begin
//                    delta_exponent      <=  8'd12;
//                    real_mantise_temp   <=  {mantise_temp[11:0], 12'b0};
//                end
//                // RIGHT THIRTEEN
//                else if (mantise_temp[10]) begin
//                    delta_exponent      <=  8'd13;
//                    real_mantise_temp   <=  {mantise_temp[10:0], 13'b0};
//                end
//                // RIGHT FOURTEEN
//                else if (mantise_temp[9]) begin
//                    delta_exponent      <=  8'd14;
//                    real_mantise_temp   <=  {mantise_temp[9:0], 14'b0};
//                end
//                // RIGHT FIFTEEN
//                else if (mantise_temp[8]) begin
//                    delta_exponent      <=  8'd15;
//                    real_mantise_temp   <=  {mantise_temp[8:0], 15'b0};
//                end
//                // RIGHT SIXTEEN
//                else if (mantise_temp[7]) begin
//                    delta_exponent      <=  8'd16;
//                    real_mantise_temp   <=  {mantise_temp[7:0], 16'b0};
//                end
//                // RIGHT SEVENTEEN
//                else if (mantise_temp[6]) begin
//                    delta_exponent      <=  8'd17;
//                    real_mantise_temp   <=  {mantise_temp[6:0], 17'b0};
//                end
//                // RIGHT EIGHTEEN
//                else if (mantise_temp[5]) begin
//                    delta_exponent      <=  8'd18;
//                    real_mantise_temp   <=  {mantise_temp[5:0], 18'b0};
//                end
//                // RIGHT NINETEEN
//                else if (mantise_temp[4]) begin
//                    delta_exponent      <=  8'd19;
//                    real_mantise_temp   <=  {mantise_temp[4:0], 19'b0};
//                end
//                // RIGHT TWENTY
//                else if (mantise_temp[3]) begin
//                    delta_exponent      <=  8'd20;
//                    real_mantise_temp   <=  {mantise_temp[3:0], 20'b0};
//                end
//                // RIGHT TWENTY-ONE
//                else if (mantise_temp[2]) begin
//                    delta_exponent      <=  8'd21;
//                    real_mantise_temp   <=  {mantise_temp[2:0], 21'b0};
//                end
//                // RIGHT TWENTY-TWO
//                else if (mantise_temp[1]) begin
//                    delta_exponent      <=  8'd22;
//                    real_mantise_temp   <=  {mantise_temp[1:0], 22'b0};
//                end
//                // RIGHT TWENTY-THREE
//                else if (mantise_temp[0]) begin
//                    delta_exponent      <=  8'd23;
//                    real_mantise_temp   <=  {mantise_temp[0],   23'b0};
//                end
//                // RIGHT TWENTY-FOUR
//                else if (mantise_temp=='b0) begin
//                    delta_exponent      <=  8'b0100_0000;
//                    real_mantise_temp   <=  {24'b0};
//                end
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