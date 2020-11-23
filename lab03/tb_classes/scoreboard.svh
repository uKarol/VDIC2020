
class scoreboard extends uvm_component;
   `uvm_component_utils(scoreboard)
   virtual mtm_Alu_bfm bfm;
   	
   function new (string name, uvm_component parent);
	super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
	if( !uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*", "bfm", bfm) )
	   $fatal(1, "Failed to get BFM" );
   endfunction : build_phase

   task run_phase( uvm_phase phase );
        forever begin : self_checker
	    bfm.serial_out();
	    if( bfm.expected_err == NO_ERR ) compare( bfm.opcode, bfm.data_A, bfm.data_B, bfm.result, bfm.flags);
	    else 	                     compare_error(bfm.errors, bfm.expected_err);
   	end : self_checker
    endtask : run_phase 

    protected task compare;
        input [2:0] OPERATION;
        input [31:0]A;
        input [31:0]B;
        input [31:0]RESULT;
        input [3:0] FLAGS;
        logic [31:0] expected_result;

        logic carry;
        begin
            expected_result = 0;
            bfm.expected_flags = 0;
            case(OPERATION)
                AND:
                begin
                    expected_result = A&B; 
		    if(expected_result == 0) bfm.expected_flags[1] = 1'b1; 	// zero
		    if(expected_result[31] == 1) bfm.expected_flags[0] = 1'b1;  // negative
                end 
                OR:
                begin
                    expected_result = A|B;
		    if(expected_result == 0) bfm.expected_flags[1] = 1; 	// zero				
		    if(expected_result[31] == 1) bfm.expected_flags[0] = 1; 	// negative
                end
                ADD:
                begin 
                    {carry, expected_result} = A+B;				
		    if(expected_result == 0) bfm.expected_flags[1] = 1; 	// zero
		    if(expected_result[31] == 1) bfm.expected_flags[0] = 1; 	// negative 				
		    if(carry == 1) bfm.expected_flags[3] = 1; 			// carry
		    if( ~( A[31]^B[31]^OPERATION[0] ) & (A[31] ^ expected_result[31]) ) bfm.expected_flags[2] = 1; //overflow
                end
                SUB:
                begin
                   {carry, expected_result} = A-B;
		   if(expected_result == 0) bfm.expected_flags[1] = 1; 	// zero 
	 	   if(expected_result[31] == 1) bfm.expected_flags[0] = 1; 	// negative
		   if(carry == 1) bfm.expected_flags[3] = 1; 			// carry
		   if( ~( A[31]^B[31]^OPERATION[0] ) & (A[31] ^ expected_result[31]) ) bfm.expected_flags[2] = 1; //overflow				
                end
	        default:
	        begin
		    $display( "TEST FAILED< WRONG OPERATION" );
	        end
            endcase 
           
	    if( RESULT == expected_result)begin
                bfm.CORRECT_RESULTS++;
            end
            else 
            begin
               $display("FAILED RESULT, EXPECTED %b ACTUAL, %b", expected_result , RESULT);
               bfm.WRONG_RESULTS++;
            end
			   
            if( FLAGS == bfm.expected_flags)begin
               bfm.CORRECT_FLAGS++;
            end
            else 
            begin
               $display("FAILED FLAGS, EXPECTED %b ACTUAL, %b", bfm.expected_flags, FLAGS);
               bfm.CORRECT_FLAGS++;
           end
      end   
  endtask
  
    protected task compare_error;
        input [2:0]ERRORS;
        input [2:0]EXPECTED_ERROR;
        begin
            if(ERRORS == 0)begin
                $display("TEST_FAILED NO ERRORS - ERROR EXPECTED");
            end
            else
            begin
                if(EXPECTED_ERROR == ERRORS) begin
                    bfm.EXPECTED_ERRORS++;                
                end
                else 
                begin
                    $display("FAIL - UNEXPECTED_ERROR_DETECTED %d", ERRORS); 
                    bfm.UNEXPECTED_ERRORS++;
                end 
        
            end 
      end
  endtask

endclass : scoreboard
