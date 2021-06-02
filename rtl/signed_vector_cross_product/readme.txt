signed_vector_cross_product_v2 is an alternate implementation of signed_vector_cross_product.
The modules vector vector multiplication & signed_vector_subtraction are instantiated and port  mapped.
The ports are mapped in a manner that gives the same result as signed_vector_cross_product.
Synthesis of both signed_vector_cross_product and signed_vector_cross_product_v2 gives more or less the same rtl schematic.
Comparing the two rtls schematics visually shows a 95% match (or more) in the module logic/circuitry.
Synthesized was performed using Mentor Graphics Precision Synthesis.


NOTE:       For building other, bigger modules signed_vector_cross_product will be used instead of signed_vector_cross_product_v2
