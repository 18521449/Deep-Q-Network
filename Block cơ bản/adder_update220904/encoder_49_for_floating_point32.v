`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2022 03:41:06 PM
// Design Name: 
// Module Name: encoder_25_for_floating_point32
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
module encoder_49_for_floating_point32 // 1 CLOCK
(
    input               clk, rstn, 
    input               valid_in,
    input       [48:0]  in_data,
//    input               valid_in_init,
//    input       [48:0]  in_data_init,
    output  reg         valid_out,
    output  reg [7:0]   out_data
);
    
//    reg         [48:0]  in_data;
//    reg                 valid_in;

//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            in_data     <=  'b0;
//            valid_in    <=  'b0;
//        end
//        else begin
//            valid_in    <=  valid_in_init;
//            in_data     <=  in_data_init;
//        end
//    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_data    <=  'b0;
            valid_out   <=  'b0;
        end
        else begin
            valid_out   <=  valid_in;
            if (valid_in) begin
                case (in_data)
                    // SHIFT RIGHT 1
                    49'h1_0000_0000_0000:  out_data  <=  8'h80;
                    // SHIFT LEFT 47
                    49'h0_0000_0000_0001:  out_data  <=  8'd47;
                    49'h0_0000_0000_0002:  out_data  <=  8'd46;
                    49'h0_0000_0000_0004:  out_data  <=  8'd45;
                    49'h0_0000_0000_0008:  out_data  <=  8'd44;

                    49'h0_0000_0000_0010:  out_data  <=  8'd43;
                    49'h0_0000_0000_0020:  out_data  <=  8'd42;
                    49'h0_0000_0000_0040:  out_data  <=  8'd41;
                    49'h0_0000_0000_0080:  out_data  <=  8'd40;
                    
                    49'h0_0000_0000_0100:  out_data  <=  8'd39;
                    49'h0_0000_0000_0200:  out_data  <=  8'd38;
                    49'h0_0000_0000_0400:  out_data  <=  8'd37;
                    49'h0_0000_0000_0800:  out_data  <=  8'd36;
                    
                    49'h0_0000_0000_1000:  out_data  <=  8'd35;
                    49'h0_0000_0000_2000:  out_data  <=  8'd34;
                    49'h0_0000_0000_4000:  out_data  <=  8'd33;
                    49'h0_0000_0000_8000:  out_data  <=  8'd32;

                    49'h0_0000_0001_0000:  out_data  <=  8'd31;
                    49'h0_0000_0002_0000:  out_data  <=  8'd30;
                    49'h0_0000_0004_0000:  out_data  <=  8'd29;
                    49'h0_0000_0008_0000:  out_data  <=  8'd28;
                    
                    49'h0_0000_0010_0000:  out_data  <=  8'd27;
                    49'h0_0000_0020_0000:  out_data  <=  8'd26;
                    49'h0_0000_0040_0000:  out_data  <=  8'd25;
                    49'h0_0000_0080_0000:  out_data  <=  8'd24;
                    
                    49'h0_0000_0100_0000:  out_data  <=  8'd23;
                    49'h0_0000_0200_0000:  out_data  <=  8'd22;
                    49'h0_0000_0400_0000:  out_data  <=  8'd21;
                    49'h0_0000_0800_0000:  out_data  <=  8'd20;
                    
                    49'h0_0000_1000_0000:  out_data  <=  8'd19;
                    49'h0_0000_2000_0000:  out_data  <=  8'd18;
                    49'h0_0000_4000_0000:  out_data  <=  8'd17;
                    49'h0_0000_8000_0000:  out_data  <=  8'd16;
             
                    49'h0_0001_0000_0000:  out_data  <=  8'd15;
                    49'h0_0002_0000_0000:  out_data  <=  8'd14;
                    49'h0_0004_0000_0000:  out_data  <=  8'd13;
                    49'h0_0008_0000_0000:  out_data  <=  8'd12;

                    49'h0_0010_0000_0000:  out_data  <=  8'd11;
                    49'h0_0020_0000_0000:  out_data  <=  8'd10;
                    49'h0_0040_0000_0000:  out_data  <=  8'd09;
                    49'h0_0080_0000_0000:  out_data  <=  8'd08;
                    
                    49'h0_0100_0000_0000:  out_data  <=  8'd07;
                    49'h0_0200_0000_0000:  out_data  <=  8'd06;
                    49'h0_0400_0000_0000:  out_data  <=  8'd05;
                    49'h0_0800_0000_0000:  out_data  <=  8'd04;
                    
                    49'h0_1000_0000_0000:  out_data  <=  8'd03;
                    49'h0_2000_0000_0000:  out_data  <=  8'd02;
                    49'h0_4000_0000_0000:  out_data  <=  8'd01;
                    49'h0_8000_0000_0000:  out_data  <=  8'd00;
                    
                    default:               out_data  <=  8'h40; 
                endcase
            end
            else begin
                out_data    <=  out_data;
            end
        end
    end
endmodule

































//module encoder_25_for_floating_point32 // 1 CLOCK
//(
//    input               clk, rstn, valid_in,
//    input       [24:0]  in_data,
////    input               valid_in_init,
////    input       [24:0]  in_data_init,
//    output  reg         valid_out,
//    output  reg [7:0]   out_data
//);
    
////    reg         [24:0]  in_data;
////    reg                 valid_in;

////    always @ (posedge clk or negedge rstn) begin
////        if (!rstn) begin
////            in_data     <=  'b0;
////            valid_in    <=  'b0;
////        end
////        else begin
////            valid_in    <=  valid_in_init;
////            in_data     <=  in_data_init;
////        end
////    end

//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            out_data    <=  'b0;
//            valid_out   <=  'b0;
//        end
//        else begin
//            valid_out   <=  valid_in;
//            if (valid_in) begin
//                case (in_data)
//                    // SHIFT LEFT 23
//                    25'h0_000_000:  out_data  <=  8'd00;
//                    25'h0_000_001:  out_data  <=  8'd23;
//                    25'h0_000_002:  out_data  <=  8'd22;
//                    25'h0_000_004:  out_data  <=  8'd21;
//                    25'h0_000_008:  out_data  <=  8'd20;
                      
//                    25'h0_000_010:  out_data  <=  8'd19;
//                    25'h0_000_020:  out_data  <=  8'd18;
//                    25'h0_000_040:  out_data  <=  8'd17;
//                    25'h0_000_080:  out_data  <=  8'd16;
                    
//                    25'h0_000_100:  out_data  <=  8'd15;
//                    25'h0_000_200:  out_data  <=  8'd14;
//                    25'h0_000_400:  out_data  <=  8'd13;
//                    25'h0_000_800:  out_data  <=  8'd12;
                    
//                    25'h0_001_000:  out_data  <=  8'd11;
//                    25'h0_002_000:  out_data  <=  8'd10;
//                    25'h0_004_000:  out_data  <=  8'd09;
//                    25'h0_008_000:  out_data  <=  8'd08;
                      
//                    25'h0_010_000:  out_data  <=  8'd07;
//                    25'h0_020_000:  out_data  <=  8'd06;
//                    25'h0_040_000:  out_data  <=  8'd05;
//                    25'h0_080_000:  out_data  <=  8'd04;
                    
//                    25'h0_100_000:  out_data  <=  8'd03;
//                    25'h0_200_000:  out_data  <=  8'd02;
//                    25'h0_400_000:  out_data  <=  8'd01;
//                    25'h0_800_000:  out_data  <=  8'd00;
                    
//                    25'h1_000_000:  out_data  <=  8'h80;
                    
//                    default:        out_data  <=  8'h40;
//                endcase
//            end
//            else begin
//                out_data    <=  out_data;
//            end
//        end
//    end
//endmodule
