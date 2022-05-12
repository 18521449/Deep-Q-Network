
module Soft_Update(
    input               clk,
    input               rstn, 
    input               valid_in,
    input   [31:0]      Data_w_current,
    input   [31:0]      Data_w_target,
    input   [31:0]      T_current,
    input   [31:0]      T_target,
    // T_current + T_target = 1
    output              valid_out,
    output  [31:0]      Data_w_update_target     
    );
    
    wire [31:0] out_mul_current, out_mul_target;
    wire valid_out_current, valid_out_target;    
    multiplier_floating_point32 mul_current 
            (
             .clk(clk),
             .rstn(rstn), 
             .valid_in(valid_in),
             .inA(Data_w_current), 
             .inB(T_current),
             .valid_out(valid_out_current),
             .out_data(out_mul_current));  
             
    multiplier_floating_point32 mul_target 
            (
             .clk(clk),
             .rstn(rstn), 
             .valid_in(valid_in),
             .inA(Data_w_target), 
             .inB(T_current),
             .valid_out(valid_out_target),
             .out_data(out_mul_target));
             
    adder_floating_point32 add_update  
        (
              .clk(clk), 
              .rstn(rstn), 
              .valid_in(valid_out_current),
              .inA(out_mul_current), 
              .inB(out_mul_target),
              .valid_out(valid_out),
              .out_data(Data_w_update_target)
);       

endmodule