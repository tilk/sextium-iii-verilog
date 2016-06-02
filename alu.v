module alu
#(parameter WIDTH=16)
(
	input clock,
	input diven,
	input signed [WIDTH-1:0] dataa,
	input signed [WIDTH-1:0] datab,
	input [2:0] s,
	output reg [WIDTH-1:0] result
);

	wire [WIDTH-1:0] qu, re;

	divider divcircuit(.clock(clock), .clken(diven), .numer(datab), .denom(dataa), .quotient(qu), .remain(re));

	always @(*)
	begin
	   case(s)
		3'b000: result = dataa + datab;
		3'b001: result = dataa - datab;
		3'b010: result = dataa * datab; 
		3'b011: result = qu;
		3'b100: if (datab >= 0) result = dataa <<< datab; else result = dataa >>> -datab;
		3'b101: result = ~(dataa & datab);
		default: result = 0;
		endcase
	end

endmodule
