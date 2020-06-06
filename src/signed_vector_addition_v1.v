/*
     Hardware implementation                                          //  pg38  
     Vector Addition Implementation                                   //  pg38
     All data types - 57 bits long                                    //  pg16
     10 bit precision is being used                                   //  pg36
     ray = {x, y, z}                                                  //  concatenation   //pg39
     19 bits are signed fixed point numbers
     9 bits decimal + 10 bits fractional = 19 bits per dimension
     3*19 bits = 57 bits per coordinate
     VECTOR_WIDTH = 57
*/

module vector_addition (in_vector_1, in_vector_2, out_vector);

 localparam VECTOR_WIDTH = 57;

  input wire  [VECTOR_WIDTH-1 : 0] in_vector_1, in_vector_2;
  output wire [VECTOR_WIDTH-1 : 0] out_vector;

   wire [19:0] x, y, z;                  //20 bits long, 20th bit is to be truncated

    assign x = in_vector_1[56:38] + in_vector_2[56:38];
    assign y = in_vector_1[37:19] + in_vector_2[37:19];
    assign z = in_vector_1[18:0] + in_vector_2[18:0]; 

    assign out_vector[56:0] = { x[18:0], y[18:0], z[18:0] };  //concatenation of x, y & z        //   pg  39

  
endmodule