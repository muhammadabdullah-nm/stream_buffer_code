// Publishes a rd_item for every accepted read (m_valid && m_ready).
// Also checks rule 4: m_data stable while m_valid=1 and m_ready=0.
class rd_monitor extends uvm_monitor;
  `uvm_component_utils(rd_monitor)

  virtual DUT_intf vif;
  uvm_analysis_port #(rd_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual DUT_intf)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "rd_monitor: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    rd_item          item;
    bit              stalled;      // previous cycle: valid=1, ready=0
    bit [DATA_W-1:0] stalled_data;

    stalled = 0;
    forever begin
      @(vif.monitor_cb);

      if (vif.rst_n !== 1'b1) begin
        stalled = 0;
        continue;
      end

      // rule 4 check
      if (stalled) begin
        if (vif.monitor_cb.m_valid !== 1'b1)
          `uvm_error("RD_MON", "m_valid dropped while m_ready was low")
        else if (vif.monitor_cb.m_data !== stalled_data)
          `uvm_error("RD_MON", $sformatf("m_data changed while stalled: was 0x%0h now 0x%0h",
                                         stalled_data, vif.monitor_cb.m_data))
      end

      // completed transfer
      if (vif.monitor_cb.m_valid === 1'b1 && vif.monitor_cb.m_ready === 1'b1) begin
        item = rd_item::type_id::create("item");
        item.ready = 1'b1;
        item.data  = vif.monitor_cb.m_data;
        ap.write(item);
      end

      stalled      = (vif.monitor_cb.m_valid === 1'b1 && vif.monitor_cb.m_ready !== 1'b1);
      stalled_data = vif.monitor_cb.m_data;
    end
  endtask
endclass