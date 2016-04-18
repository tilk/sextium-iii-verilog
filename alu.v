module alu
#(parameter WIDTH=16)
(
	input signed [WIDTH-1:0] dataa,
	input signed [WIDTH-1:0] datab,
	input [1:0] s,
	output reg [WIDTH-1:0] result
);

	always @(*)
	begin
	   case(s)
		2'b00: result = dataa + datab;
		2'b01: result = dataa - datab;
		2'b10: result = dataa * datab; 
		2'b11: result = dataa / datab;
		endcase
	end

endmodule
