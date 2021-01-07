class scoreboard extends uvm_subscriber #( result_transaction );
   `uvm_component_utils(scoreboard)
   
   uvm_tlm_analysis_fifo #(sequence_item) cmd_f;
   
   function new (string name, uvm_component parent);
	super.new(name, parent);
   endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase




    function result_transaction predict_result(sequence_item cmd);
        result_transaction predicted;
	bit carry;
        predicted = new("predicted");

	    if( ( cmd.op ==  RES_OP_2 )|| ( cmd.op ==  RES_OP_3 ) || ( cmd.op ==  RES_OP_4 )) predicted.errors = ERR_OP;	

            case(cmd.op)
                AND:
                begin
                    predicted.result = cmd.A&cmd.B; 
		    if(predicted.result == 0)     predicted.flags[1] = 1'b1; 	// zero
		    if(predicted.result[31] == 1) predicted.flags[0] = 1'b1;  // negative
                end 
                OR:
                begin
                    predicted.result = cmd.A|cmd.B;
		    if(predicted.result == 0) predicted.flags[1] = 1; 	// zero				
		    if(predicted.result[31] == 1) predicted.flags[0] = 1; 	// negative
                end
                ADD:
                begin 
                    {carry, predicted.result} = cmd.A+cmd.B;				
		    if(predicted.result == 0) predicted.flags[1] = 1; 	// zero
		    if(predicted.result[31] == 1) predicted.flags[0] = 1; 	// negative 				
		    if(carry == 1) predicted.flags[3] = 1; 			// carry
		    if( ~( cmd.A[31]^cmd.B[31]^cmd.op[0] ) & (cmd.A[31] ^ predicted.result[31]) ) predicted.flags[2] = 1; //overflow
                end
                SUB:
                begin
                   {carry, predicted.result} = cmd.A-cmd.B;
		   if(predicted.result == 0) predicted.flags[1] = 1; 	// zero 
	 	   if(predicted.result[31] == 1) predicted.flags[0] = 1; 	// negative
		   if(carry == 1) predicted.flags[3] = 1; 			// carry
		   if( ~( cmd.A[31]^cmd.B[31]^cmd.op[0] ) & (cmd.A[31] ^ predicted.result[31]) ) predicted.flags[2] = 1; //overflow				
                end
	        default:
		begin
		end

            endcase 

        return predicted;

    endfunction : predict_result

    function void write(result_transaction t);
        string data_str;
        sequence_item cmd;
        result_transaction predicted;

        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.op == RST_OP);

        predicted = predict_result(cmd);

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};


        if (!predicted.compare(t))
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

endclass : scoreboard
