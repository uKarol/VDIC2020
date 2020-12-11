class add_test extends random_test;

    `uvm_component_utils(add_test)


    function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction : new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        command_transaction::type_id::set_type_override(add_transaction::get_type());
    endfunction : build_phase


endclass
