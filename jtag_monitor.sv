class jtag_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual jtag_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(jtag_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured 
  //---------------------------------------
  jtag_seq_item item_collected;
   bit mon_tdo[];

  `uvm_component_utils(jtag_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected = new();
    item_collected_port = new("item_collected_port", this);
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
    jtag_seq_item item_collected = jtag_seq_item::type_id::create("item_collected",this);
     
    forever begin
      @(posedge vif.tck);
      collect_tdo();
    end
   
  endtask : run_phase
  
 //collect shifted out tdo bits from DUT via interface 
    task collect_tdo();
     //start collecting tdo in shift dr state
      wait(vif.shift_dr_o == 1);
      while(vif.shift_dr_o)
      begin
        mon_tdo = new[mon_tdo.size()+1](mon_tdo);
        mon_tdo[mon_tdo.size() - 1] = vif.tdo_pad_o;
         @(posedge vif.tck);
       
         // 00001111100101010001000111000011
        end
      $display("%0d",mon_tdo.size());
      $display("%p",mon_tdo);
    
   endtask

endclass : jtag_monitor