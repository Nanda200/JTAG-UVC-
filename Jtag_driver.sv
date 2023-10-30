
class jtag_driver extends uvm_driver #(jtag_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual jtag_if vif;
  `uvm_component_utils(jtag_driver)
  
    //defined in defines file
    tap_state current_state = X;
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jtag_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    tmsReset();
    forever begin
      seq_item_port.get_next_item(req);
     
      fork
      drive_tms();
      drive_tdi();
   //   collect_tdo();
      join
      //req.print();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  task drive_tms();
    
    for(int i = 0;i<$size(req.tms);i++) begin
      vif.tms<= req.tms[i];
      @(posedge vif.tck);
    end
    
  endtask : drive_tms
  
  //wait for shift-IR state drive inst to tdi_pad_i
  //wait for shift-DR drive random tdi pattern and drive out tdo
task drive_tdi();
 
  case (current_state)
    X:
      begin 
        if(vif.tms == 1) 
          current_state = RESET;
      end        
    RESET:
      begin 
        if(vif.tms == 0) 
          current_state = IDLE;
      end
    IDLE: 
      begin
        if(vif.tms == 1) 
          current_state = SELECT_DR;
      end
    SELECT_DR: 
      begin
        if(vif.tms == 1) 
          current_state = SELECT_IR;
        else
          current_state = CAPTURE_DR;
      end
    SELECT_IR: 
      begin
        if(vif.tms == 1)
          current_state = RESET;
        else
          current_state = CAPTURE_IR;
      end
    CAPTURE_DR: 
      begin
        if(vif.tms == 1)
          current_state = EXIT_DR;
        else
          current_state = SHIFT_DR;
      end
    CAPTURE_IR: 
      begin
        if(vif.tms == 1)
          current_state = EXIT_IR;
        else
          current_state = SHIFT_IR;
      end
    SHIFT_DR: 
      begin
        foreach(req.tdi[i])
          vif.tdi <= req.tdi[i];
        if(vif.tms == 1)
          current_state = EXIT_DR;
        else
          current_state = SHIFT_DR; 
      end
    SHIFT_IR: 
      begin
        for(int i=4;i>0;i--)
          begin
            vif.tdi <= req.inst[i];
          end
       
        if(vif.tms == 1)
          current_state = EXIT_IR;
        else
          current_state = SHIFT_IR; 
          
      end
    EXIT_DR:
      begin
       
        if(vif.tms == 1)
          current_state = UPDATE_DR;
        else
          current_state = PAUSE_DR;
      end
    EXIT_IR:
      begin
       
        if(vif.tms == 1)
          current_state = UPDATE_IR;
        else
          current_state = PAUSE_IR;
      end
    PAUSE_DR:
      begin
        if(vif.tms == 1)
          current_state = EXIT2_DR;
      end
    PAUSE_IR:
      begin
        if(vif.tms == 1)
          current_state = EXIT2_IR;
      end
    EXIT2_DR:
      begin
        if(vif.tms == 1)
          current_state = UPDATE_DR;
        else
          current_state = SHIFT_DR;
      end
    EXIT2_IR:
      begin
        if(vif.tms == 1)
          current_state = UPDATE_IR;
        else
          current_state = SHIFT_IR;
      end
    UPDATE_DR, UPDATE_IR:
      begin
        if(vif.tms == 1)
          current_state = SELECT_DR;
        else
          current_state = IDLE;
      end
  endcase 
  
endtask
    

  task tmsReset();
    
    vif.tms <= 1;
    repeat(5)@(posedge vif.tck);
    
  endtask
  
endclass :jtag_driver