`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 03:58:29 PM
// Design Name: 
// Module Name: tb_CSA
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


module tb_multipiler_float32(

);
    localparam  delay       =   5;

    reg               clk,rstn, valid_in;
    reg   [31:0]      inA, inB;
    wire              valid_out;
    wire  [31:0]      out;        
    
    int     i;
    initial begin
        clk         <=   1;
        rstn        <=   0;
        valid_in    <=   0;
        inA         <=   32'hz;
        inB         <=   32'hz;
        #(20*delay);
        rstn        <=   1;
        #(2*delay);
        /////////////////////////
        #(2*delay);
        valid_in    <=  1;
        inA         <=  32'h0000_0000;
        inB         <=  32'h0000_0000;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h0000_0000;
        inB         <=  32'h7f80_0000;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h7f80_0000;
        inB         <=  32'h0000_0000;
        /////////////////////////
        #(2*delay);
        inA         <=  $random;
        inB         <=  32'h7f80_0000;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h7f80_0000;
        inB         <=  $random;
        /////////////////////////
        #(2*delay);
        inA         <=  $random;
        inB         <=  32'h0000_0000;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h0000_0000;
        inB         <=  $random;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h7a1a_130c;
        inB         <=  32'h5095_02f9;
        /////////////////////////
        #(2*delay);
        inA         <=  32'h0000_0001;
        inB         <=  32'h0000_000e;
        /////////////////////////
        for (i = 0; i < 20; i++) begin
            #(2*delay);
            inA         <=  $random;
            inB         <=  $random;
        end
        #(2*delay);
        valid_in    <=  0;
        inA         <=   32'hz;
        inB         <=   32'hz;
        #(100*delay);
        $finish;
    end
    
    always #delay clk  =  ~clk;
//    wire    valid_in_d;
//    wire    [31:0]      inA_d, inB_d;
//    delay_value #( 32, 1)  INA        ( .clk(clk), .rstn(rstn), .in_data(inA) , .out_data(inA_d));
//    delay_value #( 32, 1)  INB        ( .clk(clk), .rstn(rstn), .in_data(inB) , .out_data(inB_d));
//    delay_value #( 1, 1)  VLD        ( .clk(clk), .rstn(rstn), .in_data(valid_in) , .out_data(valid_in_d));

    multiplier_floating_point32 T_MFP32
    (
        clk,rstn, valid_in,
        inA, inB,
        valid_out,
        out               
    );  
endmodule