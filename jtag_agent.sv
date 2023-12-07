class jtag_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  jtag_driver    drv;
  jtag_sequencer seqr;
  jtag_monitor   mon;

  `uvm_component_utils(jtag_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    mon = jtag_monitor::type_id::create("mon", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      drv   = jtag_driver::type_id::create("drv", this);
      seqr = jtag_sequencer::type_id::create("seqr", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : jtag_agent
