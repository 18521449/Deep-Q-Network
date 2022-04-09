`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:39:31 PM
// Design Name: 
// Module Name: right_shiftter32
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

module right_shifter32 // 1 CLOCK
(
    input           clk, rstn, valid_in,
    input   [7:0]   shift,
    input   [23:0]  in_data,
    output          valid_out,
    output  [47:0]  out_data
//    input           clk, rstn, valid_in_init,
//    input   [7:0]   shift_init,
//    input   [23:0]  inData_init,
//    output          valid_out,
//    output  [23:0]  out_data
);    
//    reg                  valid_in;
//    reg   [7:0]          shift;
//    reg   [23:0]         in_data;    
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            in_data         <=  'b0;
//            shift         <=  'b0;
//            valid_in    <=  'b0;
//        end
//        else begin
//            valid_in<=  valid_in_init;
//            if (valid_in_init) begin
//                in_data     <=  inData_init;
//                shift     <=  shift_init;
//            end
//            else begin
//                in_data     <=  in_data;
//                shift     <=  shift;
//            end
//        end
//    end
    wire    [47:0]  temp_in;
    assign  temp_in =   {in_data, 24'b0};

    reg             temp_valid_out;
    reg     [47:0]  temp_outData;
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            temp_valid_out      <=  'b0;
            temp_outData        <=  'b0;            
        end
        else begin
            temp_valid_out      <=  valid_in;
            if (valid_in) begin
                temp_outData    <=  temp_in >> shift;
            end
            else begin
                temp_outData    <=  temp_outData;
            end
        end
    end
    
    assign  valid_out       =   temp_valid_out;
    assign  out_data         =   temp_outData;
    
endmodule
