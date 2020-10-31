module top;

logic clk;
logic rst_n;
logic sin;  
wire sout;	

mtm_Alu DUT (.clk(clk), .rst_n(rst_n), .sin(sin), .sout(sout) );

// constants
localparam 
    RANDOM_TESTS_NUMBER = 5000,
    WRONG_TESTS_NUMBER = 500,
    WRONG_TESTS_NUMBER_2 = 500,
    CLK_PERIOD = 10,
    OVERSAMPLING_SAMPLES = 1,
    BIT_SAMPLING_CYCLES = CLK_PERIOD*OVERSAMPLING_SAMPLES,        
    FRAME_SIZE = 10,
    BYTE_SIZE = 7,
    FRAME_NUMBER = 8,
    DATA_SIZE = 31,
    TESTS_NUMBER = RANDOM_TESTS_NUMBER+WRONG_TESTS_NUMBER+WRONG_TESTS_NUMBER_2;

typedef enum { TEST_IDLE, TEST_PROCESSING, TEST_FIRST_BIT, TEST_ERROR, TEST_FINISH, ALL_TESTS_FINISHED }   test_states; 
typedef enum { NO_ERR = 3'b000, ERR_DATA = 3'b100, ERR_CRC = 3'b010, ERR_OP = 3'b001 } err_code;
typedef enum { AND = 3'b000, OR = 3'b001, ADD = 3'b100, SUB = 3'b101, RST_OP = 3'b010, RES_OP_2 = 3'b011, RES_OP_3 = 3'b110, RES_OP_4 = 3'b111 }  	       opcode;
typedef enum { bDATA = 1'b0, bCMD = 1'b1 }					       byte_type;


// serial frame format: [ 0, packet type, packet pits, stop ] 

bit [DATA_SIZE:0] data_A;
bit [DATA_SIZE:0] data_B;
opcode current_op;
err_code expected_err; 
test_states test_state; 
logic   [54:0]serializer_out;
integer bit_ctr;
integer tests_ctr;
logic   [2:0]errors;
logic [3:0] expected_flags;
// initialize 
initial 
begin 
     errors = 0; 
     serializer_out = 0;
     test_state = TEST_IDLE;
     bit_ctr = 0;
     clk = 1;
     tests_ctr = 0;
end 
   
   // clock generation  
always 
    #(CLK_PERIOD/2)  clk =  ! clk;     

// test variables


integer RUN_TESTS = 0;
integer UNEXPECTED_ERRORS = 0;
integer EXPECTED_ERRORS = 0;
integer CORRECT_FLAGS = 0;
integer WRONG_FLAGS = 0;
integer CORRECT_RESULTS = 0;
integer WRONG_RESULTS = 0;

// SCOREBOARD 

    always @(posedge clk)
    begin


    
        case(test_state)
        TEST_IDLE:
        begin
            if( sout == 0) begin
               test_state = TEST_FIRST_BIT;
               serializer_out[54] = sout;
            end
            else test_state = TEST_IDLE;
            bit_ctr = 0;
	    errors = 0;
            
        end
        TEST_FIRST_BIT:
        begin 
            bit_ctr = 0;
	    tests_ctr++;
            serializer_out[53] = sout;;
            if( sout == 0 ) test_state = TEST_PROCESSING;
            else test_state = TEST_ERROR;      
            
        end
        TEST_ERROR:
        begin
            serializer_out[52-bit_ctr] = sout;           
            bit_ctr++;
            if(bit_ctr < 10)begin
               test_state = TEST_ERROR;
            end 
            else begin
               test_state = TEST_FINISH;
               errors = serializer_out[51:49];
            end
            
        end
        
        TEST_PROCESSING:
        begin
            serializer_out[52-bit_ctr] = sout;  	      
            bit_ctr++;
            if(bit_ctr < 53) test_state = TEST_PROCESSING;
            else test_state = TEST_FINISH;
        end

	TEST_FINISH:
	begin    
	     if( errors == 0 ) compare( current_op, data_A, data_B, {serializer_out[52: 45], serializer_out[41: 34], serializer_out[30: 23], serializer_out[19: 12]}, serializer_out[7:4]);
	     else 	       compare_error(errors, expected_err);
	     if( tests_ctr == TESTS_NUMBER) test_state = ALL_TESTS_FINISHED;
	     else   			    test_state = TEST_IDLE;
	end

	ALL_TESTS_FINISHED:
	begin
	    $display("----- ALU TEST SUMMARY------");
    	    // test variables
	    $display("NUMBER OF TESTS RUN %d", TESTS_NUMBER);
    	    $display("DETECTED UNEXPECTED_ERRORS %d", UNEXPECTED_ERRORS);
    	    $display("DETECTED EXPECTED_ERRORS %d",EXPECTED_ERRORS);
	    $display("CORRECT_FLAGS %d",CORRECT_FLAGS);
    	    $display("WRONG_FLAGS %d",WRONG_FLAGS);
    	    $display("CORRECT_RESULTS %d",CORRECT_RESULTS);
    	    $display("WRONG_RESULTS %d", WRONG_RESULTS);
	    if( UNEXPECTED_ERRORS == 0 && WRONG_RESULTS == 0 && WRONG_FLAGS == 0 ) $display("TESTS PASS");
	    else $display("TESTS FAILED");		
	    $finish;
	end

        endcase
        
    end
