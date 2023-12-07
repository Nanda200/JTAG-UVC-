//comparison for IDCODE inst - compare collected tdo with stores IDCODE reg val 
//for all other instruction tdo and tdo need to be compared
//------------------------------------------------------------------------------------


`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
class jtag_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(jtag_scoreboard)
  
  uvm_analysis_imp_in#(jtag_seq_item, jtag_scoreboard) in_item_collected_export;
  uvm_analysis_imp_out#(jtag_seq_item, jtag_scoreboard) out_item_collected_export;
  
  uvm_analysis_port#(jtag_seq_item) cov_port;
  
  jtag_seq_item exp_item;
  jtag_seq_item act_item;

  
  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_item_collected_export = new("in_item_collected_export", this);
    out_item_collected_export = new("out_item_collected_export", this);
    cov_port = new("cov_port",this);
  endfunction: build_phase
  
   // write
  virtual function void write_in(jtag_seq_item in_item);
   
    `uvm_info(get_type_name()," EXP ITEM RECEIVED FROM MONITOR",UVM_LOW)
     $cast(exp_item,in_item.clone());
    //comparison logic       
    
     if(!exp_item.compare(act_item))
      `uvm_error(get_type_name(),"ERROR:MISMATCH IN TDI &TDO")
     else
      `uvm_info(get_type_name(),"ITEM MATCH FOUND",UVM_LOW)
    
  endfunction : write_in
      
  virtual function void write_out(jtag_seq_item out_item);
    `uvm_info(get_type_name(),"ACT ITEM RECEIVED FROM MONITOR",UVM_LOW)
    $cast(act_item,out_item.clone());

  endfunction : write_out

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    phase.drop_objection(this);
    
  endtask
  
endclass : jtag_scoreboard
