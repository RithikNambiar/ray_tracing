/*
     Hardware implementation                                          //  pg38, 39  
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
     https://www.tutorialspoint.com/negative-binary-numbers
*/


module signed_vector_subtraction (in_vector_1, in_vector_2, out_vector);

  input wire  [56:0] in_vector_1, in_vector_2;
  output wire [56:0] out_vector;                   // out_vector = in_vector_1 - in_vector_2

  wire [18:0] x1, y1, z1;   //19 bits 
  wire [18:0] x2, y2, z2;
  reg [19:0] x, y, z;       //20 bits to hold overflow


  /*
  assign {x1[18:0], y1[18:0], z1[18:0] } = in_vector_1[56:0];
  assign {x2[18:0], y2[18:0], z2[18:0] } = in_vector_2[56:0];
  */

  assign x1 = in_vector_1[56:38];   //    in_vector_1
  assign y1 = in_vector_1[37:19];
  assign z1 = in_vector_1[18:0];
  assign x2 = in_vector_2[56:38];   //    in_vector_2
  assign y2 = in_vector_2[37:19];
  assign z2 = in_vector_2[18:0];

  localparam BOTH_POS = 2'b00;              //  x1 +ve, x2 +ve  ;  y1 +ve, y2 +ve  ;  z1 +ve, z2 +ve  ;
  localparam FIRST_POS_SEC_NEG = 2'b01;     //  x1 +ve, x2 -ve  ;  y1 +ve, y2 -ve  ;  z1 +ve, z2 -ve  ;
  localparam FIRST_NEG_SEC_POS = 2'b10;     //  x1 -ve, x2 +ve  ;  y1 -ve, y2 +ve  ;  z1 -ve, z2 +ve  ;
  localparam BOTH_NEG = 2'b11;              //  x1 -ve, x2 -ve  ;  y1 -ve, y2 -ve  ;  z1 -ve, z2 -ve  ;

    always@ *
      begin : X_COMPONENT      

        case ( {x1[18], x2[18]} ) 
          BOTH_POS: begin                                  // (+x1) - (+x2) = (x1) - (x2)
                      if (x1[17:0] < x2[17:0])
                        begin
                          x[18:0] = x2[17:0] - x1[17:0];
                          x[19] = 1;                       //result is -ve
                        end
                  
                      else // (x1[17:0] >= x2[17:0])
                        begin
                          x[18:0] = x1[17:0] - x2[17:0];
                          x[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+x1) - (-x2) = (x1) + (x2)
                               x[18:0] = x1[17:0] + x2[17:0];
                               x[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-x1) - (+x2) = -((x1) + (x2))
                               x[18:0] = x1[17:0] + x2[17:0];
                               x[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-x1) - (-x2) = (x2) - (x1)
                      if (x1[17:0] > x2[17:0])
                        begin
                          x[18:0] = x1[17:0] - x2[17:0];
                          x[19] = 1;                       //result is -ve
                        end 

                      else // (x1[17:0] <= x2[17:0])    
                        begin
                          x[18:0] = x2[17:0] - x1[17:0];
                          x[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG 
           
        endcase

        if( x[19] == 0 && x[18] == 1)                             // assigning min & max values on overflow
          begin
            x[17:0] = {18{1'b1}};  //replication operator
          end

        else if( x[19] == 1 && x[18] == 1)
          begin
            x[17:0] = {18{1'b1}};  //replication operator
          end

      end

    always@ *
      begin : Y_COMPONENT      

        case ( {y1[18], y2[18]} ) 
          BOTH_POS: begin                                  // (+y1) - (+y2) = (y1) - (y2)
                      if (y1[17:0] < y2[17:0])
                        begin
                          y[18:0] = y2[17:0] - y1[17:0];
                          y[19] = 1;                       //result is -ve
                        end
                  
                      else // (y1[17:0] >= y2[17:0])
                        begin
                          y[18:0] = y1[17:0] - y2[17:0];
                          y[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+y1) - (-y2) = (y1) + (y2)
                               y[18:0] = y1[17:0] + y2[17:0];
                               y[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-y1) - (+y2) = -((y1) + (y2))
                               y[18:0] = y1[17:0] + y2[17:0];
                               y[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-y1) - (-y2) = (y2) - (y1)
                      if (y1[17:0] > y2[17:0])
                        begin
                          y[18:0] = y1[17:0] - y2[17:0];
                          y[19] = 1;                       //result is -ve
                        end 

                      else // (y1[17:0] <= y2[17:0])    
                        begin
                          y[18:0] = y2[17:0] - y1[17:0];
                          y[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG d
           
        endcase

        if( y[19] == 0 && y[18] == 1)                             // assigning min & max values on overflow
          begin
            y[17:0] = {18{1'b1}};  //replication operator
          end

        else if( y[19] == 1 && y[18] == 1)
          begin
            y[17:0] = {18{1'b1}};  //replication operator
          end

      end

    always@ *
      begin : Z_COMPONENT      

        case ( {z1[18], z2[18]} ) 
          BOTH_POS: begin                                  // (+z1) - (+z2) = (z1) - (z2)
                      if (z1[17:0] < z2[17:0])
                        begin
                          z[18:0] = z2[17:0] - z1[17:0];
                          z[19] = 1;                       //result is -ve
                        end
                  
                      else // (z1[17:0] >= z2[17:0])
                        begin
                          z[18:0] = z1[17:0] - z2[17:0];
                          z[19] = 0;                       //result is +ve
                        end
                    end //BOTH_POS

          FIRST_POS_SEC_NEG: begin                         // (+z1) - (-z2) = (z1) + (z2)
                               z[18:0] = z1[17:0] + z2[17:0];
                               z[19] = 0;                  //result is +ve 
                             end //FIRST_POS_SEC_NEG   
          
          FIRST_NEG_SEC_POS: begin                         // (-z1) - (+z2) = -((z1) + (z2))
                               z[18:0] = z1[17:0] + z2[17:0];
                               z[19] = 1;                  //result is -ve
                             end //FIRST_NEG_SEC_POS  

          BOTH_NEG: begin                                  // (-z1) - (-z2) = (z2) - (z1)
                      if (z1[17:0] > z2[17:0])
                        begin
                          z[18:0] = z1[17:0] - z2[17:0];
                          z[19] = 1;                       //result is -ve
                        end 

                      else // (z1[17:0] <= z2[17:0])    
                        begin
                          z[18:0] = z2[17:0] - z1[17:0];
                          z[19] = 0;                       //result is +ve
                        end
                    end //BOTH_NEG d
           
        endcase

        if( z[19] == 0 && z[18] == 1)                             // assigning min & max values on overflow
          begin
            z[17:0] = {18{1'b1}};  //replication operator
          end

        else if( z[19] == 1 && z[18] == 1)
          begin
            z[17:0] = {18{1'b1}};  //replication operator
          end

      end

  assign out_vector[56:0] = { {x[19], x[17:0]}, {y[19], y[17:0]}, {z[19], z[17:0]} };   // {x, y, z}      //   pg  39

endmodule