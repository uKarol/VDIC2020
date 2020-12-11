class coverage extends uvm_subscriber #(command_transaction);
    `uvm_component_utils(coverage)

    

    bit                  [31:0] A;
    bit                  [31:0] B; 
    bit[2:0]                op_set;

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

   covergroup op_cov;

      option.name = "cg_op_cov";

      coverpoint op_set {
         // #A1 test all operations
         bins A1_single_cycle[] = {[AND : SUB]};     
	 // #A2 test all operations after reset
         bins A2_rst_operation[] = ( RST_OP=> [AND:SUB]);
         // #A3 test reset after all operations
         bins A3_operation_rst[] = ([AND:SUB] => RST_OP);
         // #A5 Error CRC code
         bins A5_two_operations[] = {ERR_CRC};

         // #A6 Error OP code
         bins A6_two_operations[] = {ERR_OP};

	 // #A7 Error DATA code
         bins A7_two_operations[] = {ERR_DATA};

         // #A8 Test reset after all errors
         bins A8_two_operations[] = ([ERR_CRC:ERR_DATA] => RST_OP );

         // #A9 Test reset after all errors
         bins A9_two_operations[] = (RST_OP => [ERR_CRC:ERR_DATA] );

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {RST_OP, RES_OP_2, RES_OP_3, RES_OP_4};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00_00_00_00};
         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
         bins ones  = {'hFF_FF_FF_FF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00_00_00_00};
         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
         bins ones  = {'hFF_FF_FF_FF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_and_00 = binsof (all_ops) intersect {AND} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {OR} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	 
	 bins B1_add_00 = binsof (all_ops) intersect {ADD} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {SUB} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));


         // #B2 simulate all one input for all the operations

         bins B2_and_FF = binsof (all_ops) intersect {AND} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {OR} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_add_FF = binsof (all_ops) intersect {ADD} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {SUB} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

endgroup

 
/*    covergroup flags_cov;
       option.name = "mtm alu flags cov";
      
       flags : coverpoint bfm.expected_flags {
	    wildcard bins carry = {4'b1xxx};
	    wildcard bins overflow = {4'bx1xx};
	    wildcard bins zero = {4'bxx1x};
	    wildcard bins negative = {4'bxxx1};
	    bins no_flag = {4'b0000};	      
       }

   endgroup


    covergroup err_flags_cov;
       option.name = "mtm alu error flags cov";
      
       flags : coverpoint bfm.expected_err {
	    wildcard bins err_data = {ERR_DATA};
	    wildcard bins err_crc = {ERR_CRC};
	    wildcard bins err_op = {ERR_OP};
	    bins no_err = {NO_ERR};    
       }
    endgroup*/


    function new( string name, uvm_component parent );
	super.new(name, parent);
        op_cov = new();
        zeros_or_ones_on_ops = new();
       // err_flags_cov = new();
        //flags_cov = new();
    endfunction : new

    function void write(command_transaction t);
        A      = t.A;
        B      = t.B;
        op_set = t.op;
         op_cov.sample();
         zeros_or_ones_on_ops.sample();
	// err_flags_cov.sample();
//	 flags_cov.sample();
   endfunction : write

endclass : coverage
