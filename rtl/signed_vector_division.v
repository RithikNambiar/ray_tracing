/*
     Hardware implementation of basic operations                      //  pg38  
     Vector Division Implementation                                   //  pg41
     All (most) data types - 57 bits long                             //  pg16
     10 bit precision is being used                                   //  pg36
     ray = {x, y, z}                                                  //  concatenation   //pg39
     19 bits are signed fixed point numbers
     9 bits decimal + 10 bits fractional = 19 bits per dimension
     3*19 bits = 57 bits per coordinate
     VECTOR_WIDTH = 57 
     Signed Fixed Point  = {Sign, Integer, Fraction} 
     https://www.tutorialspoint.com/fixed-point-and-floating-point-number-representations 
     https://www.tutorialspoint.com/negative-binary-numbers 
     https://wwws.rapidtables.com/convert/number/binary-to-decimal.html
     https://www.lettercount.com/ 
     https://stackoverflow.com/questions/24580154/fixed-point-integer-division-fractional-division-algorithm 
     https://stackoverflow.com/questions/35433371/how-to-do-division-of-two-fixed-point-64-bits-variables-in-synthesizable-verilog 
     PROCEDURE: Left shift the dividend by 10 bits, perform the division, and take the 19 LSBs as the result,
                where 10 LSBs are the fractional part.
*/

module signed_vector_division(in_vector_1, in_vector_2, clk, out_vector);
 
  parameter LEFT_SHIFT_RESOLUTION = 10; // no. of bits by which dividend is left shifted. Check pg 41

  input clk;
  input  [56:0] in_vector_1, in_vector_2;

  output [56:0] out_vector;

  reg [18:0] reg_x1, reg_x2;
  reg [18:0] reg_y1, reg_y2;  //to hold values after splitting in_vector_1 & in_vector_2 into x, y & z components
  reg [18:0] reg_z1, reg_z2;

  reg [27:0] x1_left_shift, y1_left_shift, z1_left_shift;  //no use for the sign bit. It will be calculated later

  reg x_sign_bit, y_sign_bit, z_sign_bit;

  reg [27:0] reg_x, reg_y, reg_z;     //to hold temporary values of the resultant vector's 3 components.   //magnitude only 
   
  reg [56:0] reg_out_vector;          //to hold resultant vector after concatenation of reg_x, reg_y & reg_z 

  always @(posedge clk)
    begin : SIGNED_VECTOR_DIVISION
      //SPLIT INPUT VECTORS
      reg_x1[18:0] = in_vector_1[56:38];            //load x component into temporary, internal wires
      reg_x2[18:0] = in_vector_2[56:38];
      reg_y1[18:0] = in_vector_1[37:19];            //load y component into temporary, internal wires
      reg_y2[18:0] = in_vector_2[37:19];
      reg_z1[18:0] = in_vector_1[18:0];             //load z component into temporary, internal wires
      reg_z2[18:0] = in_vector_2[18:0];

      //LEFT SHIFT DIVIDEND
      x1_left_shift[27:0] = reg_x1[17:0] << LEFT_SHIFT_RESOLUTION;  
      y1_left_shift[27:0] = reg_y1[17:0] << LEFT_SHIFT_RESOLUTION;  //LEFT_SHIFT_RESOLUTION = 10    // check line 24
      z1_left_shift[27:0] = reg_z1[17:0] << LEFT_SHIFT_RESOLUTION;  

      //DIVIDE LEFT SHIFTED DIVIDEND
      reg_x[27:0] <= x1_left_shift[27:0] / reg_x2[17:0]; 
      reg_y[27:0] <= y1_left_shift[27:0] / reg_y2[17:0];  //only magnitude is being calculated
      reg_z[27:0] <= z1_left_shift[27:0] / reg_z2[17:0];

      //CALCULATE SIGN BIT
      x_sign_bit <= reg_x1[18] ^ reg_x2[18];
      y_sign_bit <= reg_y1[18] ^ reg_y2[18];
      z_sign_bit <= reg_z1[18] ^ reg_z2[18];

      //CONCATENATE COMPONENTS
      reg_out_vector[56:0] <= { {x_sign_bit, reg_x[17:0]}, {y_sign_bit, reg_y[17:0]}, {z_sign_bit, reg_z[17:0]} };
    end
  
  assign out_vector[56:0] = reg_out_vector[56:0];

endmodule
