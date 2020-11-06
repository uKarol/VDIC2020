
package mtm_Alu_pkg;

	typedef enum { TEST_IDLE, TEST_PROCESSING, TEST_FIRST_BIT, TEST_ERROR, TEST_FINISH, ALL_TESTS_FINISHED }   test_states; 
	typedef enum { NO_ERR = 3'b000, ERR_DATA = 3'b100, ERR_CRC = 3'b010, ERR_OP = 3'b001 } err_code;
	typedef enum { AND = 3'b000, OR = 3'b001, ADD = 3'b100, SUB = 3'b101, RST_OP = 3'b010, RES_OP_2 = 3'b011, RES_OP_3 = 3'b110, RES_OP_4 = 3'b111 }  	       opcode;
	typedef enum { bDATA = 1'b0, bCMD = 1'b1 }					       byte_type;

endpackage: mtm_Alu_pkg
