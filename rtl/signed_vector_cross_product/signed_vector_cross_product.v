/*
     Hardware implementation of vector operations                      //  pg42  
     Vector Cross Product Implementation                               //  pg43
     VECTOR_WIDTH = 57
     57 bit signed fixed point  = { 3x[ Sign(1), Integer(8), Fraction(10) ] } = 3x19 = 57 bits
     V1 = {x1, y1, z1}
     V2 = {x2, y2, z2}
     V1 x V2 = { {y1*z2-  z1*y2}, {z1*x2 - x1*z2}, {x1*y2 - y1*x2} }  //total = 57 bits
*/
    
module signed_vector_cross_product (in_vector_1, in_vector_2, out_vector);
    
  input [56:0] in_vector_1;
  input [56:0] in_vector_2; 
    
  output [56:0] out_vector;

  wire [18:0] wire_x1;
  wire [18:0] wire_y1;  // to hold x, y & z elemtents of in_vector_1
  wire [18:0] wire_z1;
  wire [18:0] wire_x2;
  wire [18:0] wire_y2;  // to hold x, y & z elemtents of in_vector_2
  wire [18:0] wire_z2;

  reg [36:0] temp_y1z2;
  reg [36:0] temp_z1y2;
  reg [36:0] temp_z1x2;
  reg [36:0] temp_x1z2;
  reg [36:0] temp_x1y2;
  reg [36:0] temp_y1x2;

  reg [18:0] product_y1z2;
  reg [18:0] product_z1y2;
  reg [18:0] product_z1x2;
  reg [18:0] product_x1z2;
  reg [18:0] product_x1y2;
  reg [18:0] product_y1x2;

  reg [19:0] temp_x;
  reg [19:0] temp_y;
  reg [19:0] temp_z;

  reg [18:0] out_x;
  reg [18:0] out_y;
  reg [18:0] out_z;

  localparam BOTH_POS          = 2'b00;     //  x1 +ve, x2 +ve  ;  y1 +ve, y2 +ve  ;  z1 +ve, z2 +ve  ;
  localparam FIRST_POS_SEC_NEG = 2'b01;     //  x1 +ve, x2 -ve  ;  y1 +ve, y2 -ve  ;  z1 +ve, z2 -ve  ;
  localparam FIRST_NEG_SEC_POS = 2'b10;     //  x1 -ve, x2 +ve  ;  y1 -ve, y2 +ve  ;  z1 -ve, z2 +ve  ;
  localparam BOTH_NEG          = 2'b11;     //  x1 -ve, x2 -ve  ;  y1 -ve, y2 -ve  ;  z1 -ve, z2 -ve  ;

  assign wire_x1[18:0] = in_vector_1[56:38];
  assign wire_x2[18:0] = in_vector_2[56:38];
  assign wire_y1[18:0] = in_vector_1[37:19]; //split x, y & z elements of the 2 input vectors
  assign wire_y2[18:0] = in_vector_2[37:19];
  assign wire_z1[18:0] = in_vector_1[18:0];
  assign wire_z2[18:0] = in_vector_2[18:0];

  always @ *
    begin : X_COMPONENT
      begin  : PRODUCT_Y1Z2
        temp_y1z2[35:0] = wire_y1[17:0] * wire_z2[17:0]; //multiplying magnitudes only 
        temp_y1z2[36] = wire_y1[18] ^ wire_z2[18]; //sign bit calculation           
        product_y1z2[18:0] = {|temp_y1z2[35:28]} ? {temp_y1z2[36],{18{1'b1}}} : {temp_y1z2[36],temp_y1z2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_Y1Z2

      begin  : PRODUCT_Z1Y2
        temp_z1y2[35:0] = wire_z1[17:0] * wire_y2[17:0]; //multiplying magnitudes only
        temp_z1y2[36] = wire_z1[18] ^ wire_y2[18]; //sign bit calculation         
        product_z1y2[18:0] = {|temp_z1y2[35:28]} ? {temp_z1y2[36],{18{1'b1}}} : {temp_z1y2[36],temp_z1y2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_Z1Y2

      begin : SUBTRACTION__Y1Z2_Z1Y2
        case ( {product_y1z2[18], product_z1y2[18]} ) 
          BOTH_POS: begin                                  // (+x1) - (+x2) = (x1) - (x2)
                      if (product_y1z2[17:0] < product_z1y2[17:0])
                        begin
                          temp_x[18:0] = product_z1y2[17:0] - product_y1z2[17:0];
                          temp_x[19] = 1;                       //result is -ve
                        end
                  
                      else // (product_y1z2[17:0] >= product_z1y2[17:0])
                        begin
                          temp_x[18:0] = product_y1z2[17:0] - product_z1y2[17:0];
                          temp_x[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+x1) - (-x2) = (x1) + (x2)
                               temp_x[18:0] = product_y1z2[17:0] + product_z1y2[17:0];
                               temp_x[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-x1) - (+x2) = -((x1) + (x2))
                               temp_x[18:0] = product_y1z2[17:0] + product_z1y2[17:0];
                               temp_x[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-x1) - (-x2) = (x2) - (x1)
                      if (product_y1z2[17:0] > product_z1y2[17:0])
                        begin
                          temp_x[18:0] = product_y1z2[17:0] - product_z1y2[17:0];
                          temp_x[19] = 1;                       //result is -ve
                        end 

                      else // (product_y1z2[17:0] <= product_z1y2[17:0])    
                        begin
                          temp_x[18:0] = product_z1y2[17:0] - product_y1z2[17:0];
                          temp_x[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG 
        endcase
      
        out_x[18:0] = temp_x[18] ? {temp_x[19],{18{1'b1}}} : {temp_x[19], temp_x[17:0]};
      end  //SUBTRACTION__Y1Z2_Z1Y2
    end //X_COMPONENT

  always @ *
    begin : Y_COMPONENT
      begin  : PRODUCT_Z1X2
        temp_z1x2[35:0] = wire_z1[17:0] * wire_x2[17:0]; //multiplying magnitudes only 
        temp_z1x2[36] = wire_z1[18] ^ wire_x2[18]; //sign bit calculation           
        product_z1x2[18:0] = {|temp_z1x2[35:28]} ? {temp_z1x2[36],{18{1'b1}}} : {temp_z1x2[36],temp_z1x2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_Z1X2

      begin  : PRODUCT_X1Z2
        temp_x1z2[35:0] = wire_z1[17:0] * wire_y2[17:0]; //multiplying magnitudes only
        temp_x1z2[36] = wire_z1[18] ^ wire_y2[18]; //sign bit calculation         
        product_x1z2[18:0] = {|temp_x1z2[35:28]} ? {temp_x1z2[36],{18{1'b1}}} : {temp_x1z2[36],temp_x1z2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_X1Z2

      begin : SUBTRACTION__Z1X2_X1Z2
        case ( {product_z1x2[18], product_x1z2[18]} ) 
          BOTH_POS: begin                                  // (+x1) - (+x2) = (x1) - (x2)
                      if (product_z1x2[17:0] < product_x1z2[17:0])
                        begin
                          temp_y[18:0] = product_x1z2[17:0] - product_z1x2[17:0];
                          temp_y[19] = 1;                       //result is -ve
                        end
                  
                      else // (product_z1x2[17:0] >= product_x1z2[[17:0])
                        begin
                          temp_y[18:0] = product_z1x2[17:0] - product_x1z2[17:0];
                          temp_y[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+x1) - (-x2) = (x1) + (x2)
                               temp_y[18:0] = product_z1x2[17:0] + product_x1z2[17:0];
                               temp_y[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-x1) - (+x2) = -((x1) + (x2))
                               temp_y[18:0] = product_z1x2[17:0] + product_x1z2[17:0];
                               temp_y[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-x1) - (-x2) = (x2) - (x1)
                      if (product_z1x2[17:0] > product_x1z2[17:0])
                        begin
                          temp_y[18:0] = product_z1x2[17:0] - product_x1z2[17:0];
                          temp_y[19] = 1;                       //result is -ve
                        end 

                      else // (product_z1x2[17:0] <= product_x1z2[[17:0])    
                        begin
                          temp_y[18:0] = product_x1z2[17:0] - product_z1x2[17:0];
                          temp_y[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG            
        endcase

        out_y[18:0] = temp_y[18] ? {temp_y[19],{18{1'b1}}} : {temp_y[19], temp_y[17:0]};
      end  //SUBTRACTION__Z1X2_X1Z2
    end //Y_COMPONENT


  always @ *
    begin : Z_COMPONENT
      begin  : PRODUCT_X1Y2
        temp_x1y2[35:0] = wire_x1[17:0] * wire_y2[17:0]; //multiplying magnitudes only 
        temp_x1y2[36] = wire_x1[18] ^ wire_y2[18]; //sign bit calculation           
        product_x1y2[18:0] = {|temp_x1y2[35:28]} ? {temp_x1y2[36],{18{1'b1}}} : {temp_x1y2[36],temp_x1y2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_X1Y2

      begin  : PRODUCT_Y1X2
        temp_y1x2[35:0] = wire_y1[17:0] * wire_x2[17:0]; //multiplying magnitudes only
        temp_y1x2[36] = wire_y1[18] ^ wire_x2[18]; //sign bit calculation         
        product_y1x2[18:0] = {|temp_y1x2[35:28]} ? {temp_y1x2[36],{18{1'b1}}} : {temp_y1x2[36],temp_y1x2[27:10]};  //final output & overflow handling        
      end  //PRODUCT_Y1X2

      begin : SUBTRACTION__X1Y2_Y1X2
        case ( {product_x1y2[18], product_y1x2[18]} ) 
          BOTH_POS: begin                                  // (+x1) - (+x2) = (x1) - (x2)
                      if (product_x1y2[17:0] < product_y1x2[17:0])
                        begin
                          temp_z[18:0] = product_y1x2[17:0] - product_x1y2[17:0];
                          temp_z[19] = 1;                       //result is -ve
                        end
                  
                      else // (product_x1y2[17:0] >= product_y1x2[17:0])
                        begin
                          temp_z[18:0] = product_x1y2[17:0] - product_y1x2[17:0];
                          temp_z[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+x1) - (-x2) = (x1) + (x2)
                               temp_z[18:0] = product_x1y2[17:0] + product_y1x2[17:0];
                               temp_z[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-x1) - (+x2) = -((x1) + (x2))
                               temp_z[18:0] = product_x1y2[17:0] + product_y1x2[17:0];
                               temp_z[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-x1) - (-x2) = (x2) - (x1)
                      if (product_x1y2[17:0] > product_y1x2[17:0])
                        begin
                          temp_z[18:0] = product_x1y2[17:0] - product_y1x2[17:0];
                          temp_z[19] = 1;                       //result is -ve
                        end 

                      else // (product_x1y2[17:0] <= product_y1x2[17:0])    
                        begin
                          temp_z[18:0] = product_y1x2[17:0] - product_x1y2[17:0];
                          temp_z[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG 
           
        endcase
      
        out_z[18:0] = temp_z[18] ? {temp_z[19],{18{1'b1}}} : {temp_z[19], temp_z[17:0]};
      end  //SUBTRACTION__X1Y2_Y1X2
    end //Z_COMPONENT

 assign out_vector[56:0] = {out_x[18:0], out_y[18:0], out_z[18:0]};

endmodule