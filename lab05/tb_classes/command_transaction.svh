class command_transaction extends uvm_transaction;
   `uvm_object_utils(command_transaction)

    rand	bit[31:0] A;
    rand	bit[31:0] B;
    rand	bit[2:0] op;
    rand	bit[2:0] expected_err; 
    rand	bit bad_crc;
    rand	bit[2:0] length;
    rand	bit no_ctl;

  // constraint data { A dist {32'h00:=1, [32'h01 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};
  //                   B dist {32'h00:=1, [32'h01 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};} 
   
  // constraint valid_only {op == ADD; op == OR; op == AND; op == OR; op == RST_OP;}

   virtual function void do_copy(uvm_object rhs);
      command_transaction copied_transaction_h;

      if(rhs == null) 
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")
      
      super.do_copy(rhs); // copy all parent class data

      if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

      A = copied_transaction_h.A;
      B = copied_transaction_h.B;
      op = copied_transaction_h.op;
      expected_err = copied_transaction_h.expected_err;

   endfunction : do_copy

   virtual function command_transaction clone_me();
      command_transaction clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      command_transaction compared_transaction_h;
      bit   same;
      
      if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(compared_transaction_h,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (compared_transaction_h.A == A) &&
               (compared_transaction_h.B == B) &&
               (compared_transaction_h.op == op)&&
	       (compared_transaction_h.expected_err == expected_err);
               
      return same;
   endfunction : do_compare


   virtual function string convert2string();
      string s;
      s = $sformatf("A: %h  B: %h op: %h",
                        A, B, op);
      return s;
   endfunction : convert2string

   function new (string name = "");
      super.new(name);
   endfunction : new

endclass : command_transaction
