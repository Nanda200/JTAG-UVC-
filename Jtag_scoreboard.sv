class jtag_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(jtag_scoreboard)
  uvm_analysis_imp#(jtag_seq_item, jtag_scoreboard) item_collected_export;

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction: build_phase
  
   // write
  virtual function void write(jtag_seq_item item);
    $display("SCB:: Pkt recived");
    item.print();
  endfunction : write

endclass : jtag_scoreboard