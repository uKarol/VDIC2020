class result_transaction extends uvm_transaction;
    `uvm_object_utils(result_transaction)

   bit[31:0] result;
   bit[3:0] flags;
   bit[3:0] errors;
   	

   function new(string name = "");
      super.new(name);
   endfunction : new

   virtual function void do_copy(uvm_object rhs);
      result_transaction copied_transaction_h;
      assert(rhs != null) else
        $fatal(1,"Tried to copy null transaction");
      super.do_copy(rhs);
      assert($cast(copied_transaction_h,rhs)) else
        $fatal(1,"Faied cast in do_copy");
      result = copied_transaction_h.result;
      flags = copied_transaction_h.flags;
      errors = copied_transaction_h.errors;
   endfunction : do_copy

   virtual function string convert2string();
      string s;
      s = $sformatf("result: %h",result);
      return s;
   endfunction : convert2string

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      result_transaction RHS;
      bit    same;
      assert(rhs != null) else
        $fatal(1,"Tried to copare null transaction");

      same = super.do_compare(rhs, comparer);

      $cast(RHS, rhs);
    	same = (result == RHS.result) && (flags == RHS.flags) && same;
	//if(errors == expected_error )
	same = (errors == RHS.errors);
      return same;
   endfunction : do_compare

endclass : result_transaction
