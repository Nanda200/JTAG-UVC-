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

class jtag_BypassInst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_BypassInst_seq)
  
   jtag_seq_item seq;
  
  bit m_tms[] = `TMS_DEF;
  //Constructor
  function new(string name = "jtag_BypassInst_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(seq,{seq.inst == BYPASS;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];
                      })
  endtask
  
endclass:jtag_BypassInst_seq
//********************************************************************************
//sequence to veriy sample instruction
//********************************************************************************

class jtag_SampleInst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_SampleInst_seq)
   jtag_seq_item seq;
  
  bit m_tms[] = `TMS_DEF;
  //Constructor
  function new(string name = "jtag_SampleInst_seq ");
    super.new(name);
  endfunction
  
    virtual task body();
      `uvm_do_with(seq,{seq.inst == SAMPLE_PREL;
                        seq.tms.size() == m_tms.size();
                        foreach(tms[i])
                        tms[i] == m_tms[i];
                       })
  endtask
  
endclass:jtag_SampleInst_seq 
/*
//********************************************************************************
//sequence to veriy preload instruction
//********************************************************************************

class jtag_PreloadInst_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_PreloadInst_seq)
  
   jtag_seq_item seq;
  
  bit m_tms[] = `TMS_PRELOAD;
  //Constructor
  function new(string name = "jtag_PreloadInst_seq ");
    super.new(name);
  endfunction
  
    virtual task body();
      `uvm_do_with(seq,{seq.inst == SAMPLE_PREL;
                        seq.tms.size() == m_tms.size();
                        foreach(tms[i])
                        tms[i] == m_tms[i];
                       })
  endtask
  
endclass:jtag_PreloadInst_seq 
*/
//********************************************************************************
//sequence to veriy whether extest instruction is enabled or not
//********************************************************************************

class jtag_ExtestEn_seq extends jtag_base_seq;
  
  `uvm_object_utils(jtag_ExtestEn_seq)
   jtag_seq_item seq;
  
  bit m_tms[] = `TMS_DEF;
  
  //Constructor
  function new(string name = "jtag_ExtestEn_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(seq,{seq.inst == EXTEST;
                      seq.tms.size() == m_tms.size();
                      foreach(tms[i])
                        tms[i] == m_tms[i];})
  endtask:body
  
endclass:jtag_ExtestEn_seq

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
        //EXTEST      : seq.tms = `TMS_EXTEST;         
       // SAMPLE_PREL : seq.tms = `TMS_SAMPLE; 
       // BYPASS      : seq.tms = `TMS_BYPASS;
        IDCODE      : seq.tms = `TMS_IDCODE;
        default     : seq.tms = `TMS_DEF;
      endcase
       
     finish_item(seq);
  endtask:body
  
endclass:jtag_RandInst_seq 
//******************************************************************************
