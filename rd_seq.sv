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

// m_ready high every cycle until almost_empty is seen, then m_ready low
class rd_almost_empty_seq extends rd_seq;
  `uvm_object_utils(rd_almost_empty_seq)

  virtual DUT_intf vif;
  int unsigned max_cycles = 100;   // safety limit

  function new(string name = "rd_almost_empty_seq");
    super.new(name);
  endfunction

  task body();
    bit hit = 0;
    if (!uvm_config_db#(virtual DUT_intf)::get(m_sequencer, "", "vif", vif))
      `uvm_fatal("RD_SEQ", "virtual interface not set")

    for (int i = 0; i < max_cycles && !hit; i++) begin
      req = rd_item::type_id::create("req");
      start_item(req);
      req.ready = 1'b1;
      finish_item(req);
      if (vif.monitor_cb.almost_empty === 1'b1) hit = 1;
    end
    if (!hit) `uvm_error("RD_SEQ", "almost_empty never asserted")

    // stop reading
    req = rd_item::type_id::create("req");
    start_item(req);
    req.ready = 1'b0;
    finish_item(req);
  endtask
endclass


// one read: m_ready high for 1 cycle, then low for 1 cycle
class rd_one_read_seq extends rd_seq;
  `uvm_object_utils(rd_one_read_seq)

  function new(string name = "rd_one_read_seq");
    super.new(name);
  endfunction

  task body();
    req = rd_item::type_id::create("req");
    start_item(req);
    req.ready = 1'b1;
    finish_item(req);

    req = rd_item::type_id::create("req");
    start_item(req);
    req.ready = 1'b0;
    finish_item(req);
  endtask
endclass