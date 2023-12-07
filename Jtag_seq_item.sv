//JTAG_seq_item

class jtag_seq_item extends uvm_sequence_item;
  
  rand bit tms[]; //tms pattern 
  rand bit tdi[]; //tdi 
  rand jtag_ir inst;
  rand int ds_dly;
  rand int irs_dly;
  bit tdo[];
  
   
 
 
  //include field macro automation if AUTOMATE is defined,else use userdefined hooks
  
  `uvm_object_utils(jtag_seq_item)
  
  `ifdef AUTOMATE 
  
  `uvm_object_utils_begin(jtag_seq_item)
     `uvm_field_enum(jtag_ir, inst, UVM_DEFAULT)
     `uvm_field_array_int(tms, UVM_DEFAULT)
     `uvm_field_array_int(tdi, UVM_DEFAULT)
     `uvm_field_array_int(tdo, UVM_DEFAULT)
     `uvm_field_int(ds_dly,UVM_DEFAULT)
     `uvm_field_int(irs_dly,UVM_DEFAULT)
  `uvm_object_utils_end
  
 `endif
  
  //fixing the size of tdi to 10
  constraint size_con {soft tdi.size() == 10;
                     }
 
  /*//constrainig delay to max 5 cycles
  constraint delay_con1 {ds_dly > 0;
                        ds_dly < 5; }
  constraint delay_con2 {irs_dly > 0;
                         irs_dly < 5; }*/
  
  constraint delay_con2 {ds_dly == 0;
                         irs_dly == 0;}
 
  
   function new(string name = "jtag_seq_item");
     super.new(name);
   endfunction
 

 //--------------------------------------------------------
 //callback methods
 //--------------------------------------------------------
   //callback hook for print method
   virtual function void do_print(uvm_printer printer);
     
     super.do_print(printer);
     
     foreach(tms[i])
       printer.print_field_int($sformatf("tms[%0d]", i), tms[i], $bits(tms[i]), UVM_BIN);
     foreach(tdi[i])
       printer.print_field_int($sformatf("tdi[%0d]", i), tdi[i], $bits(tdi[i]), UVM_BIN);
     foreach(tdo[i])
       printer.print_field_int($sformatf("tdo[%0d]", i), tdo[i], $bits(tdo[i]), UVM_BIN);
     
     printer.print_string("INSTRUCTION", inst.name); 
     printer.print_field_int("DS_DELAY",ds_dly,$bits(ds_dly),UVM_DEC);
     printer.print_field_int("IRS_DELAY",irs_dly,$bits(irs_dly),UVM_DEC);
   endfunction : do_print 
  
  
  //callback hook for copy method
  virtual function void do_copy(uvm_object rhs);
    jtag_seq_item item;
    super.do_copy(rhs);
    $cast(item, rhs);
    tms = item.tms;
    tdi = item.tdi;
    inst = item.inst;
    tdo = item.tdo;    
  endfunction : do_copy
  
   // User defined callback of compare method
   virtual function bit do_compare (uvm_object rhs,uvm_comparer comparer);
     jtag_seq_item item;
     bit idcode[32];    
     bit comp;
     
     $cast(item, rhs);
     
     if(item.inst == IDCODE) begin
       {>>{idcode}} = `IDCODE_VALUE;
      // $display("idcode val :%p",idcode);
       comp = super.do_compare(item,comparer) & (inst == item.inst) & (item.tdo == idcode);
     end
     else begin
       comp = super.do_compare(item, comparer) & (tdi == item.tdo) & (inst == item.inst) ;
     end
     return comp;
   endfunction : do_compare
   
   
  virtual function string convert2string();
    string contents;
    $sformat(contents, "tms_pattern = %p,tdi = %p,inst= %b,tdo = %p", tms, tdi, inst,tdo);
    return contents;
  endfunction : convert2string
 
  
endclass:jtag_seq_item
