interface jtag_if(input bit tck);
  
   // JTAG pads
   logic tms; 
   logic trst;
   logic tdi;
   logic tdo_pad_o; 
   logic tdo_padoe_o;

   // TAP states
   logic shift_dr_o;
   logic pause_dr_o; 
   logic update_dr_o;
   logic capture_dr_o;
                
   // Select signals for boundary scan or mbist
   logic extest_select_o;
   logic sample_preload_select_o;
   logic mbist_select_o;
   logic debug_select_o;
                
   // TDO signal that is connected to TDI of sub-modules.
   logic tdo_o; 
                
   // TDI signals from sub-modules
   logic debug_tdi_i;    // from debug module
   logic  bs_chain_tdi_i; // from Boundary Scan Chain
   logic mbist_tdi_i;     // from Mbist Chain   
    
     
             
endinterface :jtag_if