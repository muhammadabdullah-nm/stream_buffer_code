class basic_test extends uvm_test;
  `uvm_component_utils(basic_test)

  stream_env env;

  int unsigned testnumber = 5;   // default test; override with +TESTNUM=<n>

  function new(string name = "basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = stream_env::type_id::create("env", this);
    void'($value$plusargs("TESTNUM=%d", testnumber));
    uvm_top.set_timeout(1ms, 0);
    `uvm_info("TEST", $sformatf("Running testnumber = %0d", testnumber), UVM_NONE)
  endfunction

  // ---------------------------------------------------------------
  // helper tasks: run one write sequence / one read sequence
  // ---------------------------------------------------------------
  task run_wr(int unsigned n);
    wr_seq wseq = wr_seq::type_id::create("wseq");
    wseq.num_items = n;
    wseq.start(env.wr_agt.sqr);
  endtask

  task run_rd(int unsigned n);
    rd_seq rseq = rd_seq::type_id::create("rseq");
    rseq.num_cycles = n;
    rseq.start(env.rd_agt.sqr);
  endtask

  // ---------------------------------------------------------------
  // tests
  // ---------------------------------------------------------------

    //  m_ready toggles 200 cycles high, then 200 cycles low
  task read_ready_toggle();
    rd_when_ready_toggle rseq = rd_when_ready_toggle::type_id::create("rseq");
    fork
      run_wr(20);
      rseq.start(env.rd_agt.sqr);
    join
  endtask
  
    
  // write bursts (5 writes, 50 idle cycles, 5 writes) with m_ready toggling 200 high / 200 low
  task write_back_to_back();
    wr_burst_seq         wseq = wr_burst_seq::type_id::create("wseq");
    rd_when_ready_toggle rseq = rd_when_ready_toggle::type_id::create("rseq");
    fork
      wseq.start(env.wr_agt.sqr);
      rseq.start(env.rd_agt.sqr);
    join
  endtask
  
  task full_empty_flag();
    rd_empty_seq r1 = rd_empty_seq::type_id::create("r1");
    wr_fill_seq  w  = wr_fill_seq ::type_id::create("w");
    rd_drain_seq r2 = rd_drain_seq::type_id::create("r2");

    r1.start(env.rd_agt.sqr);   // reads while empty: nothing happens
    w.start(env.wr_agt.sqr);    // fill to full, m_ready low
    #100ns;                     // sit full for a while
    r2.start(env.rd_agt.sqr);   // drain back to empty
  endtask
  
    // keep writing till full, with no reads (do extra writes get accepted?)
  task keep_writing();
    wr_keep_writing_seq w  = wr_keep_writing_seq::type_id::create("w");
    rd_hold_low_seq     r1 = rd_hold_low_seq    ::type_id::create("r1");
    rd_drain_seq        r2 = rd_drain_seq       ::type_id::create("r2");

    fork
      w.start(env.wr_agt.sqr);
      begin
        r1.start(env.rd_agt.sqr);   // m_ready low: buffer fills and stays full
        r2.start(env.rd_agt.sqr);   // then drain so the stuck writes finish
      end
    join
  endtask

    // almost_full / almost_empty flag test
  task toggle_almost();
    wr_almost_full_seq  w1 = wr_almost_full_seq ::type_id::create("w1");
    rd_almost_empty_seq r1 = rd_almost_empty_seq::type_id::create("r1");
    wr_to_count_seq     w2 = wr_to_count_seq    ::type_id::create("w2");
    rd_one_read_seq     r2 = rd_one_read_seq    ::type_id::create("r2");
    wr_fill_seq         w3 = wr_fill_seq        ::type_id::create("w3");
    rd_drain_seq        r3 = rd_drain_seq       ::type_id::create("r3");

    w3.depth = 1;                // wr_fill_seq with depth 1 = a single write
    w2.target = 3;

    w1.start(env.wr_agt.sqr);    // 1. write until almost_full
    r1.start(env.rd_agt.sqr);    // 2. read until almost_empty
    w2.start(env.wr_agt.sqr);    // 3. raise count to 3 (just above the almost_empty threshold)
    repeat (10) begin            // 4. one read, one write, repeated
      r2.start(env.rd_agt.sqr);
      w3.start(env.wr_agt.sqr);
    end
    r3.start(env.rd_agt.sqr);    // 5. drain so the scoreboard sees every item read
  endtask
  // ---------------------------------------------------------------
  // run_phase: pick the test
  // ---------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);

    case (testnumber)
      1:        read_ready_toggle();
      2: 		write_back_to_back();
      3: 		full_empty_flag();
      4: 		keep_writing();
      5: 		toggle_almost();
      default: `uvm_error("TEST", $sformatf("Invalid testnumber %0d", testnumber))
    endcase

    phase.drop_objection(this);
  endtask
endclass