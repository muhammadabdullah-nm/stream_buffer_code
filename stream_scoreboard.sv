`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class stream_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(stream_scoreboard)

  uvm_analysis_imp_wr #(wr_item, stream_scoreboard) wr_imp;
  uvm_analysis_imp_rd #(rd_item, stream_scoreboard) rd_imp;

  // Expected data queue
  bit [DATA_W-1:0] exp_q[$];

  // Statistics
  int unsigned wr_cnt, rd_cnt, err_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  //------------------------------------------------
  // Write side (slave / input)
  //------------------------------------------------
  function void write_wr(wr_item t);
    exp_q.push_back(t.data);
    wr_cnt++;
    `uvm_info("SB", $sformatf("WR  data=0x%0h  queue_size=%0d", t.data, exp_q.size()), UVM_HIGH)
  endfunction

  //------------------------------------------------
  // Read side (master / output)
  //------------------------------------------------
  function void write_rd(rd_item t);
    bit [DATA_W-1:0] exp;

    rd_cnt++;

    if (exp_q.size() == 0) begin
      `uvm_error("SB", $sformatf("Unexpected READ 0x%0h (queue empty)", t.data))
      err_cnt++;
      return;
    end

    exp = exp_q.pop_front();

    if (t.data !== exp) begin
      `uvm_error("SB", $sformatf("Data MISMATCH: exp=0x%0h  act=0x%0h", exp, t.data))
      err_cnt++;
    end
    else begin
      `uvm_info("SB", $sformatf("MATCH  data=0x%0h  remaining=%0d", t.data, exp_q.size()), UVM_HIGH)
    end
  endfunction

  //------------------------------------------------
  // End-of-test checks
  //------------------------------------------------
  function void check_phase(uvm_phase phase);
    if (exp_q.size() != 0) begin
      `uvm_error("SB", $sformatf("%0d item(s) written but never read", exp_q.size()))
      err_cnt++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("=== SCOREBOARD SUMMARY ==="), UVM_NONE)
    `uvm_info("SB", $sformatf("  Writes : %0d", wr_cnt), UVM_NONE)
    `uvm_info("SB", $sformatf("  Reads  : %0d", rd_cnt), UVM_NONE)
    `uvm_info("SB", $sformatf("  Errors : %0d", err_cnt), UVM_NONE)
    if (err_cnt == 0)
      `uvm_info("SB", "  STATUS : PASSED", UVM_NONE)
    else
      `uvm_error("SB", "  STATUS : FAILED")
  endfunction

endclass