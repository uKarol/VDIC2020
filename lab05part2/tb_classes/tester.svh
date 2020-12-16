class tester extends uvm_component;
   `uvm_component_utils (tester)

   uvm_put_port #(command_transaction) command_port;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction  command;

      phase.raise_objection(this);

      command = new("command");
      command.op = RST_OP;
      command_port.put(command);

      repeat (600) begin
         command = command_transaction::type_id::create("command");
         if(! command.randomize())
             `uvm_fatal("TESTER", "Randomization failed");
            
         command_port.put(command);
      end

      command = new("command");
      command.op = RES_OP_2;
      command.A = 32'hFFFF_FFFF;
      command.B = 32'hFFFF_FFFF;
      command_port.put(command);

      command.op = ADD;
      command.A = 32'hFFFF_FFFF;
      command.B = 32'hFFFF_FFFF;
      command_port.put(command);

      command.op = SUB;
      command.A = 32'hFFFF_FFFF;
      command.B = 32'hFFFF_FFFF;
      command_port.put(command);

      command.op = OR;
      command.A = 32'hFFFF_FFFF;
      command.B = 32'hFFFF_FFFF;
      command_port.put(command);

      command.op = AND;
      command.A = 32'hFFFF_FFFF;
      command.B = 32'hFFFF_FFFF;
      command_port.put(command);

      command.op = AND;
      command.A = 32'h0;
      command.B = 32'h0;
      command_port.put(command);

      command.op = ADD;
      command.A = 32'h0;
      command.B = 32'h0;
      command_port.put(command);
 
      command.op = SUB;
      command.A = 32'h0;
      command.B = 32'h0;
      command_port.put(command);
      
      command.op = OR;
      command.A = 32'h0;
      command.B = 32'h0;
      command_port.put(command);

      command.op = OR;
      command.A = 32'h0;
      command.B = 32'h0;
      command_port.put(command);
      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester
