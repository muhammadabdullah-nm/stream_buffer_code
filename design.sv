module stream_buf #(
	parameter DATA_W=32,
	parameter DEPTH=16
	)
  			(input  logic 			   clk, rst_n, 
			 input  logic 			   s_valid,
			 input  logic [DATA_W-1:0] s_data,
			 output logic			   s_ready,
			 input  logic 			   m_ready,
			 output logic 			   m_valid,
             output logic [DATA_W-1:0] m_data,
             output logic [$clog2(DEPTH+1):0] count
			);

  	logic [3:0] wptr, rptr;
    logic [DATA_W-1:0] mem [DEPTH-1:0]; 
	logic full, empty;
  
	assign full=(count==DEPTH)?1:0;
	assign empty=(count==0)?1:0;

	assign s_ready = !full;
	assign m_valid = (!empty)?1:0;

    always_ff@(posedge clk)
        begin
            if(!rst_n)
            begin
              	wptr <= 0;
                rptr <= 0;
                count <= 0;
              	m_data <= '0;
            end

            else if(s_valid && s_ready)
            begin
              if(count==DEPTH) wptr <= 0;
              else wptr<=wptr+1;
              	mem[wptr]<=s_data;
                count<=count+1;
            end

            else if(m_valid && m_ready)
            begin
              if(rptr == DEPTH) rptr <= 0;
              else rptr<=rptr;
                m_data<=mem[rptr];
              	rptr<=rptr+1;
                count<=count-1;
            end
        end
    endmodule
				
		