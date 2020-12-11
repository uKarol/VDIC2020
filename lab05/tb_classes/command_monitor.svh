class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual mtm_Alu_bfm bfm;

    uvm_analysis_port #(command_transaction) ap;

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        bfm.command_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase

    function void write_to_monitor(bit[31:0] A, bit[31:0] B, bit[2:0] op, bit[2:0] expected_err);
        command_transaction cmd;
        `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %h  B: %h  op: %h ",
                A, B, op), UVM_HIGH);
        cmd    = new("cmd");
        cmd.A  = A;
        cmd.B  = B;
        cmd.op = op;
	cmd.expected_err = expected_err;
        cmd.bad_crc = 0;
    	cmd.length = 7;
    	cmd.no_ctl = 0;
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor
