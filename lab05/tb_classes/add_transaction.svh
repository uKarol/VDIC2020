class add_transaction extends command_transaction;
    `uvm_object_utils(add_transaction)

    constraint add_only {op == ADD;}

    function new(string name="");
        super.new(name);
    endfunction

endclass : add_transaction
