class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    virtual mtm_Alu_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("RESULT MONITOR", "Failed to get BFM")

        bfm.result_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase

    function void write_to_monitor( bit[31:0] result, bit[3:0] flags, bit[2:0] errors );
        result_transaction result_t;
        result_t        = new("result_t");
        result_t.result = result;
	result_t.flags = flags;
	result_t.errors = errors;

        ap.write(result_t);

    endfunction : write_to_monitor

endclass : result_monitor
