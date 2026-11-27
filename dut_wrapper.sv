module dut_wrapper #(
    parameter DATA_W = 32,
    parameter DEPTH  = 16
)(DUT_intf intf);

    stream_buf #(
        .DATA_W(DATA_W),
        .DEPTH (DEPTH)
    ) DUT (
        .clk          (intf.clk),
        .rst_n        (intf.rst_n),
        .s_valid      (intf.s_valid),
        .s_data       (intf.s_data),
        .s_ready      (intf.s_ready),
        .m_ready      (intf.m_ready),
        .m_valid      (intf.m_valid),
        .m_data       (intf.m_data),
        .count        (intf.count),
        .almost_full  (intf.almost_full),
        .almost_empty (intf.almost_empty)
    );

endmodule