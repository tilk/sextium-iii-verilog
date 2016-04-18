module mux4
#(parameter WIDTH = 1)
(
	input [1:0] sel,
	input [WIDTH-1:0] in1,
	input [WIDTH-1:0] in2,
	input [WIDTH-1:0] in3,
	input [WIDTH-1:0] in4,
	output reg [WIDTH-1:0] out
);

	always @(*)
	begin
		case(sel)
			0: out = in1;
			1: out = in2;
			2: out = in3;
			3: out = in4;
		endcase
	end

endmodule