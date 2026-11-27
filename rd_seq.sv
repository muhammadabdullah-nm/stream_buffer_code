// Generates num_cycles cycles of random m_ready.
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


// m_ready high for 200 cycles, then low for 200 cycles
class rd_when_ready_toggle extends rd_seq;
  `uvm_object_utils(rd_when_ready_toggle)

  function new(string name = "rd_when_ready_toggle");
    super.new(name);
  endfunction

  task body();
    // 200 cycles high
    repeat (200) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b0;
      finish_item(req);
    end

    // 200 cycles low
    repeat (200) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b1;
      finish_item(req);
    end
  endtask
endclass

class rd_empty_seq extends rd_seq;
  `uvm_object_utils(rd_empty_seq)

  function new(string name = "rd_empty_seq");
    super.new(name);
  endfunction

  task body();
    repeat (10) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b1;
      finish_item(req);
    end
    // hold m_ready low from here on (driver keeps the last value)
    req = rd_item::type_id::create("req");
    start_item(req);
    req.ready = 1'b0;
    finish_item(req);
  endtask
endclass


// Phase 3: m_ready high long enough to drain a full buffer
class rd_drain_seq extends rd_seq;
  `uvm_object_utils(rd_drain_seq)

  function new(string name = "rd_drain_seq");
    super.new(name);
  endfunction

  task body();
    repeat (30) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b1;
      finish_item(req);
    end
  endtask
endclass

// m_ready held low for hold_cycles (no reads while the buffer fills up and sits full)
class rd_hold_low_seq extends rd_seq;
  `uvm_object_utils(rd_hold_low_seq)

  int unsigned hold_cycles = 50;

  function new(string name = "rd_hold_low_seq");
    super.new(name);
  endfunction

  task body();
    repeat (hold_cycles) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b0;
      finish_item(req);
    end
  endtask
endclass