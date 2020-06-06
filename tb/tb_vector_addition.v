`include "/home/rithik/projects/verilog/ray_tracing/src/vector_addition.v" 

module tb_vector_addition;

  wire [56:0] tb_in_1, tb_in_2, tb_out;

  //module vector_addition (in_vector_1, in_vector_2, out_vector);
  vector_addition tb_instance (.in_vector_1(tb_in_1), .in_vector_2(tb_in_2), .out_vector(tb_out));

    always @*
      begin : increment_input_vectors
        integer i = 0, j = 0; 

        for ( i=0 ;i<(2**57) ;i=i+1 ) begin
            assign tb_in_1 = tb_in_1 +1;
            
        end  
      end


endmodule