module mtm_alu_tester_module(mtm_Alu_bfm bfm);
    
    import mtm_Alu_pkg::*;

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
   function bit[31:0] get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00;
      else if (zero_ones == 2'b11)
        return 32'hFF;
      else
        return $random;
   endfunction : get_data

 initial begin
      bit[31:0]    A;
      bit[31:0]    B;
      bit[2:0] op;
      #100;
     
	
      bfm.reset_alu();
      repeat (600) begin : random_loop
	A = get_data();
        B = get_data();
        op = get_op(); 
	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR);
	#1000;
      end : random_loop
	#1000;
	op = ADD;
        A = 32'hFFFF_FFFF;
        B = 32'hFFFF_FFFF;
	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR);     

	#1000;
	op = SUB;
        A = 32'hFFFF_FFFF;
        B = 32'hFFFF_FFFF;
	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR);     

	#1000;
	op = AND;
        A = 32'hFFFF_FFFF;
        B = 32'hFFFF_FFFF;
	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 

	#1000;
	op = OR;
        A = 32'hFFFF_FFFF;
        B = 32'hFFFF_FFFF;
	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 
	
	#1000;
        op = AND;
        A = 32'h0;
        B = 32'h0;
    	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 

	#1000;
        op = OR;
        A = 32'h0;
        B = 32'h0;
    	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 

	#1000;
        op = ADD;
        A = 32'h0;
        B = 32'h0;
    	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 

	#1000;
        op = SUB;
        A = 32'h0;
        B = 32'h0;
    	bfm.send_serial_data(A, B, op, 0,7, 0, NO_ERR); 


     
   end // initial begin

endmodule : mtm_alu_tester_module
