/*
  Read about verilog File I/O here -
  http://www.asic.co.in/Index_files/verilog_files/File_IO.htm
  http://www.asic-world.com/verilog/verilog2k3.html
  Works with Verilog 2001 only
  To read a line at a time use $fgets                                        (!)
*/

module tb_signed_vector_addition;

parameter input_value_count = 101;   //set the number of values to be read as inputs from the input vector files

wire [56:0] in_vector_1, in_vector_2, out_vector;
reg [56:0] test_in_1, test_in_2; 

reg [56:0] test_file_1[1:100000];     //to load data from file containing test vectors for test_in_1
reg [56:0] test_file_2[1:100000];     //to load data from file containing test vectors for test_in_1

integer mcd_sim_results;              //multi channel file descriptor (mcd file) for simulation results 

integer i = 0;                        //for feeding values from readmemb to test _in_1 & test_in_2

assign in_vector_1[56:0] = test_in_1[56:0];    
assign in_vector_2[56:0] = test_in_2[56:0];  

//module signed_vector_addition (in_vector_1, in_vector_2, out_vector);
signed_vector_cross_product dut_instance (.in_vector_1(in_vector_1), .in_vector_2(in_vector_2), .out_vector(out_vector));

initial
  begin
    mcd_sim_results = $fopen("H:/eda-tool-projects/ray_tracing/sim_results/tb_signed_vector_cross_product_sim_results.txt");

    //when doing $readmemb, if there are any no.s apart from 1 & 0, all regs will be loaded with 'X'
    //after the occurence of that decimal no.
    //Eg if there is no. 2 on 3rd line. regs that will be loaded with value of line 3 and after will be loaded with 'X'
    //only binary no.s should be there in the file.
    //for $readmemh,  only hex no.s are allowed. any other no hex characters will be replaced by 'X'
    $readmemb ("H:/projects/ray_tracing/test_inputs/test_input_1.txt", test_file_1);
    $readmemb ("H:/projects/ray_tracing/test_inputs/test_input_2.txt", test_file_2);
        
    //test_in_1[56:0] = {57{1'b0}};     
    //test_in_2[56:0] = {57{1'b0}};     
    for(i = 0; i <= input_value_count;i=i+1)
      begin        
        
        test_in_1[56:0] = test_file_1 /*[56:0]*/ [i];
        test_in_2[56:0] = test_file_2 /*[56:0]*/ [i];
      
        #20

        if (^test_file_1 /*[56:0]*/ [i] === 1'bX)     //== will not work. Need to use === or case inequality operator for it to work
          begin
            $display ("Test Vector File 1 Loaded Incorrectly at %tns", $time);
            //$stop;
          end

        if (^test_file_2 /*[56:0]*/ [i] === 1'bX)     //== will not work. Need to use === or case inequality operator for it to work
          begin
            $display ("Test Vector File 2 Loaded Incorrectly at %tns", $time);
            //$stop;
          end        
        
        $fmonitor (mcd_sim_results, "%b", out_vector);
        $monitor ("%tns %b", $time, out_vector);
      end
    
  end

endmodule  
