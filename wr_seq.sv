class wr_seq extends uvm_sequence #(wr_item);
  `uvm_object_utils(wr_seq)

  int unsigned num_items = 20;

  function new(string name = "wr_seq");
    super.new(name);
  endfunction

  task body();
    repeat (num_items) begin
      req = wr_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("WR_SEQ", "randomize failed")
      finish_item(req);
    end
  endtask
endclass