// Drives m_ready, one item per clock cycle.
class rd_driver extends uvm_driver #(rd_item);
  `uvm_component_utils(rd_driver)

  virtual DUT_intf vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual DUT_intf)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "rd_driver: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    vif.driver_cb.m_ready <= 1'b0;
    wait (vif.rst_n === 1'b1);
    @(vif.driver_cb);

    forever begin
      seq_item_port.get_next_item(req);
      vif.driver_cb.m_ready <= req.ready;
      @(vif.driver_cb);
      seq_item_port.item_done();
    end
  endtask
endclass