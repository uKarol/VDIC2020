/*
virtual class base_tester extends uvm_component;
	
    `uvm_component_utils(base_tester)
    virtual mtm_Alu_bfm bfm;
	
   function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction : new

    uvm_put_port #(command_s) command_port;

   function void build_phase(uvm_phase phase);
	command_port = new("command_port", this);
   endfunction : build_phase

   // Random data generation functions

   pure virtual function opcode get_op();
   pure virtual function opcode get_valid_op();
   pure virtual function byte get_data();
	
   task run_phase(uvm_phase phase);
      	integer random_ctr;      
	
	command_s command;	

    	// test case 1
    	// valid frames 

	phase.raise_objection(this);
    
    	$display("RANDOM TESTS START" );
    	
	// random operation, random data
    	for (random_ctr = 0; random_ctr < 1000; random_ctr = random_ctr + 1) begin
		command.expected_err = NO_ERR;
        	command.A = get_data();
        	command.B = get_data();
		command.op = get_op();
		command.bad_crc = 0;
		command.length = 7;
		command.no_ctl = 0;
		if( command.op == RES_OP_2 || command.op == RES_OP_3 || command.op == RES_OP_4 ) command.expected_err = ERR_OP;
		command_port.put(command);
        	#(1000);      
    	end 

	// corner case 1

    	for (random_ctr = 0; random_ctr < 100; random_ctr = random_ctr + 1) begin
		command.expected_err = NO_ERR;
        	command.A  = 32'h7FFF_FFFF;
        	command.B  = 32'h7FFF_FFFF;
		command.op  = get_valid_op();
		command.bad_crc = 0;
		command.length = 7;
		command.no_ctl = 0;
		command_port.put(command);
        	#(1000);      
    	end 

	// random tests with wrong CRC
    	for (random_ctr = 0; random_ctr < 1000; random_ctr = random_ctr + 1) begin
		command.expected_err = ERR_CRC;
        	command.A = get_data();
        	command.B = get_data();
		command.op = get_valid_op();
		command.bad_crc = 1;
		command.length = 7;
		command.no_ctl = 0;
		command_port.put(command);
        	#(1000);      
    	end 
	
	// old test backup
    	for (random_ctr = 0; random_ctr < 1000; random_ctr = random_ctr + 1) begin
		command.expected_err = ERR_DATA;
        	command.A = get_data();
        	command.B = get_data();
		command.op = get_valid_op();
		command.bad_crc = 1;
		command.length = 7;

		if ((command.length == 4 ) || (command.length == 1)) command.expected_err = ERR_CRC;
		if( command.length == 7 ) command.no_ctl = 1;
		else command.no_ctl = $random;
		command_port.put(command);

		
        	#(1000);      
    	end 

	    $display("----- ALL TESTS PASS------");

	    $finish;

	    phase.drop_objection(this);	

	endtask : run_phase
endclass : base_tester
*/

