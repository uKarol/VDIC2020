class add_tester extends random_tester;
    `uvm_component_utils(add_tester)

    function new(string name, uvm_component parent);
	super.new(name, parent);
    endfunction : new

    function opcode get_op();
	bit [2:0] op_choice;
	return ADD;
    endfunction : get_op

endclass : add_tester
