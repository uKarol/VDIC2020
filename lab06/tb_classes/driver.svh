class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)

    virtual mtm_Alu_bfm bfm;


    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        sequence_item cmd;
        void'(begin_tr(cmd));

        forever begin : command_loop
	    #1000;
            seq_item_port.get_next_item(cmd);

	    bfm.send_serial_data(cmd.A, 
				 cmd.B, 
				 cmd.op, 
				 0,
				 7,
				 0,
				 cmd.expected_err);
            seq_item_port.item_done();
        end : command_loop

	end_tr(cmd);

    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver
