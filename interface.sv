interface DUT_intf #(
    parameter DATA_W = 32,
    parameter DEPTH  = 16
)(input logic clk, rst_n);

    localparam CNT_W = $clog2(DEPTH+1);

    // Slave (write) side
    logic              s_valid;
    logic [DATA_W-1:0] s_data;
    logic              s_ready;

    // Master (read) side
    logic              m_ready;
    logic              m_valid;
    logic [DATA_W-1:0] m_data;

    logic [CNT_W:0]    count;          
    logic              almost_full;   
    logic              almost_empty;   
  
    logic              overflow;
    logic              underflow;
    logic              clr_err = 1'b0;

    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output s_valid;
        output s_data;
        input  s_ready;
        output m_ready;
        input  m_valid;
        input  m_data;
        input  count;
        output clr_err;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input s_valid;
        input s_data;
        input s_ready;
        input m_ready;
        input m_valid;
        input m_data;
        input count;
        input almost_full;             
        input almost_empty;    
      	input overflow;
        input underflow;
    endclocking

endinterface