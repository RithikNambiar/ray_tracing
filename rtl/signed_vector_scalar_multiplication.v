/*
     Hardware implementation of basic operations                      //  pg38  
     Vector-Scalar Multiplication Implementation                      //  pg40
     All (most) data types - 57 bits long                             //  pg16
     10 bit precision is being used                                   //  pg36
     ray = {x, y, z}                                                  //  concatenation   //pg39
     19 bits are signed fixed point numbers
     9 bits decimal + 10 bits fractional = 19 bits per dimension
     3*19 bits = 57 bits per coordinate
     VECTOR_WIDTH = 57
     SCALAR_WIDTH = 19
     Signed Fixed Point  = {Sign, Integer, Fraction}
     https://www.tutorialspoint.com/fixed-point-and-floating-point-number-representations
     https://www.tutorialspoint.com/negative-binary-numbers
     https://www.rapidtables.com/convert/number/binary-to-decimal.html
     https://www.lettercount.com/
*/


module signed_vector_scalar_multiplication(in_scalar, in_vector, out_vector);

  input  [18:0] in_scalar;             //19 bit scalar
  input  [56:0] in_vector;             //3*19 = 57 bit vector
  output [56:0] out_vector;            //3*19 = 57 bit vector

  wire   [18:0] in_x, in_y, in_z;      //19 bits input for the vector
  reg    [36:0] out_x, out_y, out_z;   //37 bits to hold 37 bit result of [1 + (18*18)] bit product(19th bit is the sign bit)
  
  //   +------+----------+----------+------------+----------+
  //   |37  36|35      28|27      20|19        10|9        0|      //bit field for regs out_x, out_y and out_z    
  //   +------+----------+----------+------------+----------+ 

  assign in_x = in_vector[56:38];   //split in_vector into 3 components of 19 bits each
  assign in_y = in_vector[37:19];
  assign in_z = in_vector[18:0];

  always @*
    begin : VECTOR_SCALAR_MULTIPLICATION

      out_x[35:0] = in_scalar[17:0] * in_x[17:0];  //multiplying magnitudes only
      out_y[35:0] = in_scalar[17:0] * in_y[17:0];
      out_z[35:0] = in_scalar[17:0] * in_z[17:0];
      
      //     +---------------------------------------++-----------------------------------+
      //     |            SIGN BIT CASES             ||       XOR GATE TRUTH TABLE        |
      //     +---------------------------------------++-----------------------------------+
      //     | in_scalar[18]  | in_x[18] | out_x[18] ||           |           |           |
      //     |    scalar      |  vector  |  vector   ||     A     |     B     |     Y     |
      //     +----------------+----------+-----------++-----------+-----------+-----------+
      //     |                |          |           ||           |           |           |
      //     |      0         |    0     |     0     ||     0     |     0     |     0     |
      //     |      0         |    1     |     1     ||     0     |     1     |     1     |
      //     |      1         |    0     |     1     ||     1     |     0     |     1     |
      //     |      1         |    1     |     0     ||     1     |     1     |     0     |
      //     +----------------+----------+-----------++-----------+-----------+-----------+
      // 
      // 0 : +ve
      // 1 : -ve
      //
      // both tables are same    
      out_x[36] = in_scalar[18] ^ in_x[18];     //assigning sign bits for the resultant vector
      out_y[36] = in_scalar[18] ^ in_y[18];     //valid for all cases, even for default min - max assignments
      out_z[36] = in_scalar[18] ^ in_z[18];

      //assigning default min & max values
      //Reduction operator. Logical-ORs all bits from 35 to 28  with each other. Result is one bit wide
      //eg. 2.5*2.5 -> result = 6.25. if we can only hold upto value 4.25, we will assign it as 4.25 instead of 6.25   
      out_x[27:10] = {|out_x[35:28]} ? {18{1'b1}} : out_x[27:10];  
      out_y[27:10] = {|out_y[35:28]} ? {18{1'b1}} : out_x[27:10];  //handles decimal overflows
      out_z[27:10] = {|out_z[35:28]} ? {18{1'b1}} : out_x[27:10];
    end

  assign out_vector[56:0] = {  {out_x[36],out_x[27:10]} , {out_y[36],out_y[27:10]} , {out_z[36],out_z[27:10]}  };   //{x,y,z} //pg  40 //line 6

endmodule 
