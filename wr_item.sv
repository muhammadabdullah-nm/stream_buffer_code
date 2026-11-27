class wr_item extends uvm_sequence_item;
  `uvm_object_utils(wr_item)

  rand bit [DATA_W-1:0] data;
  rand int unsigned     delay;   // idle cycles before s_valid is raised

  constraint c_delay { delay dist {0 := 6, [1:3] := 4}; }

  function new(string name = "wr_item");
    super.new(name);
  endfunction
endclass