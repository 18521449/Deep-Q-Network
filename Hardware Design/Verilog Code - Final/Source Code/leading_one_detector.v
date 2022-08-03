`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2022 03:42:05 PM
// Design Name: 
// Module Name: leading_one_detector
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


module leading_one_detector // 1 CLOCK
#(
    parameter DATA_WIDTH    =   25
)
(
    input                           clk, rstn, valid_in,
    input       [DATA_WIDTH-1:0]    in_data,      
//    input                       valid_in_init,
//    input       [DATA_WIDTH-1:0]  in_data_init,  
    output  reg                     valid_out,
    output  reg [DATA_WIDTH-1:0]    out_data    
);    
    
//    reg         [DATA_WIDTH-1:0]  in_data;
//    reg                         valid_in;

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
    
    wire    [DATA_WIDTH-1:0]  reverse_in;
    wire    [DATA_WIDTH-1:0]  complement_two;
    wire    [DATA_WIDTH-1:0]  temp_out_data;
    
    genvar i;
    generate
        for (i=0; i<DATA_WIDTH; i=i+1) begin: GEN_INPUT
            assign  reverse_in[DATA_WIDTH-i-1]  =   ~in_data[i];
            assign  temp_out_data[i]            =   complement_two[DATA_WIDTH-i-1] & in_data[i];
        end
        assign  complement_two                  =   reverse_in + 1'b1;
    endgenerate
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_data    <=  'b0;
            valid_out   <=  'b0;
        end
        else begin
            valid_out   <=  valid_in;
            if (valid_in)
                out_data    <=  temp_out_data;
            else
                out_data    <=  out_data;                
        end
    end
    /*
    https://www.edaboard.com/threads/solutions-for-leading-one-detector.201958/
    
    Example 1:
    000011110000 -- input
    111100001111 -- invert
    111100010000 -- add 1
    000000010000 -- xnor with input.
    
    Example 2:
    1010101011 -- input
    0101010100 -- invert
    0101010101 -- add 1
    0000000001 -- xnor with input
    */
endmodule
