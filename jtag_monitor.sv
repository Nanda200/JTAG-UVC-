
class jtag_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual jtag_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(jtag_seq_item) out_item_collected_port;
  uvm_analysis_port #(jtag_seq_item) in_item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured 
  //---------------------------------------
  jtag_seq_item out_item_collected;
  jtag_seq_item in_item_collected;
  bit mon_tdo[]; //temporary container to collect all the tdo bits
  bit mon_tdi[]; //temporary container to collect all the input tdi bits

  `uvm_component_utils(jtag_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  //  item_collected = new();
    out_item_collected_port = new("out_item_collected_port", this);
    in_item_collected_port = new("in_item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jtag_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
   
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal and assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    out_item_collected = jtag_seq_item::type_id::create("out_item_collected",this);
    in_item_collected =  jtag_seq_item::type_id::create("in_item_collected",this);
     
    forever begin
     
      fork
      collect_tdi();
      collect_tdo();
      join
     end
  endtask : run_phase
  
  //collect tdi bits for creating reference item to compare in scoreboard
  task collect_tdi();
    int i = (`IR_LENGTH - 1); // to iterate and store inst
    //wait till it reaches shift-ir state 
    wait(vif.shift_ir);
    @(posedge vif.tck);
   //start collecting instr bits from tdo
    while(vif.shift_ir)
      begin
        @(posedge vif.tck);
        in_item_collected.inst[i] = vif.tdi;
        i--;
      end
   //----------------------------------------
   //start collecting driven tdi bits from vif
     wait(vif.shift_dr_o );
    repeat(2)@(posedge vif.tck);
      while(vif.shift_dr_o)
      begin
              
        mon_tdi = new[mon_tdi.size()+1](mon_tdi);  
       // $display(in_item_collected.inst.name);
        case(in_item_collected.inst)
         
          DEBUG                 : mon_tdi[mon_tdi.size() - 1] =  vif.debug_tdi_i ;
          SAMPLE_PRELOAD,EXTEST : mon_tdi[mon_tdi.size() - 1] = vif.bs_chain_tdi_i;
          MBIST                 : mon_tdi[mon_tdi.size() - 1] = vif.mbist_tdi_i ;
          IDCODE                : mon_tdi[mon_tdi.size() - 1] = 0;
          default               : mon_tdi[mon_tdi.size() - 1] = vif.tdi; 
            
        endcase
        //mon_tdi[mon_tdi.size()-1] = vif.tdi; 
        @(posedge vif.tck);
        end
       mon_tdi.reverse();
       in_item_collected.tdi = new[mon_tdi.size()](mon_tdi);
    
      
    `uvm_info(get_type_name(),$sformatf("MONITORED INPUT ITEM:%s",in_item_collected.convert2string()),UVM_LOW)
       in_item_collected_port.write(in_item_collected);
      
    
  endtask
  

 //collect shifted out tdo bits from DUT via interface 
  task collect_tdo();
    int i = (`IR_LENGTH - 1);
    wait(vif.shift_ir);
      @(posedge vif.tck);
    //start collecting instr bits from tdo_o pin
    while(vif.shift_ir)
      begin
        @(negedge vif.tck);
        out_item_collected.inst[i] = vif.tdo_o;
        i--;
      end
 
     //start collecting tdo padding bits in shift dr state
    
    wait(vif.shift_dr_o);
    repeat(2)@(posedge vif.tck);
    while(vif.shift_dr_o)
      begin
       
        
        mon_tdo = new[mon_tdo.size()+1](mon_tdo);  
        
        case(out_item_collected.inst)
          
          BYPASS : mon_tdo[mon_tdo.size()-1] = vif.tdo_o;
          default :  mon_tdo[mon_tdo.size()-1] = vif.tdo_pad_o;
          
        endcase
       
        @(negedge vif.tck);
         // 00001111100101010001000111000011
        end
      /*$display("%0d",mon_tdo.size());
      $display("tdo :%p",mon_tdo);
      $display("tdi :%p",mon_tdi);*/
      mon_tdo.reverse();
      out_item_collected.tdo = new[mon_tdo.size()](mon_tdo);
      
      `uvm_info(get_type_name(),$sformatf("MONITORED OUTPUT ITEM:%s",out_item_collected.convert2string()),UVM_LOW)
      out_item_collected_port.write(out_item_collected);
      
   endtask
  
 /* 
  task collect_instr();
    
    int i ;
    //wait till it reaches shift-ir state 
    wait(vif.shift_ir == 1);
    @(posedge vif.tck);
    //start collecting instr bits from tdo
    while(vif.shift_ir)
      begin
        @(posedge vif.tck);
        in_item_collected.inst[i] = vif.tdi;
        out_item_collected.inst[i] = vif.tdo_o;
        i++;
      end
  endtask

  task collect_data();
    
     //start collecting tdo padding bits in shift dr state
      wait(vif.shift_dr_o == 1);
      repeat(2)@(posedge vif.tck);
      while(vif.shift_dr_o)
      begin
       
        @(posedge vif.tck);
        mon_tdo = new[mon_tdo.size()+1](mon_tdo);       
        mon_tdo[mon_tdo.size()-1] = vif.tdo_pad_o;
        
        mon_tdi = new[mon_tdi.size()+1](mon_tdi);  
        mon_tdi[mon_tdi.size()-1] = vif.tdi;   
         // 00001111100101010001000111000011
        end
    
    
       in_item_collected.tdi = new[mon_tdi.size()](mon_tdi);
       out_item_collected.tdo = new[mon_tdo.size()](mon_tdo);
    
  endtask*/
  
endclass : jtag_monitor
