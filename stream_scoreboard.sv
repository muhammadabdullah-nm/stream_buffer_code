`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

// In-order data checker: every read must match the oldest unread write.
// Catches drop / duplicate / reorder (rule 2).
class stream_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(stream_scoreboard)

  uvm_analysis_imp_wr #(wr_item, stream_scoreboard) wr_imp;
  uvm_analysis_imp_rd #(rd_item, stream_scoreboard) rd_imp;

  bit [DATA_W-1:0] exp_q[$];
  int unsigned     wr_cnt, rd_cnt, err_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  function void write_wr(wr_item t);
    exp_q.push_back(t.data);
    wr_cnt++;
  endfunction

  function void write_rd(rd_item t);
    bit [DATA_W-1:0] exp;
    rd_cnt++;
    if (exp_q.size() == 0) begin
      `uvm_error("SB", $sformatf("Read 0x%0h with no pending write", t.data))
      err_cnt++;
      return;
    end
    exp = exp_q.pop_front();
    if (t.data !== exp) begin
      `uvm_error("SB", $sformatf("Data mismatch: exp=0x%0h act=0x%0h", exp, t.data))
      err_cnt++;
    end
  endfunction

  function void check_phase(uvm_phase phase);
    if (exp_q.size() != 0) begin
      `uvm_error("SB", $sformatf("%0d written item(s) never read", exp_q.size()))
      err_cnt++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("writes=%0d reads=%0d errors=%0d", wr_cnt, rd_cnt, err_cnt), UVM_NONE)
  endfunction
endclass