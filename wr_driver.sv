// Drives s_valid / s_data. Holds them until s_ready is seen high at a clock edge.
class wr_driver extends uvm_driver #(wr_item);
  `uvm_component_utils(wr_driver)

  virtual DUT_intf vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual DUT_intf)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "wr_driver: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    vif.driver_cb.s_valid <= 1'b0;
    vif.driver_cb.s_data  <= '0;
    wait (vif.rst_n === 1'b1);
    @(vif.driver_cb);

    forever begin
      seq_item_port.get_next_item(req);

      repeat (req.delay) @(vif.driver_cb);

      vif.driver_cb.s_valid <= 1'b1;
      vif.driver_cb.s_data  <= req.data;
      @(vif.driver_cb);
      while (vif.driver_cb.s_ready !== 1'b1) @(vif.driver_cb);

      // handshake done; drop valid (next item can override this in the same cycle)
      vif.driver_cb.s_valid <= 1'b0;
      seq_item_port.item_done();
    end
  endtask
endclass