/*
     Hardware implementation                                          //  pg38  
     Vector Addition Implementation                                   //  pg38
     All (most) data types - 57 bits long                             //  pg16
     10 bit precision is being used                                   //  pg36
     ray = {x, y, z}                                                  //  concatenation   //pg39
     19 bits are signed fixed point numbers
     9 bits decimal + 10 bits fractional = 19 bits per dimension
     3*19 bits = 57 bits per coordinate
     VECTOR_WIDTH = 57
     Signed Fixed Point  = {Sign, Integer, Fraction}
     https://www.tutorialspoint.com/fixed-point-and-floating-point-number-representations
*/

module signed_vector_addition (in_vector_1, in_vector_2, out_vector);

  input wire  [56:0] in_vector_1, in_vector_2;
  output wire [56:0] out_vector;

  wire [18:0] x1, y1, z1;   //19 bits 
  wire [18:0] x2, y2, z2;
  reg [19:0] x, y, z;       //20 bits to hold overflow
  
  /*
  assign {x1[19:0], y1[19:0], z1[19:0] } = in_vector_1[56:0];
  assign {x2[19:0], y2[19:0], z2[19:0] } = in_vector_2[56:0];
  */

  assign x1 = in_vector_1[56:38];   //    in_vector_1
  assign y1 = in_vector_1[37:19];
  assign z1 = in_vector_1[18:0];
  assign x2 = in_vector_2[56:38];   //    in_vector_2
  assign y2 = in_vector_2[37:19];
  assign z2 = in_vector_2[18:0];
  

    
    always@ *
      begin : X_COMPONENT                                            
                                                                     // x1 x2         //if 1, the no. is -ve
        if(x1[18] == 0 && x2[18] == 0)                               // 0  0
          begin   
            x = x1[17:0] + x2[17:0];
            x[19] = 0;
          end

        else if(x1[18] == 0 && x2[18] == 1)                          // 0  1
          begin
            x = x1[17:0] - x2[17:0];  

            if (x1[17:0] < x2[17:0])  x[19] =1;        //  sign bit
            else /* (x1[17:0] >= x2[17:0]) */  x[19] =0;
          end

        else if(x1[18] == 1 && x2[18] == 0)                          // 1  0
          begin
            x = x2[17:0] - x1[17:0];

            if (x1[17:0] > x2[17:0])  x[19] =1;        //  sign bit
            else /* (x1[17:0] >= x2[17:0]) */  x[19] =0;
          end

        else //(x1[18] == 1 && x2[18] == 1)                          // 1  1
          begin
            x = x1[17:0] + x2[17:0];
            x[19] = 1;
          end 


        //if()                                                         // assigning min & max values on overflow


      end
       
       
       
       
       
       assign out_vector[56:0] = { {x[19], x[17:0]}, {y[19], y[17:0]}, {z[19], z[17:0]} };   // {x, y, z}      //   pg  39
  
endmodule