`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.02.2022 13:42:27
// Design Name: 
// Module Name: mult_fixed_no2
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


module mult_fixed_no2
#(
    parameter DATA_WIDTH = 32,
    parameter INT_PART =15
 )
(   
    input clk,
    input rstn,
    input valid_in,
    input[DATA_WIDTH - 1 : 0] A,
    input[DATA_WIDTH - 1 : 0] B,
    output valid_out,
    output [DATA_WIDTH - 1 : 0] OUT
);

    wire [(DATA_WIDTH-1)*2  - INT_PART - 1 : 0] sxs[DATA_WIDTH-1:0];
    wire  [(DATA_WIDTH-1)*2 - INT_PART -1 : 0] add_wire [$clog2(DATA_WIDTH) : 0][DATA_WIDTH-2:0];
    wire  [(DATA_WIDTH-1)*2 - INT_PART -1 : 0] add_wire_out [$clog2(DATA_WIDTH) : 0][DATA_WIDTH-2:0];

//     wire [DATA_WIDTH-1:0] A;
//     wire [DATA_WIDTH-1:0] B;  
//     n_dff
//     #(
//         .NUMBER_BIT(DATA_WIDTH)
//     ) 
//     reg_A
//     (
//         .clk(clk),
//         .rstn(rstn),
//         .en(1),
//         .in(i_A),
//         .out(A)
//     );

//     n_dff
//     #(
//         .NUMBER_BIT(DATA_WIDTH)
//     ) 
//     reg_B
//     (
//         .clk(clk),
//         .rstn(rstn),
//         .en(1),
//         .in(i_B),
//         .out(B)
//     );

    wire sign;
    assign sign =A[DATA_WIDTH-1] ^ B[DATA_WIDTH-1];

    genvar i; 
    generate
        for(i = 0 ;i<DATA_WIDTH;i=i+1) begin:loop_gen
            if(i==0) begin
                synth_mul_cell_no2_0
                #(
                    .DATA_WIDTH(DATA_WIDTH-1),
                    .INT_PART(INT_PART),
                    .LOCAL(i)
                ) synth_mul_cell_0
                (
                    .in(A[DATA_WIDTH-2:0]),
                    .en(B[i]),
                    .out(sxs[i])
                );

            end else if(i<DATA_WIDTH-1 && i>0 )begin
                synth_mul_cell_no2
                #(
                    .DATA_WIDTH(DATA_WIDTH-1),
                    .INT_PART(INT_PART),
                    .LOCAL(i)
                ) synth_mul_cell
                (
                    .in(A[DATA_WIDTH-2:0]),
                    .en(B[i]),
                    .out(sxs[i])
                );
            end else begin
                assign sxs[i] = 0;
            end
            if((i+1) % 2 == 0) begin
                assign add_wire[0][i/2] = sxs[i-1] + sxs[i] ;
                n_dff
                #(
                    .NUMBER_BIT(((DATA_WIDTH-1)*2-INT_PART))
                ) 
                reg_0
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(1),
                    .in(add_wire[0][i/2]),
                    .out(add_wire_out[0][i/2])
                );
            end
            if((i+1) % 4 == 0) begin
                assign add_wire[1][i/4] =  add_wire_out[0][i/2-1] + add_wire_out[0][i/2];
                n_dff 
                #(
                    .NUMBER_BIT(((DATA_WIDTH-1)*2-INT_PART))
                ) 
                reg_1
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(1),
                    .in(add_wire[1][i/4]),
                    .out(add_wire_out[1][i/4])
                );
            end
            if((i+1) % 8 == 0) begin
                assign add_wire[2][i/8] =  add_wire_out[1][i/4-1] + add_wire_out[1][i/4];
                n_dff 
                #(
                    .NUMBER_BIT(((DATA_WIDTH-1)*2-INT_PART))
                ) 
                reg_2
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(1),
                    .in(add_wire[2][i/8]),
                    .out(add_wire_out[2][i/8])
                );
            end
            if((i+1) % 16 == 0) begin
                assign add_wire[3][i/16] =  add_wire_out[2][i/8-1] + add_wire_out[2][i/8];
                n_dff 
                #(
                    .NUMBER_BIT(((DATA_WIDTH-1)*2-INT_PART))
                ) 
                reg_3
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(1),
                    .in(add_wire[3][i/16]),
                    .out(add_wire_out[3][i/16])
                );
            end
            if((i+1) % 32 == 0) begin
                assign add_wire[4][i/32] =  add_wire_out[3][i/16-1] + add_wire_out[3][i/16];
                n_dff 
                #(
                    .NUMBER_BIT(((DATA_WIDTH-1)*2-INT_PART))
                ) 
                reg_4
                (
                    .clk(clk),
                    .rstn(rstn),
                    .en(1),
                    .in(add_wire[4][i/32]),
                    .out(add_wire_out[4][i/32])
                );
            end            
        end
    endgenerate
    assign OUT[DATA_WIDTH-2:0] = add_wire_out[$clog2(DATA_WIDTH)-1][0][2*DATA_WIDTH - INT_PART -3 :DATA_WIDTH - INT_PART -1];

    delay_clock
    #(
        .DATA_WIDTH(1),
        .N_CLOCKs($clog2(DATA_WIDTH))//$clog2(DATA_WIDTH)+1
    ) delay_clock_valid
    (
        .clk(clk),
        .rstn(rstn),
        .en(1),
        .in(valid_in & valid_in),
        .out(valid_out)
    );

    delay_clock
    #(
        .DATA_WIDTH(1),
        .N_CLOCKs($clog2(DATA_WIDTH))//$clog2(DATA_WIDTH)+1
    ) delay_clock_sign
    (
        .clk(clk),
        .rstn(rstn),
        .en(1),
        .in(sign),
        .out(OUT[DATA_WIDTH-1])
    );
endmodule


module synth_mul_cell_no2
#(
    parameter DATA_WIDTH = 31,
    parameter INT_PART = 15,
    parameter LOCAL = 1)
(
    input [DATA_WIDTH - 1: 0] in,
    input en,
    output [DATA_WIDTH*2 - INT_PART - 1 : 0] out   
);
    wire [DATA_WIDTH*2 - 1 : 0]  w;
    assign w[LOCAL-1:0]                         = {LOCAL{1'b0}};
    assign w[LOCAL+DATA_WIDTH-1:LOCAL]          = in;
    assign w[DATA_WIDTH*2-1:LOCAL+DATA_WIDTH]   = 'b0;

    assign out = en ?  w[DATA_WIDTH*2 - INT_PART - 1 : 0] : 'b0 ;    
endmodule

module synth_mul_cell_no2_0
#(
    parameter DATA_WIDTH = 31,
    parameter INT_PART = 15,
    parameter LOCAL = 0)
(
    input [DATA_WIDTH - 1: 0] in,
    input en,
    output [DATA_WIDTH*2 - INT_PART - 1 : 0] out   
);
    wire [DATA_WIDTH*2 - INT_PART - 1 : 0]  w;
    assign w[LOCAL+DATA_WIDTH-1:LOCAL] = in;
    assign w[DATA_WIDTH*2 - INT_PART - 1:LOCAL+DATA_WIDTH] = 0;

    assign out = en ?  w[DATA_WIDTH*2 - INT_PART -1 : 0] : 'b0 ;  
endmodule