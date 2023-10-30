//JTAG_seq_item

class jtag_seq_item extends uvm_sequence_item;
  
  rand bit tms[]; //tms pattern 
  rand bit tdi[]; //tdi 
  rand jtag_ir inst;
  bit tdo[];
  
 
 
    //include field macro automation if AUTOMATE is defined,else use userdefined hooks
  
  //`uvm_object_utils(jtag_seq_item)
  
 
   //`ifdef AUTOMATE 
  
  `uvm_object_utils_begin(jtag_seq_item)
  `uvm_field_enum(jtag_ir, inst, UVM_DEFAULT)
    `uvm_field_array_int(tms, UVM_DEFAULT)
    `uvm_field_array_int(tdi, UVM_DEFAULT)
    `uvm_field_array_int(tdo, UVM_DEFAULT)
  `uvm_object_utils_end
  
// `endif
  
  
   function new(string name = "jtag_seq_item");
    super.new(name);
  endfunction
 
  
   //fixing the size of tdi to 10
  constraint con {tdi.size() == 10;}
  
  
   virtual function string convert2string();
    
     string contents;
     $sformat(contents, "tms_pattern = %0p,tdi = %0p,inst= %0s,tdo = %0p", tms, tdi, inst.name,tdo);
      return contents;
    
   endfunction : convert2string
 
/*    
 //--------------------------------------------------------
 //callback methods
 //--------------------------------------------------------
   virtual function void do_print(uvm_printer printer);
     super.do_print(printer);
     foreach(tms[i])
       printer.print_field_int($sformatf("tms[%0d]", i), data[i], $bits(data[i]), UVM_HEX);
     printer.print_field("data=", data, $bits(data), UVM_HEX);
     printer.print_field("addr=", addr, $bits(addr), UVM_HEX);
     printer.print_string("wr_rd", wr_rd.name);
     printer.print_string("delay_type", delay.name);
     printer.print_field("delay_val", delay_val, $bits(delay_val));
                         
    
  endfunction : do_print 
  
  
  
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
   virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);
      jtag_seq_item item;
      bit comp;
      $cast(item, rhs);
      comp = super.do_compare(item, comparer) &
     (tms == item.tms) & (tdi == item.tdi) & (inst == item.inst) &(tdo == item.tdo);
      return comp;
   endfunction : do_compare
   
  */
   
  
  
endclass:jtag_seq_item