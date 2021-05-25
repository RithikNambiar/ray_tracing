  module dot_product_stage_1 (stage1_in_1, stage1_in_2, clk, stage1_out_x, stage1_out_y, stage1_out_z);

  input [56:0] 	stage1_in_1;
  input [56:0] 	stage1_in_2;
  input         clk; 
    
  output [18:0] stage1_out_x;
  output [18:0] stage1_out_y;
  output [18:0] stage1_out_z;
    
  reg [18:0] reg_x1; 
  reg [18:0] reg_x2;
  reg [18:0] reg_y1;     // temporary vairables(wires) to hold values after 
  reg [18:0] reg_y2;     // splitting 'stage1_in_1' & 'stage1_in_2' into x, y & z components
  reg [18:0] reg_z1;   
  reg [18:0] reg_z2;

  reg [36:0] temp_stage1_out_x;    //temporary wire to hold value after multiplication
  reg [36:0] temp_stage1_out_y;    // 18x18 = 36 bit product + 1 sign bit
  reg [36:0] temp_stage1_out_z;

  reg [18:0] temp_out_x;
  reg [18:0] temp_out_y;      //temporary reg to hold final value of product
  reg [18:0] temp_out_z;
  
  always @ *
    begin: ARITHMETIC_BLOCK
      reg_x1[18:0] = stage1_in_1[56:38];     //load x component into temporary, internal reg
      reg_x2[18:0] = stage1_in_2[56:38];
      reg_y1[18:0] = stage1_in_1[37:19];     //load y component into temporary, internal reg
      reg_y2[18:0] = stage1_in_2[37:19];
      reg_z1[18:0] = stage1_in_1[18:0];      //load z component into temporary, internal reg
      reg_z2[18:0] = stage1_in_2[18:0];
        
      //X_COMPONENT
      temp_stage1_out_x[36] = reg_x1[18] ^ reg_x2[18];      //sign bit calculation
      temp_stage1_out_x[35:0] = reg_x1[17:0] * reg_x2[17:0];  //calculate product's magnitude 
  
      //Y_COMPONENT
      temp_stage1_out_y[36] = reg_y1[18] ^ reg_y2[18];      //sign bit calculation
      temp_stage1_out_y[35:0] = reg_y1[17:0] * reg_y2[17:0];  //calculate product's magnitude 
     
      //Z_COMPONENT
      temp_stage1_out_z[36] = reg_z1[18] ^ reg_z2[18];      //sign bit calculation
      temp_stage1_out_z[35:0] = reg_z1[17:0] * reg_z2[17:0];  //calculate product's magnitude
    end

  always @ (posedge clk)
    begin: OVERFLOW_HANDLING_DELAY_BLOCK
      temp_out_x[18:0] <= {|temp_stage1_out_x[35:28]}  ?  { temp_stage1_out_x[36], {18{1'b1}} } : { temp_stage1_out_x[36], temp_stage1_out_x[27:10] };
      temp_out_y[18:0] <= {|temp_stage1_out_y[35:28]}  ?  { temp_stage1_out_y[36], {18{1'b1}} } : { temp_stage1_out_y[36], temp_stage1_out_y[27:10] };
      temp_out_z[18:0] <= {|temp_stage1_out_z[35:28]}  ?  { temp_stage1_out_z[36], {18{1'b1}} } : { temp_stage1_out_z[36], temp_stage1_out_z[27:10] };
    end 

  assign stage1_out_x[18:0] = temp_out_x[18:0];
  assign stage1_out_y[18:0] = temp_out_y[18:0];
  assign stage1_out_z[18:0] = temp_out_z[18:0];

endmodule

