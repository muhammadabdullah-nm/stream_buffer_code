// Generates num_cycles cycles of m_ready.
class rd_seq extends uvm_sequence #(rd_item);
  `uvm_object_utils(rd_seq)

  int unsigned num_cycles = 100;

  function new(string name = "rd_seq");
    super.new(name);
  endfunction

  task body();
    repeat (num_cycles) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("RD_SEQ", "randomize failed")
      finish_item(req);
    end
  endtask
endclass