class jtag_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  jtag_agent      j_agnt;
//  jtag_scoreboard j_scb;
  
  `uvm_component_utils(jtag_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    j_agnt = jtag_agent::type_id::create("j_agnt", this);
   // j_scb = jtag_scoreboard::type_id::create("j_scb", this);
    
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    //j_agnt.mon.item_collected_port.connect(j_scb.item_collected_export);
  endfunction : connect_phase

endclass : jtag_env