module demux1to
#(parameter N = 2)
(
	input wire [N-1 : 0] sel,
	input wire in,
	output reg [0 : (1<<N)-1] out
);

   always @(*) begin
      out = 0;
      out[sel] = in;
   end

endmodule