// Code your testbench here
// or browse Examples


//--------------------------------------------------------------
`include "uvm_macros.svh"

//importing uvm package
import uvm_pkg :: *;

//including interfcae and testcase files
`include "defines.h"
`include "jtag_interface.sv"
`include "jtag_seq_item.svh"
`include "jtag_sequences.svh"
`include "jtag_sequencer.svh"

`include "jtag_driver.svh"
`include "jtag_monitor.svh"
`include "jtag_agent.svh"
`include "jtag_env.svh"
`include "jtag_base_test.svh"

`include "jtag_IdcodeInstr_test.svh"
//-------------------------------------------------------------------


module tb_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit tck;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 tck = ~tck;
  
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  jtag_if vif(tck);
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  tap_top DUT (
    .tms_pad_i(vif.tms),
    .tck_pad_i(tck),
    .trst_pad_i(vif.trst),
    .tdi_pad_i(vif.tdi),
    .tdo_pad_o(vif.tdo_pad_o),
    .tdo_padoe_o(vif.tdo_padoe_o),
    .shift_dr_o(vif.shift_dr_o),
    .pause_dr_o(vif.pause_dr_o),
    .update_dr_o(vif.update_dr_o),
    .capture_dr_o(vif.capture_dr_o),
    .extest_select_o(vif.extest_select_o),
    .sample_preload_select_o(vif.sample_preload_select_o),
    .mbist_select_o(vif.mbist_select_o),
    .debug_select_o(vif.debug_select_o),
    .tdo_o(vif.tdo_o),
    .debug_tdi_i(vif.debug_tdi_i),
    .bs_chain_tdi_i(vif.bs_chain_tdi_i),
    .mbist_tdi_i(vif.mbist_tdi_i)
   );
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual jtag_if)::set(uvm_root::get(),"*","vif",vif);
    
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test("jtag_IdcodeInstr_test");
   
  end
  
endmodule
















