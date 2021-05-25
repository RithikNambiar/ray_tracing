module dot_product_TOP (in_vector_1, in_vector_2, clk, out_scalar);

  input [56:0] in_vector_1;
  input [56:0] in_vector_2;
  input clk;
    
  output [18:0] out_scalar; 

  wire [18:0] stage1_out_x;
  wire [18:0] stage1_out_y;
  wire [18:0] stage1_out_z;
  
  dot_product_stage_1 STAGE1 (  .stage1_in_1    (in_vector_1), 
                                .stage1_in_2    (in_vector_2), 
                                .clk            (clk), 
                                .stage1_out_x   (stage1_out_x), 
                                .stage1_out_y   (stage1_out_y), 
                                .stage1_out_z   (stage1_out_z)
                             );    //STAGE1

  dot_product_stage_2 STAGE2 (  .stage2_in_1    (stage1_out_x),
                                .stage2_in_2    (stage1_out_y),
                                .stage2_in_3    (stage1_out_z),
                                .clk            (clk), 
                                .stage2_out     (out_scalar)
                             );    //STAGE2

endmodule
