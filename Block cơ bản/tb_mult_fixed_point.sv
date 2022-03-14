`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2022 13:09:59
// Design Name: 
// Module Name: tb_mult_fixed_point
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



module tb_mult_fixed_point();

    parameter SIZE_MUL_FIXED = 32;
    parameter INT_PART = 15;
    reg clk;
    reg rstn;
    reg[SIZE_MUL_FIXED - 1 : 0] A;
    reg[SIZE_MUL_FIXED - 1 : 0] B;
    reg valid_in;
    reg addsub_sel;
    wire valid_out;
    wire[SIZE_MUL_FIXED - 1 : 0] OUT;

    localparam sys_clk = 20;
    int fd1,fd2,fo;
    initial begin
        fd1 = $fopen("C:/Users/minxh/OneDrive/Desktop/a.txt","w");
        fd2 = $fopen("C:/Users/minxh/OneDrive/Desktop/b.txt","w");
        fo  = $fopen("C:/Users/minxh/OneDrive/Desktop/out.txt","w");
    end
    initial begin
        clk <= 1;
        rstn <= 0;
        A <= 'b0;
        B <= 'b0;
        valid_in <= 0;
        #(30*sys_clk);
            rstn <= 1;
        for(int i = 0;i<40;i++)begin
            $display("[TIME] :%0d",i);
//            A[SIZE_MUL_FIXED-1] <= $random;
//            B[SIZE_MUL_FIXED-1] <= $random;
//            A[SIZE_MUL_FIXED-2:SIZE_MUL_FIXED*3/4] <= 'b0;
//            A[SIZE_MUL_FIXED-2:SIZE_MUL_FIXED*3/4] <= 'b0;
//            #sys_clk;
//            rstn <= 1;
            valid_in <= 1;
//            A[SIZE_MUL_FIXED/4*3-1:SIZE_MUL_FIXED/4] <= $random;
//            B[SIZE_MUL_FIXED/4*3-1:SIZE_MUL_FIXED/4] <= $random;
//            #sys_clk;
//            valid_in <= 0;

//            A <='bz;
//            B <='bz;
//            while(valid_out == 0)
//                #sys_clk;    
            A[3+15:0] <= $random;
            B[3+15:0] <= $random;
            #(sys_clk);
//            rstn <= 1;
////            A <= 'b0;
////            B <= 'b0;
        end
        #(12*sys_clk);
        $fclose(fd1);
        $fclose(fd2);
        $fclose(fo);
        $finish;
    end

    always @ (posedge clk) begin
        if(valid_out == 1) begin
            $display("OUT = %b",OUT);
            $display("OUT = %b_%b",OUT[SIZE_MUL_FIXED-1:SIZE_MUL_FIXED/2],OUT[SIZE_MUL_FIXED/2-1:0]);
            $fwrite(fo,"%b\n",OUT);
        end
        if(valid_in == 1) begin
            $fwrite(fd1,"%b\n",A);
            $fwrite(fd2,"%b\n",B);
            $display("A   = %b",A);
            $display("B   = %b",B);
            $display("A   = %b_%b",A[SIZE_MUL_FIXED-1:SIZE_MUL_FIXED/2],A[SIZE_MUL_FIXED/2-1:0]);
            $display("B   = %b_%b",B[SIZE_MUL_FIXED-1:SIZE_MUL_FIXED/2],B[SIZE_MUL_FIXED/2-1:0]);
        end

    end

    always #(sys_clk/2) clk = ~clk;

    mult_fixed_no2
    #(
        .SIZE_MUL_FIXED(SIZE_MUL_FIXED),
        .INT_PART(INT_PART)
    ) dut
    (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .A(A),
        .B(B),
        .valid_out(valid_out),
        .OUT(OUT)
    );
endmodule