//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

   covergroup op_cov;

      option.name = "cg_op_cov";

      coverpoint current_op {
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

      all_ops : coverpoint current_op {
         ignore_bins null_ops = {RST_OP, RES_OP_2, RES_OP_3, RES_OP_4};
      }

      a_leg: coverpoint data_A {
         bins zeros = {'h00_00_00_00};
         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
         bins ones  = {'hFF_FF_FF_FF};
      }

      b_leg: coverpoint data_B {
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

 
 covergroup flags_cov;
      option.name = "mtm alu flags cov";
      
      flags : coverpoint expected_flags {
	    wildcard bins carry = {4'b1xxx};
	    wildcard bins overflow = {4'bx1xx};
	    wildcard bins zero = {4'bxx1x};
	    wildcard bins negative = {4'bxxx1};
	    bins no_flag = {4'b0000};
	
	      
      }

   endgroup


covergroup err_flags_cov;
      option.name = "mtm alu error flags cov";
      
      flags : coverpoint expected_err {
	    wildcard bins err_data = {ERR_DATA};
	    wildcard bins err_crc = {ERR_CRC};
	    wildcard bins err_op = {ERR_OP};
	    bins no_err = {NO_ERR};    
      }
endgroup


   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;
   err_flags_cov err_flags;
   flags_cov normal_flags;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
      err_flags = new();
      normal_flags = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
	 err_flags.sample();
	 normal_flags.sample();
      end
   end : coverage




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
	bit [2:0] length;
	bit bad_ctl;
  
      	sin = 1;
      	rst_n = 0;
      	@(negedge clk);
      	@(negedge clk);
      	rst_n = 1;
    	// test case 1
    	// valid frames 
    
    	$display("RANDOM TESTS START" );
    	
	// random operation, random data
    	for (random_ctr = 0; random_ctr < RANDOM_TESTS_NUMBER; random_ctr = random_ctr + 1) begin
        	data_A = get_data();
        	data_B = get_data();
		current_op = get_op();
		if( current_op == RST_OP ) begin
		      	rst_n = 0;
      			@(negedge clk);
      			@(negedge clk);
      			rst_n = 1;
		end
		if(  current_op == RES_OP_2 || current_op == RES_OP_3 || current_op == RES_OP_4 ) expected_err = ERR_OP;
		send_serial_data(data_A, data_B, current_op, 0); 
        	#(100*CLK_PERIOD);      
    	end 
	
	
	// random tests with wrong CRC
    	for (random_ctr = 0; random_ctr < WRONG_TESTS_NUMBER; random_ctr = random_ctr + 1) begin
		expected_err = ERR_CRC;
        	data_A = get_data();
        	data_B = get_data();
		current_op = get_valid_op();
		if( current_op == RST_OP ) begin
			expected_err = ERR_OP;
		      	rst_n = 0;
      			@(negedge clk);
      			@(negedge clk);
      			rst_n = 1;
			send_serial_data(data_A, data_B, current_op, 0);
		end
		else send_serial_data(data_A, data_B, current_op, 1); 
        	#(100*CLK_PERIOD);      
    	end 
	
	expected_err = ERR_DATA;
	// random tests without CTL and incomplete frames
    	for (random_ctr = 0; random_ctr < WRONG_TESTS_NUMBER_2; random_ctr = random_ctr + 1) begin
        	data_A = get_data();
        	data_B = get_data();
		current_op = get_valid_op();
		if( current_op == RST_OP ) begin
		      	rst_n = 0;
      			@(negedge clk);
      			@(negedge clk);
      			rst_n = 1;
			bad_ctl = 1;
		end
		else begin
			length = $random;
			if( length == 7 ) bad_ctl = 1;
			else bad_ctl = $random;
		end
		send_wrong_data(data_A, data_B, current_op, 0, length, bad_ctl); 
        	#(100*CLK_PERIOD);      
    	end 
	
	//random tests with invalid frames
	
	
	// corner cases                             
end
  
  // tasks definistion
  
  task send_byte;  
      input [7:0] s_byte;
      input cmd;
      integer bit_ctr;
      begin
        sin = 1'b0; // start_bit
        #BIT_SAMPLING_CYCLES;         
        if( cmd == 1 ) sin = 1'b1; // packet type bit
        else sin = 1'b0;
        #BIT_SAMPLING_CYCLES; // data or cmd 
        for( bit_ctr = BYTE_SIZE ; bit_ctr>=0  ; bit_ctr-- ) begin
            sin = s_byte[bit_ctr];
            #BIT_SAMPLING_CYCLES;                               
        end  
        sin = 1'b1;         
      end
  endtask 
  
  // task send_calculation_data 
  
  task send_calculation_data;
      integer lctr;
      input[71:0] data;
      bit [BYTE_SIZE:0] packages[FRAME_NUMBER : 0] ;
      begin
          
          packages[0]= data[71:64];
          packages[1] =data[63:56];
          packages[2] =data[55:48];
          packages[3] =data[47:40];
          packages[4] =data[39:32];
          packages[5] =data[31:24];
          packages[6] =data[23:16];
          packages[7] =data[15:8];
          packages[8] =data[7:0];

          for( lctr = 0 ; lctr <= 7; lctr++) begin
            #CLK_PERIOD;
            send_byte(packages[lctr],bDATA);  
          end     
            #CLK_PERIOD;
            send_byte(data[7:0],bCMD);  
      
      end
  endtask

  task send_serial_data;
     input[DATA_SIZE:0] data_A;
     input[DATA_SIZE:0] data_B;
     input[2:0] opcode;
     input bad_crc;
     begin
	bit [BYTE_SIZE:0] ctl;
	ctl[7] = 1'b1;
    	ctl[6:4] = opcode;
	if( bad_crc == 1'b1) ctl[3:0] = 3'b111;
    	else ctl[3:0] = nextCRC4_D68({data_A, data_B,1'b1, opcode}, 4'b0000);
        send_calculation_data( {data_A, data_B, ctl} ); 
     
     end
  endtask;	

  task send_wrong_calculation_data;
      integer lctr;
      input[71:0] data;
      input[3:0] length;
      input no_ctl;
      bit [BYTE_SIZE:0] packages[FRAME_NUMBER : 0] ;
      begin
          
          packages[0]= data[71:64];
          packages[1] =data[63:56];
          packages[2] =data[55:48];
          packages[3] =data[47:40];
          packages[4] =data[39:32];
          packages[5] =data[31:24];
          packages[6] =data[23:16];
          packages[7] =data[15:8];
          packages[8] =data[7:0];

          for( lctr = 0 ; lctr <= 7; lctr++) begin
            #CLK_PERIOD;
            send_byte(packages[lctr],bDATA);  
          end     
            #CLK_PERIOD;
            if(no_ctl == 1'b1) send_byte(data[7:0],bDATA); 
	    else send_byte(data[7:0],bCMD);  
      
      end
  endtask

   task send_wrong_data;
     input[DATA_SIZE:0] data_A;
     input[DATA_SIZE:0] data_B;
     input[2:0] opcode;
     input bad_crc;
     input[3:0] length;
     input no_ctl;
     begin
	bit [BYTE_SIZE:0] ctl;
	ctl[7] = 1'b1;
    	ctl[6:4] = opcode;
	if( bad_crc == 1'b1) ctl[3:0] = 3'b111;
    	else ctl[3:0] = nextCRC4_D68({data_A, data_B,1'b1, opcode}, 4'b0000);
        send_wrong_calculation_data( {data_A, data_B, ctl}, length, no_ctl ); 
     
     end
  endtask;
  
  task compare;
    input [2:0] OPERATION;
    input [31:0]A;
    input [31:0]B;
    input [31:0]RESULT;
    input [3:0] FLAGS;
    logic [31:0] expected_result;
    //logic [3:0] expected_flags;
    logic carry;
    begin
        expected_result = 0;
        expected_flags = 0;
        case(OPERATION)
            AND:
            begin
                expected_result = A&B; 
		if(expected_result == 0) expected_flags[1] = 1'b1; 	// zero
		if(expected_result[31] == 1) expected_flags[0] = 1'b1;  // negative
            end 
            OR:
            begin
                expected_result = A|B;
		if(expected_result == 0) expected_flags[1] = 1; 	// zero				
		if(expected_result[31] == 1) expected_flags[0] = 1; 	// negative
            end
            ADD:
            begin 
                {carry, expected_result} = A+B;				
		if(expected_result == 0) expected_flags[1] = 1; 	// zero
		if(expected_result[31] == 1) expected_flags[0] = 1; 	// negative 				
		if(carry == 1) expected_flags[3] = 1; 			// carry
		if( ~( A[31]^B[31]^OPERATION[0] ) & (A[31] ^ expected_result[31]) ) expected_flags[2] = 1; //overflow
            end
            SUB:
            begin
                {carry, expected_result} = A-B;
		if(expected_result == 0) expected_flags[1] = 1; 	// zero 
		if(expected_result[31] == 1) expected_flags[0] = 1; 	// negative
		if(carry == 1) expected_flags[3] = 1; 			// carry
		if( ~( A[31]^B[31]^OPERATION[0] ) & (A[31] ^ expected_result[31]) ) expected_flags[2] = 1; //overflow				
            end
	    default:
	    begin
		$display( "TEST FAILED< WRONG OPERATION" );
	    end
            endcase 
           
	if( RESULT == expected_result)begin
           CORRECT_RESULTS = CORRECT_RESULTS+1;
        end
        else 
        begin
           $display("FAILED RESULT, EXPECTED %b ACTUAL, %b", expected_result , RESULT);
           WRONG_RESULTS = WRONG_RESULTS+1;
        end
			   
        if( FLAGS == expected_flags)begin
           CORRECT_FLAGS = CORRECT_FLAGS+1;
        end
        else 
        begin
           $display("FAILED FLAGS, EXPECTED %b ACTUAL, %b", expected_flags, FLAGS);
           CORRECT_FLAGS = WRONG_FLAGS+1;
        end
  end   
  endtask
  
  task compare_error;
    input [2:0]ERRORS;
    input [2:0]EXPECTED_ERROR;
  begin
        if(ERRORS == 0)begin
            $display("TEST_FAILED NO ERRORS - ERROR EXPECTED");
        end
        else
        begin
            if(EXPECTED_ERROR == ERRORS) begin
                EXPECTED_ERRORS = EXPECTED_ERRORS+1;                
            end
            else 
            begin
                $display("FAIL - UNEXPECTED_ERROR_DETECTED %d", ERRORS); 
                UNEXPECTED_ERRORS = UNEXPECTED_ERRORS+1;
            end 
        
        end 
      //  rst_n = 0;
      //  #CLK_PERIOD;
      //  rst_n = 1;
  end
  endtask
 
 
   function [3:0] nextCRC4_D68;
     // polynomial: x^4 + x^1 + 1
     // data width: 68
     // convention: the first serial bit is D[67]
     
       input [67:0] Data;
       input [3:0] crc;
       reg [67:0] d;
       reg [3:0] c;
       reg [3:0] newcrc;
     begin
       d = Data;
       c = crc;
     
       newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
       newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
       newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
       newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
       nextCRC4_D68 = newcrc;
     end
     endfunction


endmodule
