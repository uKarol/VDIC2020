module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

import mtm_Alu_pkg::*;

    mtm_Alu_bfm    bfm();
   
    mtm_Alu DUT (.clk(bfm.clk), .rst_n(bfm.rst_n), .sin(bfm.sin), .sout(bfm.sout) );

    initial begin
	uvm_config_db #(virtual mtm_Alu_bfm)::set(null, "*", "bfm", bfm);
	run_test();
    end

endmodule : top
