module tb_signed_vector_addition;

wire [56:0] in_vector_1, in_vector_2, out_vector;
reg [56:0] test_in_1, test_in_2; 

assign in_vector_1[56:0] = test_in_1[56:0];    
assign in_vector_2[56:0] = test_in_2[56:0];  

//module signed_vector_addition (in_vector_1, in_vector_2, out_vector);
signed_vector_addition dut_instance (.in_vector_1(in_vector_1), .in_vector_2(in_vector_2), .out_vector(out_vector));

initial
  begin
    #0  
    test_in_1[56:0] = {57{1'b0}};
    test_in_2[56:0] = {57{1'b0}};

    #20                                     
    test_in_1[56:0] = {57{1'b1}};
    test_in_2[56:0] = {57{1'b1}};

    #20                                     
    test_in_1[56:0] = {57{1'b1}};
    test_in_2[56:0] = {57{1'b0}};

    #20                                     
    test_in_1[56:0] = {57{1'b0}};
    test_in_2[56:0] = {57{1'b1}};

    #20  
    test_in_1[56:0] = { {19{1'b0}}, {19{1'b1}}, {19{1'b0}} };
    test_in_2[56:0] = { {19{1'b1}}, {19{1'b1}}, {19{1'b1}} };

    #20  
    test_in_1[56:0] = 57'b0110100001001111000_1000010001001100001_1000010000111110001 ;
    test_in_2[56:0] = 57'b0100011011100001010_0000000110110011001_1111001101100111000 ;
    
    #20  
    test_in_1[56:0] = 57'b0100011011100001010_0000000110110011001_1111001101100111000 ;
    test_in_2[56:0] = 57'b0110111010101011110_0011100101000111111_0000011010001001011 ;
    
    #20  
    test_in_1[56:0] = 57'b1000110001111110011_1011011110000100011_1101101001110011010;
    test_in_2[56:0] = 57'b0001000000010011001_0111100010000111000_0110011011111111000 ;
    
    #20  
    test_in_1[56:0] = 57'b1111010101010010100_1100111101110001011_0101001110001110001 ;
    test_in_2[56:0] = 57'b1100111000001011110_1001100011001000111_0110000111010011111 ;
       
    #20  
    test_in_1[56:0] = 57'b1110100001001011111_0001101101100000101_1011101001000111001 ;
    test_in_2[56:0] = 57'b0011101111100000110_1010010100101011011_1010001100110011011 ;
    
    #20  
    test_in_1[56:0] = 57'b1100001111100010010_1001100110110100101_0111100100010110001 ;
    test_in_2[56:0] = 57'b1001010101100011101_0110010110000011111_0010100111001101110 ;
    
    #20  
    test_in_1[56:0] = 57'b0100100011010000001_1111001010001100001_1101001100101100111 ;
    test_in_2[56:0] = 57'b1101011110001111001_1110011101001011010_1011110110111111000 ;
    
    #20  
    test_in_1[56:0] = 57'b0011010011111010100_0011110011011101001_0100101011011001111 ;
    test_in_2[56:0] = 57'b0000001101011111011_1101100111011101110_0111000110110100001 ;
    
    #20  
    test_in_1[56:0] = 57'b1000000011000001010_1010101101001100011_0101100100100000110 ;
    test_in_2[56:0] = 57'b1101000010001001000_1010110111100001011_1010011001111011110 ;
    
    #20  
    test_in_1[56:0] = 57'b1001101001000010101_1101111011011101101_1111101011000100000 ;
    test_in_2[56:0] = 57'b1001101101110010101_0111000101010001110_1010100101110110110 ;
     
  end
endmodule