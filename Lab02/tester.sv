module tester(mtm_Alu_bfm bfm);
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


initial begin 
      

      	integer random_ctr;      

  
    	// test case 1
    	// valid frames 
    
    	$display("RANDOM TESTS START" );
    	
	// random operation, random data
    	for (random_ctr = 0; random_ctr < 5000; random_ctr = random_ctr + 1) begin
		bfm.expected_err = NO_ERR;
        	bfm.data_A = get_data();
        	bfm.data_B = get_data();
		bfm.opcode = get_op();
		if( bfm.opcode == RST_OP ) bfm.reset_alu();
		if( bfm.opcode == RST_OP || bfm.opcode == RES_OP_2 || bfm.opcode == RES_OP_3 || bfm.opcode == RES_OP_4 ) bfm.expected_err = ERR_OP;
		bfm.send_serial_data(bfm.data_A, bfm.data_B, bfm.opcode, 0, 7, 0); 
        	#(1000);      
    	end 
	
	
	// random tests with wrong CRC
    	for (random_ctr = 0; random_ctr < 1000; random_ctr = random_ctr + 1) begin
		bfm.expected_err = ERR_CRC;
        	bfm.data_A = get_data();
        	bfm.data_B = get_data();
		bfm.opcode = get_valid_op();
		if( bfm.opcode == RST_OP ) begin
			bfm.reset_alu();
		end
		else bfm.send_serial_data(bfm.data_A, bfm.data_B, bfm.opcode, 1, 7, 0); 
        	#(1000);      
    	end 
	
	
	// old test backup
    	for (random_ctr = 0; random_ctr < 0; random_ctr = random_ctr + 1) begin
		bfm.expected_err = ERR_DATA;
        	bfm.data_A = get_data();
        	bfm.data_B = get_data();
		bfm.opcode = get_valid_op();
		if( bfm.opcode == RST_OP ) begin
			bfm.reset_alu();
		end
		else begin
			bfm.length = $random;
			if( bfm.length == 7 ) begin 
				bfm.no_ctl = 1;
				//bfm.length;
				//bfm.expected_err = ERR_CRC;
			end
			else bfm.no_ctl = $random;
			bfm.send_serial_data(bfm.data_A, bfm.data_B, bfm.opcode, 0, bfm.length, bfm.no_ctl); 
		end
		
        	#(1000);      
    	end 
	    $display("----- ALU TEST SUMMARY------");
    	    // test variables
    	    $display("DETECTED UNEXPECTED_ERRORS %d", bfm.UNEXPECTED_ERRORS);
    	    $display("DETECTED EXPECTED_ERRORS %d",bfm.EXPECTED_ERRORS);
	    $display("CORRECT_FLAGS %d",bfm.CORRECT_FLAGS);
    	    $display("WRONG_FLAGS %d",bfm.WRONG_FLAGS);
    	    $display("CORRECT_RESULTS %d",bfm.CORRECT_RESULTS);
    	    $display("WRONG_RESULTS %d", bfm.WRONG_RESULTS);
	    if( bfm.UNEXPECTED_ERRORS == 0 && bfm.WRONG_RESULTS == 0 && bfm.WRONG_FLAGS == 0 ) $display("TESTS PASS");
	    else $display("TESTS FAILED");
	$finish;
	                        
end
endmodule : tester
