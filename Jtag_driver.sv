
class jtag_driver extends uvm_driver #(jtag_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual jtag_if vif;
  `uvm_component_utils(jtag_driver)
  
    //defined in defines file
    tap_state current_state = RESET;
    int inst_size;
    int data_size;
    bit exit,next;
  
    jtag_seq_item temp;
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
      `uvm_info(get_type_name(),$sformatf("RECEIVED ITEM IN DRV:%s",req.convert2string()),UVM_LOW)
      
      
      $cast(temp,req.clone()); // temp_req will be modified
      `uvm_info("JTAG_DRIVER_INFO", " Driving -> ", UVM_LOW)
       temp.print();
      
      inst_size = $size(req.inst);
    /*  
      if(temp.inst == IDCODE)
        data_size = 31;
      else
        data_size = req.tdi.size();*/
      data_size = (temp.inst == IDCODE)? 32:(req.tdi.size());
      
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  // tms pattern moves fsm from one state to another
  // for waiting in shift and pause dr state apply tms <= 0 
  //---------------------------------------
  task drive();
    
    int i = 0;
    exit = 0;
    next = 0;

   while(!exit) begin
     
     
     if((!next) && ((current_state == SHIFT_DR) || (current_state == SHIFT_IR) || (current_state == PAUSE_DR) || (current_state == PAUSE_IR))) begin
       vif.tms <= 0;
     //  $display("next = %0b",next);
       //$display("if loop,");
     end  
     else begin
       vif.tms <= temp.tms[i];
      // $display("else loop,%0d tms : %0b",i,temp.tms[i]);
       i++;
     end
     
      @(posedge vif.tck);
     drive_fsm();
   
     end
  endtask : drive
  
  //wait for shift-IR state drive inst to tdi_pad_i
  //wait for shift-DR drive random tdi pattern and drive out tdo
  task drive_fsm();
    
    //for debugging
    `uvm_info(get_type_name(),$sformatf("CURRENT_STATE = %s",current_state.name),UVM_DEBUG)
    
    exit = 0;
    next = 0;
    case (current_state)
 
    RESET:
      begin   
      
        if(vif.tms == 0) 
          current_state = IDLE;
        else
          current_state = RESET;
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
 
    
         data_size -- ;   
        
   
          case(req.inst)              
           
            DEBUG              : vif.debug_tdi_i <= temp.tdi[data_size];
            SAMPLE_PRELOAD,EXTEST : vif.bs_chain_tdi_i <= temp.tdi[data_size];
            MBIST              : vif.mbist_tdi_i <= temp.tdi[data_size];
            IDCODE             : vif.tdi <= 0;
            default            : vif.tdi <= temp.tdi[data_size];
                     
          endcase
        
         if(data_size == 0) begin
           next = 1;
          
          end
        `uvm_info(get_type_name(),$sformatf("temp.tdi[%0d] = %0b = %0b",data_size,temp.tdi[data_size],vif.tdi),UVM_DEBUG);
        
        //state shifting logic
         if(vif.tms == 1)
          current_state = EXIT_DR;
        else
          current_state = SHIFT_DR;     
   
      end
      
    SHIFT_IR: 
      begin
        
        if(vif.tms == 1)
          current_state = EXIT_IR;
      
        
        inst_size--; 
        if (inst_size > 0)
          begin
            vif.tdi <= req.inst[inst_size];  
            //$display(inst_size);
          end
       else begin
         //$display("else inst loop");
         vif.tdi <= req.inst[inst_size];
         next = 1;  
       end
        //$display(vif.tdi);
        //$display("next is %0d",next);
     
      end
    EXIT_DR:
      begin
        //exit = 1;
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
        if(temp.ds_dly == 0)
          next = 1;
        
        temp.ds_dly --;
        
        if(vif.tms == 1)
          current_state = EXIT2_DR;
        else 
          current_state = PAUSE_DR;
        
       
      end
    PAUSE_IR:
      begin
        
        
        if(temp.irs_dly == 0)
          next = 1;
        
        temp.irs_dly --;
        
        if(vif.tms == 1)
          current_state = EXIT2_IR;
        else 
          current_state = PAUSE_IR;
        
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
    UPDATE_DR : 
      begin
        
         exit = 1;
        if(vif.tms == 1)
          current_state = SELECT_DR;
        else
          current_state = IDLE;
      end
      
    UPDATE_IR:
       begin
        exit = 1;
        if(vif.tms == 1)
          current_state = SELECT_DR;
        else
          current_state = IDLE;
        
      end
  endcase 
 
endtask :drive_fsm
    

  task tmsReset();
    
    vif.tms <= 1;
    repeat(5)@(posedge vif.tck);
    
  endtask
  
endclass :jtag_driver
