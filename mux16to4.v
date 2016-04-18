module mux16to4
(
   input [15:0] in,
	input [1:0] sel,
	output reg [3:0] out
);

	always @(*)
	begin
		case(sel)
			3: out = in[0+:4];
			2: out = in[4+:4];
			1: out = in[8+:4];
			0: out = in[12+:4];
		endcase
	end

endmodule