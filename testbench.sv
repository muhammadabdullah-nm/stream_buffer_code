`timescale 1ns/1ps

`include "dut_intf.sv"
`include "dut_wrapper.sv"
`include "stream_buf_pkg.sv"

module tb_top;
  import uvm_pkg::*;
  import stream_buf_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 0;
  logic rst_n;

  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    repeat (5) @(posedge clk);
    #1 rst_n = 1;
  end

  DUT_intf    intf (clk, rst_n);
  dut_wrapper dut  (intf);

  initial begin
    uvm_config_db#(virtual DUT_intf)::set(null, "*", "vif", intf);
    run_test("basic_test");
  end
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, tb_top);   // use your top-level testbench module name
end
endmodule