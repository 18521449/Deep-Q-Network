`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 12:19:30 PM
// Design Name: 
// Module Name: multiplier_float
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
multiplier_floating_point32 // 7 CLOCK
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
//(* use_dsp = "yes" *) 
module multiplier_floating_point32 // 7 CLOCK
(
    input               clk,
    input               rstn, 
    input               valid_in,
    input   [31:0]      inA, 
    input   [31:0]      inB,
//    input               clk,rstn, valid_in_init,
//    input   [31:0]      inA_init, inB_init,
    output              valid_out,
    output  [31:0]      out_data               
);  
//    reg                 valid_in;
//    reg     [31:0]      inA, inB;
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            inA     <=  'b0;
//            inB     <=  'b0;
//        end
//        else begin
//            valid_in    <=  valid_in_init;
//            if (valid_in_init) begin
//                inA     <=  inA_init;
//                inB     <=  inB_init; 
//            end
//            else begin
//                inA     <=  inA;
//                inB     <=  inB;            
//            end
//        end
//    end

    //---------------------- UNPACK
    wire                signA       =   inA[31];
    wire                signB       =   inB[31];
    wire    [7:0]       exponentA   =   inA[30:23];
    wire    [7:0]       exponentB   =   inB[30:23]; 
    wire    [23:0]      mantiseA    =   {1'b1, inA[22:0]};
    wire    [23:0]      mantiseB    =   {1'b1, inB[22:0]};
    
    wire                valid_inside;
    
    //---------------------- CAL MANTISE      
    wire                valid_mantise;      
    wire    [47:0]      temp_mantise,       mean_mantise_bit;
    wire    [22:0]      mantise_cal,        mantise;
    wire                high_bit_mantise;
    // STAGE 1-4    
    array_multi_float32 // 4 CLOCK
    ARRAY_MULTIPLE_MANTISE 
    (
        .clk(clk), .rstn(rstn), .valid_in(valid_in),
        .inA(mantiseA), .inB(mantiseB),
        .valid_out(valid_mantise),
        .out_data(temp_mantise)
    );
    
    // STAGE 5
    assign  high_bit_mantise    =   temp_mantise[47];
    assign  mean_mantise_bit    =   temp_mantise;
    assign  {mantise_cal}       =   high_bit_mantise?    mean_mantise_bit[46:24] : mean_mantise_bit[45:23];
    
    delay_value #( 1, 2)  DELAY_VALID                       ( .clk(clk), .rstn(rstn), .in_data(valid_mantise), .out_data(valid_inside));
    delay_value #( 23, 2) DELAY_MANTISE                     ( .clk(clk), .rstn(rstn), .in_data(mantise_cal), .out_data(mantise));
    
    //----------------------CAL EXPONENT  
    wire                valid_exponent;
    wire                zero_flag_from_exponent, inf_flag_from_exponent;
    wire    [7:0]       exponent;
    
    exponent_process_floating_point32 // 6 CLOCK WITH SIGNAL ASYN high_bit_from_mantise_process
    EXPONENT_PROCESS 
    (
        .clk(clk), .rstn(rstn), .valid_in(valid_in),
        .high_bit_from_mantise_process(high_bit_mantise),
        .exponentA(exponentA), .exponentB(exponentB),
        .valid_out(valid_exponent),
        .zero_flag_from_exponent(zero_flag_from_exponent), .inf_flag_from_exponent(inf_flag_from_exponent),
        .exponent(exponent)
    );
      
    //----------------------CAL SIGN
    wire    sign_cal, sign;
    assign  sign_cal    =   signA ^ signB; 
    delay_value #( 1, 6) DELAY_SIGN ( .clk(clk), .rstn(rstn), .in_data(sign_cal), .out_data(sign));
    
    //----------------------CHECK
    // STAGE 1-6
    wire                zero_flag;
    wire                inf_flag;
    wire                zero_flag_check_init_cal,       zero_flag_check_init;
    wire                inf_flag_check_init_cal,        inf_flag_check_init;
    check_value_multiplier_floating_point32 CHECK_VALUE (
        .clk(clk), .rstn(rstn),
        .inA(inA), .inB(inB),
        .zero_flag(zero_flag_check_init_cal), .inf_flag(inf_flag_check_init_cal)
     );
     
     delay_value #( 1, 6) DELAY_CHECK_ZERO_FLAG_INIT        ( .clk(clk), .rstn(rstn), .in_data(zero_flag_check_init_cal), .out_data(zero_flag_check_init));
     delay_value #( 1, 6) DELAY_CHECK_INF_FLAG_INIT         ( .clk(clk), .rstn(rstn), .in_data(inf_flag_check_init_cal), .out_data(inf_flag_check_init));
     
     
     
     // STAGE 7
     reg    [31:0]      out_cal, valid_out_cal;
     
     assign zero_flag   =   zero_flag_check_init    |   zero_flag_from_exponent;
     assign inf_flag    =   inf_flag_check_init     |   inf_flag_from_exponent;
     
     always @ (posedge clk or negedge rstn) begin: OUT_DATA
        if (!rstn) begin
            out_cal         <=  'b0;
            valid_out_cal   <=  'b0;
        end
        else begin
            valid_out_cal   <=  valid_inside;       
            if (valid_inside & valid_exponent) begin    
                if (zero_flag)
                    out_cal        <=  'b0;
                else if (inf_flag)
                    out_cal        <=  {sign, 8'd255, 23'b0};
                else begin
                    out_cal[31]    <=  sign;
                    out_cal[30:23] <=  exponent;
                    out_cal[22:0]  <=  mantise;              
                end
            end
            else
                out_cal    <=  out_cal;
        end        
    end
    
    assign  valid_out   =   valid_out_cal;
    assign  out_data    =   out_cal;
    
endmodule

////module multiplier_float
////(
////    input       [31:0]  inA,
////    input       [31:0]  inB,
////    input               valid_in,
////    output      [31:0]  data_out,
////    output              valid_out
////);
    
    
    
    
////endmodule


//module multiplier_fixed
//#(
//    NUMBER_BIT  =   32,
//    NUMBER_INT  =   11
//)
//(
//    input                           clk,
//    input                           rstn,
//    input                           valid_in_init,
//    input       [NUMBER_BIT-1:0]    inA_init,
//    input       [NUMBER_BIT-1:0]    inB_init,
////    input               valid_in,
//    output  reg                     valid_out,
//    output  reg [NUMBER_BIT-1:0]    data_out//,
////    output              valid_out
//);

//// CHECK
//    reg                           valid_in;
//    reg       [NUMBER_BIT-1:0]    inA;
//    reg       [NUMBER_BIT-1:0]    inB;
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            inA         <=  'b0;
//            inB         <=  'b0;
//            valid_in    <=  'b0;
//        end 
//        else begin
//            inA         <=  inA_init;
//            inB         <=  inB_init;
//            valid_in    <=  valid_in_init;
//        end
//    end

//    // STAGE 1
    
//    wire        [NUMBER_BIT-2:0]    outS_CSA;
//    wire        [NUMBER_BIT-2:0]    outC_CSA;
//    wire        [NUMBER_BIT-2:0]    outP_CSA;
//    wire                            sign;
    
//    assign  sign    =   inA[NUMBER_BIT-1] ^ inB[NUMBER_BIT-1];
        
//    CSA_array #(
//        NUMBER_BIT-1
//    ) T_array (
//        .inA(inA[NUMBER_BIT-2:0]),
//        .inB(inB[NUMBER_BIT-2:0]),
//        .outS(outS_CSA),
//        .outC(outC_CSA),
//        .outP(outP_CSA)
//    );
    

//    reg         [NUMBER_BIT-2:0]    S_CSA;
//    reg         [NUMBER_BIT-2:0]    C_CSA;
//    reg         [NUMBER_BIT-2:0]    P_CSA;
//    reg                             valid_buffer1;
//    reg                             sign_buffer1;
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            S_CSA           <=  'b0;
//            C_CSA           <=  'b0;
//            P_CSA           <=  'b0;
//            valid_buffer1   <=  'b0;
//            sign_buffer1    <=  'b0;
//        end
//        else begin
//            if (valid_in) begin
//                S_CSA           <=  outS_CSA;
//                C_CSA           <=  outC_CSA;
//                P_CSA           <=  outP_CSA;
//                valid_buffer1   <=  valid_in;
//                sign_buffer1    <=  sign;
//            end
//            else begin
//                valid_buffer1   <=  'b0;                
//            end
            
//        end    
//    end
    
//    // STAGE 2
        
//    wire        [NUMBER_BIT-2:0]    outP_PCA;
//    wire                            outC_PCA;
    
//    CPA #(
//        NUMBER_BIT-1
//    ) T_CPA (
//        .inS(S_CSA),
//        .inC(C_CSA),
//        .outP(outP_PCA),
//        .outC(outC_PCA)   
//    );
    
//    wire        [NUMBER_BIT-1:0]                    dataOutTemp;
//    wire        [2*NUMBER_INT-1:0]                  intSide;
//    wire        [2*(NUMBER_BIT-NUMBER_INT-1)-1:0]   fraSide;
    
//    assign  {intSide, fraSide}  =   {outP_PCA, P_CSA};
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            data_out        <=  'b0;
//            valid_out       <=  'b0;
//        end
//        else begin
//            if (valid_buffer1) begin
//                data_out        <=  {sign_buffer1,  intSide[NUMBER_INT-1:0], fraSide[2*(NUMBER_BIT-NUMBER_INT-1)-1:(NUMBER_BIT-NUMBER_INT-1)]};
//                valid_out       <=  valid_buffer1;
//            end
//            else begin
//                valid_out   <=  'b0;                
//            end
            
//        end    
//    end
    
//endmodule

//// https://swarm.cs.pub.ro/~mbarbulescu/SMPA/CMOS-VLSI-design.pdf 478

//module CPA
//#(
//    NUMBER_BIT  =   31
//)
//(
//    input       [NUMBER_BIT-1:0]    inS,
//    input       [NUMBER_BIT-1:0]    inC,
//    output      [NUMBER_BIT-1:0]    outP,
//    output                          outC   
//);

//    wire        [NUMBER_BIT:0]      inTempC;
    
//    genvar i;
//    generate
//        assign  inTempC[0]  =   1'b0;
    
//        for (i=0; i<NUMBER_BIT; i=i+1) begin: CPA_GEN
//            full_adder FULL_ADDER   (
//                                        .inA(inS[i]),
//                                        .inB(inC[i]),
//                                        .inC(inTempC[i]),
//                                        .outS(outP[i]),
//                                        .outC(inTempC[i+1])
//                                    );
//        end
        
//        assign  outC    =   inTempC[NUMBER_BIT];
//    endgenerate     
//endmodule

//module CSA_array 
//#(
//    NUMBER_BIT  =   31
//)
//(
//    input       [NUMBER_BIT-1:0]    inA,
//    input       [NUMBER_BIT-1:0]    inB,
//    output      [NUMBER_BIT-1:0]    outS,
//    output      [NUMBER_BIT-1:0]    outC,
//    output      [NUMBER_BIT-1:0]    outP
//);
//    wire        [NUMBER_BIT-1:0]    outTempC    [NUMBER_BIT-1:0];
//    wire        [NUMBER_BIT-1:0]    outTempS    [NUMBER_BIT-1:0];
//    genvar i;
    
//    generate 
//        CSA_row
//        #(
//            NUMBER_BIT
//        ) CSA_ROW_IN (
//            .inA(inA),
//            .inS('b0),
//            .inC('b0),
//            .inB(inB[0]),
//            .outS(outTempS[0]),
//            .outC(outTempC[0])    
//        );
        
        
//        for (i=1; i<NUMBER_BIT; i=i+1) begin: CSA_ROW
                    
//            CSA_row
//            #(
//                NUMBER_BIT
//            ) CSA (
//                .inA(inA),
//                .inS({1'b0, outTempS[i-1][NUMBER_BIT-1:1]}),
//                .inC(outTempC[i-1]),
//                .inB(inB[i]),
//                .outS(outTempS[i]),
//                .outC(outTempC[i])    
//            );
//        end
        
//        for (i=0; i<NUMBER_BIT; i=i+1) begin
//            assign  outP[i] =   outTempS[i][0];
//        end
//        assign  outS    =   {1'b0, outTempS[NUMBER_BIT-1][NUMBER_BIT-1:1]};
//        assign  outC    =   outTempC[NUMBER_BIT-1];
//    endgenerate
//endmodule

//module CSA_row
//#(
//    NUMBER_BIT  =   31
//)
//(
//    input       [NUMBER_BIT-1:0]    inA,
//    input       [NUMBER_BIT-1:0]    inS,
//    input       [NUMBER_BIT-1:0]    inC,
//    input                           inB,
//    output      [NUMBER_BIT-1:0]    outS,
//    output      [NUMBER_BIT-1:0]    outC    
//);
//    wire        [NUMBER_BIT-1:0]    andAB;
//    genvar i;   
//    generate
//        for(i = 0; i < NUMBER_BIT; i = i + 1) begin: CSA_GEN
//            assign  andAB[i]    =   inA[i] & inB;
//            full_adder FULL_ADDER (
//                                    .inA(andAB[i]),
//                                    .inB(inS[i]),
//                                    .inC(inC[i]),
//                                    .outS(outS[i]),
//                                    .outC(outC[i])
//                                  );
//        end
//    endgenerate
//endmodule

////module CSA 
////#(
////    NUMBER_BIT  =   4
////)
////(
////    input       [NUMBER_BIT-1:0]    inA,
////    input       [NUMBER_BIT-1:0]    inB,
////    input       [NUMBER_BIT-1:0]    inC,
////    output      [NUMBER_BIT-1:0]    outS,
////    output      [NUMBER_BIT-1:0]    outC    
////);

////    genvar i;   
////    generate
////        for(i = 0; i < NUMBER_BIT; i = i + 1) begin
////            full_adder FULL_ADDER (
////                                    .inA(inA[i]),
////                                    .inB(inB[i]),
////                                    .inC(inC[i]),
////                                    .outS(outS[i]),
////                                    .outC(outC[i])
////                                  );
////        end
////    endgenerate
////endmodule

//module full_adder 
//( 
//    input       inA,
//    input       inB,
//    input       inC,
//    output      outS,
//    output      outC
//);
////    reg inA, inB, inC;

////    always @ (posedge clk or negedge rstn) begin
////        if (!rstn) begin
////            inA         <=  'b0;
////            inB         <=  'b0;
////            inC         <=  'b0;
////        end 
////        else begin
////            inA         <=  inA_init;
////            inB         <=  inB_init;
////            inC         <=  inC_init;
////        end
////    end
    
//    wire        orAB,
//                andAB,
//                andC_orAB;
                
//    assign  orAB        =   inA ^ inB;
//    assign  andAB       =   inA & inB;
//    assign  andC_orAB   =   inC & orAB;
    
//    assign  outS        =   inC ^ orAB;
//    assign  outC        =   andAB | andC_orAB;
////    wire    tempC, tempS;
    
////    assign {tempC, tempS}   =   inA + inB + inC;
                
////    always @ (posedge clk or negedge rstn) begin
////        if (!rstn) begin
////            outS        <=   'b0;
////            outC        <=   'b0;
////        end 
////        else begin
////            outC        <=   tempC;
////            outS        <=   tempS;
            
//////            outS        =   inC ^ orAB;
//////            outC        =   andAB | andC_orAB;
////        end
////    end            
   
//endmodule

//module dff
//#(
//    NUMBER_BIT  =   4
//)
//(
//    input                       clk,
//    input                       rstn,
//    input                       en,
//    input   [NUMBER_BIT-1:0]    in_data,
//    output  [NUMBER_BIT-1:0]    out_data
//);
//    reg     [NUMBER_BIT-1:0]    X;
        
//    always @(posedge clk or negedge rstn) begin
//        if(!rstn) begin
//            X   <=  1'b0;
//        end
//        else begin
//            if(en)  
//                X   <=  in_data;
//            else 
//                X   <=  X;    
//        end
//    end
    
//    assign  out_data =   X;
//endmodule


//module full
//#(
//    NUMBER_BIT  =   31
//)
//(
//    input                           clk, rstn,
//    input       [NUMBER_BIT-1:0]    inA_init,
//    input       [NUMBER_BIT-1:0]    inB_init,
//    output  reg [NUMBER_BIT-1:0]    outS_,
//    output  reg                     outC_
//);
//    reg     [NUMBER_BIT-1:0] inA, inB;

//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            inA         <=  'b0;
//            inB         <=  'b0;
//        end 
//        else begin
//            inA         <=  inA_init;
//            inB         <=  inB_init;
//        end
//    end
    
//    wire    [NUMBER_BIT-1:0] outS;
//    wire    [NUMBER_BIT-1:0] outC;
    
//    assign  {outC, outS} = inA + inB + {NUMBER_BIT{1'b1}};
    
//    always @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            outS_         <=  'b0;
//            outC_         <=  'b0;
//        end 
//        else begin
//            outS_         <=  outS;
//            outC_         <=  outC;
//        end
//    end
//endmodule
