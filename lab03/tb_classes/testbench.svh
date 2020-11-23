class testbench;
    
    virtual mtm_Alu_bfm bfm;

    function new (virtual mtm_Alu_bfm b);
	bfm = b;
    endfunction : new

    tester tester_h;
    scoreboard scoreboard_h;
    coverage coverage_h;

    task execute();

	tester_h = new(bfm);
	coverage_h = new(bfm);
	scoreboard_h = new(bfm);

	fork
	    tester_h.execute();
	    scoreboard_h.execute();
	    coverage_h.execute();
	join

    endtask : execute

endclass : testbench
