module top;
import mtm_Alu_pkg::*;

    mtm_Alu_bfm    bfm();
    testbench     testbench_h;
   
    mtm_Alu DUT (.clk(bfm.clk), .rst_n(bfm.rst_n), .sin(bfm.sin), .sout(bfm.sout) );

    initial begin
	testbench_h = new(bfm);
	testbench_h.execute();
    end

endmodule : top
