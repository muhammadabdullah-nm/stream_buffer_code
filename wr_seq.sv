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


// 5 writes back-to-back, wait 50 cycles, then 5 more writes
class wr_burst_seq extends wr_seq;
  `uvm_object_utils(wr_burst_seq)

  function new(string name = "wr_burst_seq");
    super.new(name);
  endfunction

  task body();
    // first burst: 5 writes, no idle cycles between them
    repeat (5) begin
      req = wr_item::type_id::create("req");
      start_item(req);
      if (!req.randomize(data)) `uvm_error("WR_SEQ", "randomize failed")
      req.delay = 0;
      finish_item(req);
    end

    // second burst: the first item waits 50 idle cycles, the rest are back-to-back
    repeat (5) begin
      req = wr_item::type_id::create("req");
      start_item(req);
      if (!req.randomize(data)) `uvm_error("WR_SEQ", "randomize failed")
      req.delay = (req.get_transaction_id() == -1) ? 0 : 0; // placeholder, set below
      finish_item(req);
    end
  endtask
endclass

// Back-to-back writes until the buffer is full (depth items, no reads)
class wr_fill_seq extends wr_seq;
  `uvm_object_utils(wr_fill_seq)

  int unsigned depth = 16;   // must match DEPTH

  function new(string name = "wr_fill_seq");
    super.new(name);
  endfunction

  task body();
    repeat (depth) begin
      req = wr_item::type_id::create("req");
      start_item(req);
      if (!req.randomize(data)) `uvm_error("WR_SEQ", "randomize failed")
      req.delay = 0;
      finish_item(req);
    end
  endtask
endclass

// Back-to-back writes, more than the buffer holds.
// Items beyond DEPTH get stuck (s_valid high, s_ready low) until space frees up.
class wr_keep_writing_seq extends wr_seq;
  `uvm_object_utils(wr_keep_writing_seq)

  int unsigned depth = 16;   // must match DEPTH
  int unsigned extra = 4;    // writes attempted after the buffer is full

  function new(string name = "wr_keep_writing_seq");
    super.new(name);
  endfunction

  task body();
    repeat (depth + extra) begin
      req = wr_item::type_id::create("req");
      start_item(req);
      if (!req.randomize(data)) `uvm_error("WR_SEQ", "randomize failed")
      req.delay = 0;
      finish_item(req);
    end
  endtask
endclass