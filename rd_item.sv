// One rd_item = one clock cycle of m_ready.
// 'data' is not driven; it is filled by the read monitor on a completed transfer.
class rd_item extends uvm_sequence_item;
  `uvm_object_utils(rd_item)

  rand bit              ready;
  bit [DATA_W-1:0]      data;

  constraint c_ready { ready dist {1 := 7, 0 := 3}; }

  function new(string name = "rd_item");
    super.new(name);
  endfunction
endclass