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


module encoder_25_for_floating_point32 // 1 CLOCK
(
    input               clk, rstn, valid_in,
    input       [24:0]  in_data,
//    input               valid_in_init,
//    input       [24:0]  in_data_init,
    output  reg         valid_out,
    output  reg [7:0]   out_data
);
    
//    reg         [24:0]  in_data;
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
                    // SHIFT LEFT 23
                    25'h0_000_001:  out_data  <=  8'd23;
                    25'h0_000_002:  out_data  <=  8'd22;
                    25'h0_000_004:  out_data  <=  8'd21;
                    25'h0_000_008:  out_data  <=  8'd20;
                      
                    25'h0_000_010:  out_data  <=  8'd19;
                    25'h0_000_020:  out_data  <=  8'd18;
                    25'h0_000_040:  out_data  <=  8'd17;
                    25'h0_000_080:  out_data  <=  8'd16;
                    
                    25'h0_000_100:  out_data  <=  8'd15;
                    25'h0_000_200:  out_data  <=  8'd14;
                    25'h0_000_400:  out_data  <=  8'd13;
                    25'h0_000_800:  out_data  <=  8'd12;
                    
                    25'h0_001_000:  out_data  <=  8'd11;
                    25'h0_002_000:  out_data  <=  8'd10;
                    25'h0_004_000:  out_data  <=  8'd9;
                    25'h0_008_000:  out_data  <=  8'd8;
                      
                    25'h0_010_000:  out_data  <=  8'd7;
                    25'h0_020_000:  out_data  <=  8'd6;
                    25'h0_040_000:  out_data  <=  8'd5;
                    25'h0_080_000:  out_data  <=  8'd4;
                    
                    25'h0_100_000:  out_data  <=  8'd3;
                    25'h0_200_000:  out_data  <=  8'd2;
                    25'h0_400_000:  out_data  <=  8'd1;
                    25'h0_800_000:  out_data  <=  8'd0;
                    
                    25'h1_000_000:  out_data  <=  8'h80;
                    
                    default:        out_data  <=  8'd40;
                endcase
            end
            else begin
                out_data    <=  out_data;
            end
        end
    end
endmodule
