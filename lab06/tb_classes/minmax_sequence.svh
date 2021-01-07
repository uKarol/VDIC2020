class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

    sequence_item command;

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new
    

    task body();
`uvm_create(command);
        `uvm_info("SEQ_MINMAX", "", UVM_MEDIUM)
    repeat (100) begin : minmax_loop   
    	`uvm_rand_send_with(command, { A dist {32'h0000_0000:=1,32'hFFFF_FFFF:=1}; B dist {32'h0000_0000,32'hFFFF_FFFF};})

   end: minmax_loop
    endtask : body

endclass : minmax_sequence
