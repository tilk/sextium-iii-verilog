module mux2
#(parameter WIDTH = 1)
(
	input sel,
	input [WIDTH-1:0] in1,
	input [WIDTH-1:0] in2,
	output reg [WIDTH-1:0] out
);

	always @(*)
	begin
		case(sel)
			0: out = in1;
			1: out = in2;
		endcase
	end

endmodule