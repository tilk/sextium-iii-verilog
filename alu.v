module alu
#(parameter WIDTH=16)
(
	input clock,
	input diven,
	input signed [WIDTH-1:0] dataa,
	input signed [WIDTH-1:0] datab,
	input [2:0] s,
	output reg signed [WIDTH-1:0] result
);

	wire [WIDTH-1:0] qu, re;

`ifdef IVERILOG
    assign qu = datab / dataa;
    assign re = datab % dataa;
`else
	divider divcircuit(.clock(clock), .clken(diven), .numer(datab), .denom(dataa), .quotient(qu), .remain(re));
`endif

	always @(*)
	begin
	   case(s)
		3'b000: result = dataa + datab;
		3'b001: result = dataa - datab;
		3'b010: result = dataa * datab; 
		3'b011: result = qu;
		3'b100: if (datab < 1'sb0) result = dataa >>> $unsigned(-datab); else result = dataa <<< $unsigned(datab);
		3'b101: result = ~(dataa & datab);
		default: result = 0;
		endcase
	end

endmodule
