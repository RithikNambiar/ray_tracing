/*
     Hardware implementation of basic operations                      //  pg38  
     Vector-Vector Multiplication Implementation                      //  pg40, 41
     All (most) data types - 57 bits long                             //  pg16
     10 bit precision is being used                                   //  pg36
     ray = {x, y, z}                                                  //  concatenation   //pg40
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


module signed_vector_vector_multiplication(in_vector_1, in_vector_2, out_vector);

  input  [56:0] in_vector_1, in_vector_2;
  output [56:0] out_vector;
  
  wire [18:0] x1, y1, z1;   //19 bits 
  wire [18:0] x2, y2, z2;

  //To hold the resultant vector's elements
  reg [36:0] out_x, out_y, out_z;         //37 bits to hold 37 bit result of [1 + (18*18)] bit product (19th bit is the sign bit)
  reg [35:0] temp_x, temp_y, temp_z;      //temp storage for magnitude only

  assign x1[18:0] = in_vector_1[56:38];   //in_vector_1
  assign y1[18:0] = in_vector_1[37:19];
  assign z1[18:0] = in_vector_1[18:0];
  assign x2[18:0] = in_vector_2[56:38];   //in_vector_2
  assign y2[18:0] = in_vector_2[37:19];
  assign z2[18:0] = in_vector_2[18:0];
 
  always @*
    begin : X_COMPONENT
      temp_x[35:0] = x1[17:0] * x2[17:0];  //multiplying magnitudes only

      //     +-----------------------------++-----------------------------------+
      //     |        SIGN BIT CASES       ||       XOR GATE TRUTH TABLE        |
      //     +-----------------------------++-----------------------------------+
      //     | x1[18] | x2[18] | out_x[18] ||     A     |     B     |     Y     |
      //     +--------+--------+-----------++-----------+-----------+-----------+
      //     |   0    |   0    |     0     ||     0     |     0     |     0     |
      //     |   0    |   1    |     1     ||     0     |     1     |     1     |
      //     |   1    |   0    |     1     ||     1     |     0     |     1     |
      //     |   1    |   1    |     0     ||     1     |     1     |     0     |
      //     +--------+--------+-----------++-----------+-----------+-----------+
      // 
      // 0 : +ve
      // 1 : -ve
      //
      // both tables are same 
      out_x[36] = x1[18] ^ x2[18];        //sign bit of resultant vector

      //assigning default min & max values
      //Reduction operator. Logical-ORs all bits from 35 to 28  with each other. Result is one bit wide
      //eg. 2.5*2.5 -> result = 6.25. if we can only hold upto value 4.05, we will assign it as 4.05 instead of 6.25   
      out_x[27:10] = {|temp_x[35:28]} ? {18{1'b1}} : temp_x[27:10];  
    end

  always @*
    begin : Y_COMPONENT
      temp_y[35:0] = y1[17:0] * y2[17:0];  //multiplying magnitudes only
      out_y[36] = y1[18] ^ y2[18];         //sign bit of resultant vector. Check table & comments from line 42-56
      out_y[27:10] = {|temp_y[35:28]} ? {18{1'b1}} : temp_y[27:10];  //handling overflows. Check comments from line 59-61
    end

  always @*
    begin : Z_COMPONENT
      temp_z[35:0] = z1[17:0] * z2[17:0];  //multiplying magnitudes only
      out_z[36] = z1[18] ^ z2[18];         //sign bit of resultant vector. Check table & comments from line 42-56
      out_z[27:10] = {|temp_z[35:28]} ? {18{1'b1}} : temp_z[27:10];  //handling overflows. Check comments from line 59-61      
    end

  assign out_vector[56:0] = {  {out_x[36],out_x[27:10]} , {out_y[36],out_y[27:10]} , {out_z[36],out_z[27:10]}  };   //{x,y,z} //pg  40 //line 6

endmodule