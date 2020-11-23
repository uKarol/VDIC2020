virtual class base_tester extends uvm_component;
	
    `uvm_component_utils(base_tester)
    virtual mtm_Alu_bfm bfm;
	
   function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction : new


   function void build_phase(uvm_phase phase);
	if( !uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*", "bfm", bfm) )
	   $fatal(1, "Failed to get BFM" );
   endfunction : build_phase

   // Random data generation functions

   pure virtual function opcode get_op();
   pure virtual function opcode get_valid_op();
   pure virtual function byte get_data();
	
   task run_phase(uvm_phase phase);
      	integer random_ctr;      

    	// test case 1
    	// valid frames 

	phase.raise_objection(this);
    
    	$display("RANDOM TESTS START" );
    	
	// random operation, random data
    	for (random_ctr = 0; random_ctr < 10000; random_ctr = random_ctr + 1) begin
		bfm.expected_err = NO_ERR;
        	bfm.data_A = get_data();
        	bfm.data_B = get_data();
		bfm.opcode = get_op();
		if( bfm.opcode == RST_OP ) bfm.reset_alu();
		if( bfm.opcode == RST_OP || bfm.opcode == RES_OP_2 || bfm.opcode == RES_OP_3 || bfm.opcode == RES_OP_4 ) bfm.expected_err = ERR_OP;
		bfm.send_serial_data(bfm.data_A, bfm.data_B, bfm.opcode, 0, 7, 0); 
        	#(1000);      
    	end 
	bfm.reset_alu();
	// corner case 1

    	for (random_ctr = 0; random_ctr < 100; random_ctr = random_ctr + 1) begin
		bfm.expected_err = NO_ERR;
        	bfm.data_A = 32'h7FFF_FFFF;
        	bfm.data_B = 32'h7FFF_FFFF;
		bfm.opcode = get_valid_op();
		if( bfm.opcode == RST_OP ) bfm.reset_alu();
		else bfm.send_serial_data(bfm.data_A, bfm.data_B, bfm.opcode, 0, 7, 0); 
        	#(1000);      
    	end 
	bfm.reset_alu();

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
	bfm.reset_alu();
	
	// old test backup
    	for (random_ctr = 0; random_ctr < 1000; random_ctr = random_ctr + 1) begin
		bfm.expected_err = ERR_DATA;
        	bfm.data_A = get_data();
        	bfm.data_B = get_data();
		bfm.opcode = get_valid_op();
		if( bfm.opcode == RST_OP ) begin
			bfm.reset_alu();
		end
		else begin
			if ((bfm.length == 4 ) || (bfm.length == 1)) bfm.expected_err = ERR_CRC;
			if( bfm.length == 7 ) bfm.no_ctl = 1;
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

	    phase.drop_objection(this);	

	endtask : run_phase
endclass : base_tester


