module segment7_hex_decoder
(
	input oe,
	input [3:0] hex,
	output reg [6:0] out
);

	always @(*)
	begin
		if(oe)
		case(hex)
			4'h0: out = ~7'b0111111;
			4'h1: out = ~7'b0000110;
			4'h2: out = ~7'b1011011;
			4'h3: out = ~7'b1001111;
			4'h4: out = ~7'b1100110;
			4'h5: out = ~7'b1101101;
			4'h6: out = ~7'b1111101;
			4'h7: out = ~7'b0000111;
			4'h8: out = ~7'b1111111;
			4'h9: out = ~7'b1101111;
			4'ha: out = ~7'b1110111;
			4'hb: out = ~7'b1111100;
			4'hc: out = ~7'b0111001;
			4'hd: out = ~7'b1011110;
			4'he: out = ~7'b1111001;
			4'hf: out = ~7'b1110001;
		endcase
		else out = ~7'b0000000;
	end

endmodule