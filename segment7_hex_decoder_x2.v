module segment7_hex_decoder_x2
(
	input oe,
	input [7:0] hex,
	output [6:0] out1,
	output [6:0] out2
);

	segment7_hex_decoder dec1(.oe(oe), .hex(hex[3:0]), .out(out1));
	segment7_hex_decoder dec2(.oe(oe), .hex(hex[7:4]), .out(out2));

endmodule