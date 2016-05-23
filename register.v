module register
#(parameter WIDTH=16)
(
	input clock,
	input reset,
	input write,
   input [WIDTH-1:0] indata,
	output reg [WIDTH-1:0] outdata
);

	always @(posedge clock or negedge reset)
	begin
		if (~reset)
			outdata <= 0;
		else
		if (write)
			outdata <= indata;
	end
	
endmodule