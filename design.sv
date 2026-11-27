module stream_buf #(
	parameter DATA_W=32
	parameter DEPTH=16
	)
  			(input logic clk, rst_n, 
			 input logic s_valid,
			 input logic [DWIDTH-1:0] s_data,
			 input logic m_ready,
			 output logic s_ready,
			 output logic m_valid,
             output logic [DWIDTH-1:0] m_data,
             output logic [clog2(DEPTH+1):0] count
			);

logic [2:0] wptr, rptr;
logic [7:0] mem[7:0];
  
assign full=((wptr==3'b111)&(rptr==3'b000)?1:0);
assign empty=(wptr==rptr)?1:0;

  always_ff@(posedge clk or posedge rst_n)
begin
	if(rst_n)
	begin
		for(int i=0;i<8; i++)
		begin
			mem[i]<=0;
			end
		wptr<=0;
		rptr<=0;
		D_out<=0;
	end
	
	else if(wr_rd & !full)
	begin
      mem[wptr]<=D_in;
		wptr<=wptr+1;
	end
	
	else if(!wr_rd & !empty)
	begin
		D_out<=mem[rptr];
		rptr<=rptr+1;
	end
end
endmodule
				
		