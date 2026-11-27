package stream_buf_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  parameter int DATA_W = 32;

  `include "wr_item.sv"
  `include "rd_item.sv"
  `include "wr_sequencer.sv"
  `include "rd_sequencer.sv"
  `include "wr_driver.sv"
  `include "rd_driver.sv"
  `include "wr_monitor.sv"
  `include "rd_monitor.sv"
  `include "wr_agent.sv"
  `include "rd_agent.sv"
  `include "wr_seq.sv"
  `include "rd_seq.sv"
  `include "stream_scoreboard.sv"
  `include "stream_env.sv"
  `include "basic_test.sv"
endpackage