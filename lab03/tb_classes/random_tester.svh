class random_tester extends base_tester;
    `uvm_component_utils(random_tester)
	
   function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction : new

   // Random data generation functions

  function opcode get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
	3'b000: return AND; 
	3'b001: return OR; 
	3'b100: return ADD; 
	3'b101: return SUB; 
	3'b010: return RST_OP;
	3'b011: return RES_OP_2;
	3'b110: return RES_OP_3;
	3'b111: return RES_OP_4;
      endcase // case (op_choice)
   endfunction : get_op

  function opcode get_valid_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
	3'b000: return AND; 
	3'b001: return OR; 
	3'b100: return ADD; 
	3'b101: return SUB; 
	default: return RST_OP;

      endcase // case (op_choice)
   endfunction : get_valid_op

//---------------------------------
   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data

endclass : random_tester
