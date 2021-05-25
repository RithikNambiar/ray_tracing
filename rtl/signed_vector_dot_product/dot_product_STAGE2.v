module dot_product_stage_2(stage2_in_1, stage2_in_2, stage2_in_3, clk, stage2_out);

  input [18:0] stage2_in_1;
  input [18:0] stage2_in_2;
  input [18:0] stage2_in_3;
  input clk;

  output [18:0] stage2_out;

  localparam ALL_POS = 3'b000;
  localparam Z_NEG   = 3'b001;
  localparam Y_NEG   = 3'b010;
  localparam YZ_NEG  = 3'b011;  //for use in case statement
  localparam X_NEG   = 3'b100;
  localparam XZ_NEG  = 3'b101;
  localparam XY_NEG  = 3'b110;
  localparam XYZ_NEG = 3'b111;

  reg [18:0] product_x;   
  reg [18:0] product_y;    //temporary reg to hold final value of product
  reg [18:0] product_z; 
    
  reg [18:0] temp_sum_xy;    //temporary reg to hold value of sum of two no.s
  reg [18:0] temp_sum_yz;    //19 bits for magnitude only
  reg [18:0] temp_sum_xz;    //sum of 3 n bit numbers gives a result of (n+2) bits at max
    
  reg [20:0] temp_sum;  //to temporarily hold the final value of the addition stage
  reg [18:0] temp_out;
  reg [18:0] final_temp_out;
    
  reg [2:0] concatenated_sign_bits; //for use in case statement

  always @ *
    begin: ADDITION   //WARNING: sizes of the terms being compared might be bugged
      product_x[18:0] = stage2_in_1;
      product_y[18:0] = stage2_in_2;
      product_z[18:0] = stage2_in_3;
    
      concatenated_sign_bits[2:0] = {product_x[18], product_y[18], product_z[18]};
    
      temp_sum_xy[18:0] = product_x[17:0] + product_y[17:0]; 
      temp_sum_yz[18:0] = product_y[17:0] + product_z[17:0];   //magnitude only 
      temp_sum_xz[18:0] = product_z[17:0] + product_x[17:0];
    
      case (concatenated_sign_bits[2:0])
        ALL_POS: begin
                   temp_sum[19:0] = product_x[17:0] + product_y[17:0] + product_z[17:0];
                   temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                 end  // ALL_POS 
    
        Z_NEG:   begin
                   if(temp_sum_xy[18:0] > product_z[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_xy[18:0] - product_z[17:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end
                        
                   else /* (temp_sum_xy[18:0] < product_z[17:0]) */  
                     begin
                       temp_sum[19:0] = product_z[17:0] - temp_sum_xy[18:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (1-e)
                     end
                 end  // Z_NEG
    
        Y_NEG:   begin
                   if(temp_sum_xz[18:0] > product_y[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_xz[18:0] - product_y[17:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end 
    
                   else /* (temp_sum_xz[18:0] < product_y[17:0]) */  
                     begin
                       temp_sum[19:0] = product_y[17:0] - temp_sum_xz[18:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                     end
                 end  // Y_NEG
    
        YZ_NEG:  begin
                   if(temp_sum_yz[18:0] > product_x[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_yz[18:0] - product_x[17:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                     end
    
                   else /* (temp_sum_yz[18:0] < product_x[17:0] */ 
                     begin
                       temp_sum[19:0] = product_x[17:0] - temp_sum_yz[18:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end
                 end  // YZ_NEG
                                
        X_NEG:   begin
                   if(temp_sum_yz[18:0] > product_z[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_yz[18:0] - product_x[17:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end
    
                   else /* (temp_sum_yz[18:0] < product_x[17:0]) */  
                     begin
                       temp_sum[19:0] = product_x[17:0] - temp_sum_yz[18:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                     end
                 end  // X_NEG
    
        XZ_NEG:  begin
                   if(temp_sum_xz[18:0] > product_y[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_xz[18:0] - product_y[17:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                     end
    
                   else /* (temp_sum_xz[18:0] < product_y[17:0] */ 
                     begin
                       temp_sum[19:0] = product_y[17:0] - temp_sum_xz[18:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end
                 end  // XZ_NEG
    
        XY_NEG:  begin
                   if(temp_sum_xy[18:0] > product_z[17:0])
                     begin
                       temp_sum[19:0] = temp_sum_xy[18:0] - product_z[17:0];
                       temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                     end
    
                   else /* (temp_sum_xy[18:0] < product_z[17:0] */ 
                     begin
                       temp_sum[19:0] = product_y[17:0] - temp_sum_xy[18:0];
                       temp_sum[20] = 1'b0; //sign bit = 0 (+ve)
                     end
                 end  // XY_NEG
        
        XYZ_NEG: begin
                   temp_sum[19:0] = product_x[17:0] + product_y[17:0] + product_z[17:0];
                   temp_sum[20] = 1'b1; //sign bit = 1 (-ve)
                 end
      endcase  // concatenated_sign_bits[2:0]
    
      //OVERFLOW HANDLER
      if(|temp_sum[19:18] == 1)                         //overflow occurs
        begin
          temp_out[18:0] = {temp_sum[20], {17{1'b1}}}; 
        end
    
      else /* (|temp_sum[19:18] == 0) */               //no overflow occurs
        begin
          temp_out[18:0] = {temp_sum[20], temp_sum[17:0]};  
        end

    end //ADDITION

  always @ (posedge clk)
    begin : STAGE2_TIMING_CONTROL
      final_temp_out[18:0] <= temp_out[18:0];
    end //STAGE2_TIMING_CONTROL

  assign stage2_out[18:0] = final_temp_out[18:0];
endmodule 
