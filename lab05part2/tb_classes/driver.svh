class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual mtm_Alu_bfm bfm;
    uvm_get_port #(command_transaction) command_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

   function void build_phase(uvm_phase phase);
   
      mtm_alu_agent_config mtm_alu_agent_config_h;
	  
      if(!uvm_config_db #(mtm_alu_agent_config)::get(this, "","config", mtm_alu_agent_config_h))
        `uvm_fatal("DRIVER", "Failed to get config");
		
      bfm = mtm_alu_agent_config_h.bfm;
	  
      command_port = new("command_port",this);
	  
   endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_transaction command;

        forever begin : command_loop
	    #1000;
            command_port.get(command);
	
	    bfm.send_serial_data(command.A, 
				 command.B, 
				 command.op, 
				 0,
				 7,
				 0,
				 command.expected_err);

        end : command_loop
    endtask : run_phase



endclass : driver
