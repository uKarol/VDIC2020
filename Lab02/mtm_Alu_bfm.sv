interface mtm_Alu_bfm;
import mtm_Alu_pkg::*;

// from tester
bit[31:0] data_A;
bit[31:0] data_B;
bit[2:0] opcode;
bit bad_crc;
bit[2:0] length;
bit no_ctl;
err_code expected_err; 

//connections to mtm_ALU DUT
bit clk;
bit rst_n;
bit sin;
wire sout;

// to scoreboard
bit [31:0] result; 
bit [3:0] flags;
bit test_done;
logic   [2:0]errors;
bit [3:0] expected_flags;

integer RUN_TESTS = 0;	
integer UNEXPECTED_ERRORS = 0;
integer EXPECTED_ERRORS = 0;
integer CORRECT_FLAGS = 0;
integer WRONG_FLAGS = 0;
integer CORRECT_RESULTS = 0;
integer WRONG_RESULTS = 0;

//internal variables
integer bit_ctr;
test_states test_state;
logic   [54:0]serializer_out;

initial begin
    clk = 0;
    forever begin
        #5;
        clk = ~clk;
    end
end



    always @(posedge clk)
    begin


    
        case(test_state)
        TEST_IDLE:
        begin
	    test_done = 0;
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
            serializer_out[53] = sout;
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
	    result = {serializer_out[52: 45], serializer_out[41: 34], serializer_out[30: 23], serializer_out[19: 12]};
	    flags = serializer_out[7:4];
	    test_done = 1;
 	    test_state = TEST_IDLE;
	end

        endcase
        
    end

task reset_alu();
    rst_n = 1'b0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_alu

  // tasks definistion
  
  task send_byte;  
      input [7:0] s_byte;
      input cmd;
      integer bit_ctr;
      begin
        sin = 1'b0; // start_bit
	@( negedge clk );  
        if( cmd == 1 ) sin = 1'b1; // packet type bit
        else sin = 1'b0;// data or cmd 
	@( negedge clk );
        for( bit_ctr = 7 ; bit_ctr>=0  ; bit_ctr-- ) begin
            sin = s_byte[bit_ctr];
	    @( negedge clk );	                          
        end  
        sin = 1'b1;         
      end
  endtask 
  
  task send_calculation_data;
      integer lctr;
      input[71:0] data;
      input[2:0] length;
      input no_ctl;
      bit [7:0] packages[8: 0] ;
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

          for( lctr = 0 ; lctr <= length; lctr++) begin
	    @( negedge clk ); 
            send_byte(packages[lctr],bDATA);  
          end     
	    @( negedge clk ); 
            if(no_ctl == 1'b1) send_byte(data[7:0],bDATA); 
	    else send_byte(data[7:0],bCMD);  
      
      end
  endtask

   task send_serial_data;
     input[31:0] data_A;
     input[31:0] data_B;
     input[2:0] opcode;
     input bad_crc;
     input[2:0] length;
     input no_ctl;
     begin
	bit [7:0] ctl;
	ctl[7] = 1'b1;
    	ctl[6:4] = opcode;
	if( bad_crc == 1'b1) ctl[3:0] = nextCRC4_D68({data_A, data_B,1'b0, opcode}, 4'b0000);
    	else 		     ctl[3:0] = nextCRC4_D68({data_A, data_B,1'b1, opcode}, 4'b0000);
        send_calculation_data( {data_A, data_B, ctl}, length, no_ctl );    
     end
  endtask;


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


endinterface : mtm_Alu_bfm
