//****************************************************************************
class jtag_base_seq extends uvm_sequence#(jtag_seq_item);
  
  `uvm_object_utils(jtag_base_seq)
  
  
  //Constructor
  function new(string name = "jtag_base_seq");
    super.new(name);
  endfunction
  
  
endclass :jtag_base_seq

//********************************************************************************
//sequence to verify idcode instruction
//********************************************************************************
class jtag_IdcodeInst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_IdcodeInst_seq)
  
  jtag_seq_item seq;
  
  bit m_tms[] = `TMS_IDCODE;
  
  //Constructor
  function new(string name = "jtag_IdcodeInst_seq");
    super.new(name);
  endfunction
  
   
  virtual task body();
    `uvm_do_with(seq,{seq.inst == IDCODE;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];
                     
                     })
  endtask
  
endclass:jtag_IdcodeInst_seq

//********************************************************************************
//sequence to veriy bypass instruction
//********************************************************************************

class jtag_inst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_inst_seq)
  
  jtag_seq_item seq;
  
  bit m_tms[] = `TMS_DEF;
  
  //instruction variable
  jtag_ir m_inst;
  
  //Constructor
  function new(string name = "jtag_inst_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(seq,{seq.inst == m_inst;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];
                      })
  endtask
  
endclass:jtag_inst_seq

//********************************************************************************
//sequence to veriy any random instruction 
//********************************************************************************

class jtag_RandInst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_RandInst_seq )
   jtag_seq_item seq;
  
  //Constructor
  function new(string name = "jtag_RandInst_seq");
    super.new(name);
  endfunction
  
   virtual task body();
     start_item(seq);
     
     seq.randomize(); 
     //set tms pattern based on the randomised instruction
      case(seq.inst)
        IDCODE      : seq.tms = `TMS_IDCODE;
        default     : seq.tms = `TMS_DEF;
      endcase
       
     finish_item(seq);
  endtask:body
  
endclass:jtag_RandInst_seq 

//******************************************************************************
//ir path sequence 
//*******************************************************************************
class ir_scan_sequence extends jtag_base_seq;
  `uvm_object_utils(ir_scan_sequence)
  
  jtag_seq_item seq;
  bit m_tms[] = `IR_TMS;
  rand jtag_ir m_inst;
  
  function new(string name = "ir_scan_sequence");
    super.new(name);
  endfunction
  
  
  virtual task body();
    
    `uvm_do_with(seq,{seq.inst == m_inst;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];
                      })
  endtask
    
endclass :ir_scan_sequence 
//******************************************************************************
//Data scan path sequence 
//*******************************************************************************
class dr_scan_sequence extends jtag_base_seq;
  `uvm_object_utils(dr_scan_sequence)
  
  jtag_seq_item seq;
  bit m_tms[] = `DR_TMS;
  rand jtag_ir m_inst;
  
  function new(string name = "dr_scan_sequence");
    super.new(name);
  endfunction
  
  
  virtual task body();
    
    `uvm_do_with(seq,{seq.inst == m_inst;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];
                      })
  
  endtask
    
endclass :dr_scan_sequence 

//******************************************************************************
//instruction check  sequence 
//*******************************************************************************

class inst_check_sequence extends jtag_base_seq;
  `uvm_object_utils(inst_check_sequence)
  
  dr_scan_sequence d_seq;
  ir_scan_sequence i_seq;
  jtag_ir m_instr;
  
  function new(string name = "inst_check_sequence");
    super.new(name);
  endfunction
  
  
  virtual task body();
    i_seq = ir_scan_sequence::type_id::create("i_seq");
    if(!i_seq.randomize() with {m_inst == m_instr;})
      `uvm_error(get_type_name(),"RANODMIZATION FAILED")
    i_seq.start(m_sequencer);
   
  
    d_seq = dr_scan_sequence::type_id::create("d_seq");
    if(!d_seq.randomize() with {m_inst == m_instr;})
      `uvm_error(get_type_name(),"RANODMIZATION FAILED")
    d_seq.start(m_sequencer);
    
  endtask
    
endclass : inst_check_sequence

