/*
     Hardware implementation of vector operations                      //  pg42  
     Vector Cross Product Implementation                               //  pg43
     VECTOR_WIDTH = 57
     57 bit signed fixed point  = { 3x[ Sign(1), Integer(8), Fraction(10) ] } = 3x19 = 57 bits
     V1 = {x1, y1, z1}
     V2 = {x2, y2, z2}
     V1 x V2 = { {y1*z2-  z1*y2}, {z1*x2 - x1*z2}, {x1*y2 - y1*x2} }  //total = 57 bits

     V1 x V2 =  | y1*z2-  z1*y2 |
                | z1*x2 - x1*z2 | 
                | x1*y2 - y1*x2 |
                    |       | 
                    V       V
                   LHS     RHS

           [!]   The module multiplication_LHS generates the left column, ie {y1*z2}, {z1*x2} & {x1*y2}
           [!]   The module multiplication_RHS generates the right column, ie {z1*y2}, {x1*z2} & {y1*x2}     

           subtraction_LHS = {y1*z2, z1*x2, x1*y2}
           subtraction_RHS = {z1*y2, x1*z2, y1*x2}

*/

`define VECTOR_VECTOR_MULTIPLICATION 1
`define VECTOR_SUBTRACTION 1

`include "C:/Users/rithi/Desktop/signed_vector_cross_product/includes.v"
//`include "H:/projects/ray_tracing/rtl/includes.v"   
//`include "H:/projects/ray_tracing/rtl/signed_vector_vector_multiplication.v"
//`include "H:/projects/ray_tracing/rtl/signed_vector_subtraction.v"

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

  wire [56:0] multiply_Y1Z1X1;
  wire [56:0] multiply_Z2X2Y2;
  wire [56:0] multiply_Z1X1Y1;
  wire [56:0] multiply_Y2Z2X2;

  wire [56:0] subtraction_LHS;
  wire [56:0] subtraction_RHS;

  assign wire_x1[18:0] = in_vector_1[56:38];
  assign wire_x2[18:0] = in_vector_2[56:38];
  assign wire_y1[18:0] = in_vector_1[37:19]; //split x, y & z elements of the 2 input vectors
  assign wire_y2[18:0] = in_vector_2[37:19];
  assign wire_z1[18:0] = in_vector_1[18:0];
  assign wire_z2[18:0] = in_vector_2[18:0];
  
  assign multiply_Y1Z1X1[56:0] = {wire_y1[18:0], wire_z1[18:0], wire_x1[18:0]};
  assign multiply_Z2X2Y2[56:0] = {wire_z2[18:0], wire_x2[18:0], wire_y2[18:0]};

  assign multiply_Z1X1Y1[56:0] = {wire_y1[18:0], wire_z1[18:0], wire_x1[18:0]};
  assign multiply_Y2Z2X2[56:0] = {wire_y2[18:0], wire_z2[18:0], wire_x2[18:0]};

  signed_vector_vector_multiplication multiplication_LHS ( .in_vector_1 (multiply_Y1Z1X1),
                                                           .in_vector_2 (multiply_Z2X2Y2), 
                                                           .out_vector  (subtraction_LHS)
                                                         );

  signed_vector_vector_multiplication multiplication_RHS ( .in_vector_1 (multiply_Z1X1Y1),
                                                           .in_vector_2 (multiply_Y2Z2X2), 
                                                           .out_vector  (subtraction_RHS)
                                                         );

  signed_vector_subtraction subtraction                  ( .in_vector_1 (subtraction_LHS),
                                                           .in_vector_2 (subtraction_RHS), 
                                                           .out_vector  (out_vector     )
                                                         );

endmodule


`undef VECTOR_VECTOR_MULTIPLICATION 
`undef VECTOR_SUBTRACTION 