class basic_test extends uvm_test;
  `uvm_component_utils(basic_test)

  stream_env env;

  function new(string name = "basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = stream_env::type_id::create("env", this);
    uvm_top.set_timeout(100us, 0);
  endfunction

  task run_phase(uvm_phase phase);
    wr_seq wseq;
    rd_seq rseq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);

    wseq = wr_seq::type_id::create("wseq");
    rseq = rd_seq::type_id::create("rseq");
    wseq.num_items  = 20;
    rseq.num_cycles = 100;

    fork
      wseq.start(env.wr_agt.sqr);
      rseq.start(env.rd_agt.sqr);
    join

    phase.drop_objection(this);
  endtask
endclass