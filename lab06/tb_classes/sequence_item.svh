/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class sequence_item extends uvm_sequence_item;
//   `uvm_object_utils(sequence_item)

    rand	bit[31:0] A;
    rand	bit[31:0] B;
    rand	bit[2:0] op;
    rand	bit[2:0] expected_err; 
    rand	bit bad_crc;
    rand	bit[2:0] length;
    rand	bit no_ctl;

//    constraint op_con {op dist {RES_OP_2 := 1, ADD := 5, AND:=5,
  //          OR :=5,SUB:=5, RST_OP:=1};}

  //  constraint data { A dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};
   //     B dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};}

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

	// macros providing copy, compare, pack, record, print functions.
	// Individual functions can be enabled/disabled with the last
	// `uvm_field_*() macro argument.
    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_int(op, UVM_ALL_ON)
       // `uvm_field_int(result, UVM_ALL_ON)
    `uvm_object_utils_end
/*
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        sequence_item tested;
        bit same;

        if (rhs==null) `uvm_fatal(get_type_name(),
                "Tried to do comparison to a null pointer");

        if (!$cast(tested,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (tested.A == A) &&
            (tested.B == B) &&
            (tested.op == op) &&
            (tested.result == result);
        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        sequence_item RHS;
        assert(rhs != null) else
            $fatal(1,"Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(RHS,rhs)) else
            $fatal(1,"Faied cast in do_copy");
        A      = RHS.A;
        B      = RHS.B;
        op     = RHS.op;
        result = RHS.result;
    endfunction : do_copy
*/
    function string convert2string();
        string s;
        s = $sformatf("A: %2h  B: %2h   op: %h",
            A, B, op);
        return s;
    endfunction : convert2string

endclass : sequence_item


