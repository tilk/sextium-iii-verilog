module segment7_hex_decoder_x4
(
	input oe,
	input [15:0] hex,
	output [6:0] out1,
	output [6:0] out2,
	output [6:0] out3,
	output [6:0] out4
);

	segment7_hex_decoder dec1(.oe(oe), .hex(hex[3:0]), .out(out1));
	segment7_hex_decoder dec2(.oe(oe), .hex(hex[7:4]), .out(out2));
	segment7_hex_decoder dec3(.oe(oe), .hex(hex[11:8]), .out(out3));
	segment7_hex_decoder dec4(.oe(oe), .hex(hex[15:12]), .out(out4));

endmodule