class jtag_IdcodeInstr_test extends jtag_base_test;

  `uvm_component_utils(jtag_IdcodeInstr_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  
   jtag_IdcodeInst_seq iseq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "jtag_IdcodeInstr_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    iseq = jtag_IdcodeInst_seq::type_id::create("iseq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    iseq.start(env.j_agnt.seqr);
    #200;
    phase.drop_objection(this);
    
 
  endtask : run_phase
  
endclass : jtag_IdcodeInstr_test