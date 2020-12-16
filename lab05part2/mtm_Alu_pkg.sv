
package mtm_Alu_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"

    typedef enum { TEST_IDLE, TEST_PROCESSING, TEST_FIRST_BIT, TEST_ERROR, TEST_FINISH, ALL_TESTS_FINISHED }   test_states; 
    typedef enum bit[2:0] { NO_ERR = 3'b000, ERR_DATA = 3'b100, ERR_CRC = 3'b010, ERR_OP = 3'b001 } err_code;
    typedef enum bit[2:0] { AND = 3'b000, OR = 3'b001, ADD = 3'b100, SUB = 3'b101, RST_OP = 3'b010, RES_OP_2 = 3'b011, RES_OP_3 = 3'b110, RES_OP_4 = 3'b111 }  	       opcode;
    typedef enum bit { bDATA = 1'b0, bCMD = 1'b1 }					       byte_type;

	typedef struct packed{
		bit[31:0] A;
		bit[31:0] B;
		bit[2:0] op;
		bit[2:0] expected_err; 
     		bit bad_crc;
     		bit[2:0] length;
     		bit no_ctl;
	} command_s;

	typedef struct packed{
		bit[31:0] result;
		bit[3:0] flags;
		bit[2:0] errors;
	} result_s;

	`include "env_config.svh"
	`include "mtm_alu_agent_config.svh"

	`include "command_transaction.svh"
	`include "add_transaction.svh"
	//`include "minmax_transaction.svh"

	`include "result_transaction.svh"

	`include "coverage.svh"
	`include "tester.svh"
	`include "scoreboard.svh"
	`include "driver.svh"
	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "mtm_alu_agent.svh"
	`include "env.svh"

	`include "dual_test.svh"
	//`include "random_test.svh"
	//`include "add_test.svh"
	//`include "minmax_test.svh"
	

endpackage: mtm_Alu_pkg
