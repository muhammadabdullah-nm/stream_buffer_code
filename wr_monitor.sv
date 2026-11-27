// Publishes a wr_item for every accepted write (s_valid && s_ready).
class wr_monitor extends uvm_monitor;
  `uvm_component_utils(wr_monitor)

  virtual DUT_intf vif;
  uvm_analysis_port #(wr_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual DUT_intf)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "wr_monitor: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    wr_item item;
    forever begin
      @(vif.monitor_cb);
      if (vif.rst_n === 1'b1 &&
          vif.monitor_cb.s_valid === 1'b1 &&
          vif.monitor_cb.s_ready === 1'b1) begin
        item = wr_item::type_id::create("item");
        item.data = vif.monitor_cb.s_data;
        ap.write(item);
      end
    end
  endtask
endclass