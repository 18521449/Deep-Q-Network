`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2022 05:47:15 PM
// Design Name: 
// Module Name: array_multi_float32
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


module array_multi_float32 // 4 CLOCK
(
    input               clk, rstn, valid_in,
    input   [23:0]      inA, inB,
    output              valid_out,
    output  [47:0]      out_data
);
    wire    [23:0]      stage1      [23:0];
    reg     [47:0]      stage2      [11:0];
    reg     [47:0]      stage3      [5:0];
    reg     [47:0]      stage4      [3:0];
    reg     [47:0]      stage5;
    
    reg     [4:0]       temp_valid;
    
    
    assign  stage1[0]   =  inA & {24{inB[0]}}; assign  stage1[6]   =  inA & {24{inB[6]}};  assign  stage1[12]   =  inA & {24{inB[12]}}; assign  stage1[18]   =  inA & {24{inB[18]}};
    assign  stage1[1]   =  inA & {24{inB[1]}}; assign  stage1[7]   =  inA & {24{inB[7]}};  assign  stage1[13]   =  inA & {24{inB[13]}}; assign  stage1[19]   =  inA & {24{inB[19]}};
    assign  stage1[2]   =  inA & {24{inB[2]}}; assign  stage1[8]   =  inA & {24{inB[8]}};  assign  stage1[14]   =  inA & {24{inB[14]}}; assign  stage1[20]   =  inA & {24{inB[20]}};
    assign  stage1[3]   =  inA & {24{inB[3]}}; assign  stage1[9]   =  inA & {24{inB[9]}};  assign  stage1[15]   =  inA & {24{inB[15]}}; assign  stage1[21]   =  inA & {24{inB[21]}};
    assign  stage1[4]   =  inA & {24{inB[4]}}; assign  stage1[10]  =  inA & {24{inB[10]}}; assign  stage1[16]   =  inA & {24{inB[16]}}; assign  stage1[22]   =  inA & {24{inB[22]}};
    assign  stage1[5]   =  inA & {24{inB[5]}}; assign  stage1[11]  =  inA & {24{inB[11]}}; assign  stage1[17]   =  inA & {24{inB[17]}}; assign  stage1[23]   =  inA & {24{inB[23]}};
    
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            temp_valid[4:1] <=   4'b0;
//            stage1[0]   <=  'b0; stage1[6]   <=  'b0; stage1[12]   <=  'b0; stage1[18]   <=  'b0;
//            stage1[1]   <=  'b0; stage1[7]   <=  'b0; stage1[13]   <=  'b0; stage1[19]   <=  'b0;
//            stage1[2]   <=  'b0; stage1[8]   <=  'b0; stage1[14]   <=  'b0; stage1[20]   <=  'b0;
//            stage1[3]   <=  'b0; stage1[9]   <=  'b0; stage1[15]   <=  'b0; stage1[21]   <=  'b0;
//            stage1[4]   <=  'b0; stage1[10]  <=  'b0; stage1[16]   <=  'b0; stage1[22]   <=  'b0;
//            stage1[5]   <=  'b0; stage1[11]  <=  'b0; stage1[17]   <=  'b0; stage1[23]   <=  'b0;
            
            
            stage2[0]   <=  'b0; stage2[1]   <=  'b0; stage2[2]    <=  'b0; stage2[3]    <=  'b0;
            stage2[4]   <=  'b0; stage2[5]   <=  'b0; stage2[6]    <=  'b0; stage2[7]    <=  'b0; 
            stage2[8]   <=  'b0; stage2[9]   <=  'b0; stage2[10]   <=  'b0; stage2[11]   <=  'b0;
            
            
            stage3[0]   <=  'b0; stage3[1]   <=  'b0; stage3[2]    <=  'b0;
            stage3[3]   <=  'b0; stage3[4]   <=  'b0; stage3[5]    <=  'b0;
            
            stage4[0]   <=  'b0; stage4[1]   <=  'b0; stage4[2]    <=  'b0;
            
            stage5      <=  'b0;            
        end
        else begin
            // STAGE 1
//            temp_valid[0]   <=  valid_in;
//            if (valid_in) begin
//                stage1[0]   <=  inA & {24{inB[0]}}; stage1[6]   <=  inA & {24{inB[6]}};  stage1[12]   <=  inA & {24{inB[12]}}; stage1[18]   <=  inA & {24{inB[18]}};
//                stage1[1]   <=  inA & {24{inB[1]}}; stage1[7]   <=  inA & {24{inB[7]}};  stage1[13]   <=  inA & {24{inB[13]}}; stage1[19]   <=  inA & {24{inB[19]}};
//                stage1[2]   <=  inA & {24{inB[2]}}; stage1[8]   <=  inA & {24{inB[8]}};  stage1[14]   <=  inA & {24{inB[14]}}; stage1[20]   <=  inA & {24{inB[20]}};
//                stage1[3]   <=  inA & {24{inB[3]}}; stage1[9]   <=  inA & {24{inB[9]}};  stage1[15]   <=  inA & {24{inB[15]}}; stage1[21]   <=  inA & {24{inB[21]}};
//                stage1[4]   <=  inA & {24{inB[4]}}; stage1[10]  <=  inA & {24{inB[10]}}; stage1[16]   <=  inA & {24{inB[16]}}; stage1[22]   <=  inA & {24{inB[22]}};
//                stage1[5]   <=  inA & {24{inB[5]}}; stage1[11]  <=  inA & {24{inB[11]}}; stage1[17]   <=  inA & {24{inB[17]}}; stage1[23]   <=  inA & {24{inB[23]}};
//            end
//            else begin
//                stage1[0]   <=  stage1[0]; stage1[6]   <=  stage1[6];  stage1[12]   <=  stage1[12]; stage1[18]   <=  stage1[18];
//                stage1[1]   <=  stage1[1]; stage1[7]   <=  stage1[7];  stage1[13]   <=  stage1[13]; stage1[19]   <=  stage1[19];
//                stage1[2]   <=  stage1[2]; stage1[8]   <=  stage1[8];  stage1[14]   <=  stage1[14]; stage1[20]   <=  stage1[20];
//                stage1[3]   <=  stage1[3]; stage1[9]   <=  stage1[9];  stage1[15]   <=  stage1[15]; stage1[21]   <=  stage1[21];
//                stage1[4]   <=  stage1[4]; stage1[10]  <=  stage1[10]; stage1[16]   <=  stage1[16]; stage1[22]   <=  stage1[22];
//                stage1[5]   <=  stage1[5]; stage1[11]  <=  stage1[11]; stage1[17]   <=  stage1[17]; stage1[23]   <=  stage1[23];
//            end
            // STAGE 1
            temp_valid[1]   <=  valid_in;//temp_valid[0];
            if (valid_in) begin
                stage2[0]   <=  {24'b0, stage1[0]} + {23'b0, stage1[1],  1'b0}; 
                stage2[1]   <=  {24'b0, stage1[2]} + {23'b0, stage1[3],  1'b0}; 
                stage2[2]   <=  {24'b0, stage1[4]} + {23'b0, stage1[5],  1'b0};
                stage2[3]   <=  {24'b0, stage1[6]} + {23'b0, stage1[7],  1'b0};
                stage2[4]   <=  {24'b0, stage1[8]} + {23'b0, stage1[9],  1'b0}; 
                stage2[5]   <=  {24'b0, stage1[10]}+ {23'b0, stage1[11], 1'b0};
                
                
                stage2[6]   <=  {24'b0, stage1[12]} + {23'b0, stage1[13], 1'b0}; 
                stage2[7]   <=  {24'b0, stage1[14]} + {23'b0, stage1[15], 1'b0}; 
                stage2[8]   <=  {24'b0, stage1[16]} + {23'b0, stage1[17], 1'b0};
                stage2[9]   <=  {24'b0, stage1[18]} + {23'b0, stage1[19], 1'b0};
                stage2[10]  <=  {24'b0, stage1[20]} + {23'b0, stage1[21], 1'b0}; 
                stage2[11]  <=  {24'b0, stage1[22]} + {23'b0, stage1[23], 1'b0};
            end
            else begin
                stage2[0]   <=  stage2[0]; 
                stage2[1]   <=  stage2[1]; 
                stage2[2]   <=  stage2[2];
                stage2[3]   <=  stage2[3];
                stage2[4]   <=  stage2[4]; 
                stage2[5]   <=  stage2[5];
                
                stage2[6]   <=  stage2[6]; 
                stage2[7]   <=  stage2[7]; 
                stage2[8]   <=  stage2[8];
                stage2[9]   <=  stage2[9];
                stage2[10]  <=  stage2[10]; 
                stage2[11]  <=  stage2[11];
            end
            // STAGE 2
            temp_valid[2]   <=  temp_valid[1];
            if (temp_valid[1]) begin
                stage3[0]   <=  stage2[0] + {stage2[1][45:0],  2'b0}; 
                stage3[1]   <=  stage2[2] + {stage2[3][45:0],  2'b0};
                stage3[2]   <=  stage2[4] + {stage2[5][45:0],  2'b0};
                stage3[3]   <=  stage2[6] + {stage2[7][45:0],  2'b0};
                stage3[4]   <=  stage2[8] + {stage2[9][45:0],  2'b0}; 
                stage3[5]   <=  stage2[10]+ {stage2[11][45:0], 2'b0};
            end
            else begin
                stage3[0]   <=  stage3[0]; 
                stage3[1]   <=  stage3[1]; 
                stage3[2]   <=  stage3[2];
                stage3[3]   <=  stage3[3];
                stage3[4]   <=  stage3[4]; 
                stage3[5]   <=  stage3[5];
            end            
            // STAGE 3
            temp_valid[3]   <=  temp_valid[2];
            if (temp_valid[2]) begin
                stage4[0]   <=  stage3[0] + {stage3[1][43:0],  4'b0}; 
                stage4[1]   <=  stage3[2] + {stage3[3][43:0],  4'b0};
                stage4[2]   <=  stage3[4] + {stage3[5][43:0],  4'b0};
            end
            else begin
                stage4[0]   <=  stage4[0]; 
                stage4[1]   <=  stage4[1]; 
                stage4[2]   <=  stage4[2];
            end     
            // STAGE 4
            temp_valid[4]   <=  temp_valid[3];
            if (temp_valid[3]) begin
                stage5      <=  stage4[0] + {stage4[1][43:0],  8'b0} + {stage4[2][43:0],  16'b0};
            end
            else begin
                stage5      <=  stage5;
            end     
        end
    end
    
    assign  valid_out   =   temp_valid[4];  
    assign  out_data         =   stage5; 
    
endmodule
