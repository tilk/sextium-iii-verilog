`timescale 1 ns / 1 ns
module simulated_memory
#(parameter memdata = "test2.txt")
(
	input read,
	input write,
	input [15:0] addr,
	input [15:0] data_out,
	output [15:0] data_in,
	output ack
);

	reg [15:0] contents[65535:0];
	wire dread;
	
	assign data_in = dread ? contents[addr] : 16'bX;
	
	assign #5 dread = read;
	assign #5 ack = read | write;
	
	initial begin
		$readmemh(memdata, contents);
	end
	
	always @(posedge write)
	begin
		if (write) contents[addr] <= #5 data_out;
	end
	
endmodule