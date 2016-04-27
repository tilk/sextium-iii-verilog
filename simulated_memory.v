module simulated_memory
#(parameter memdata = "test2.txt")
(
	input clock,
	input read,
	input write,
	input [15:0] addr,
	input [15:0] data_out,
	output reg [15:0] data_in,
	output reg ack
);

	reg [15:0] contents[65535:0];
	
	initial begin
		$readmemh(memdata, contents);
	end
	
	always @(posedge clock)
	begin
		ack <= 1;
		if (write) contents[addr] <= data_out;
		else if (read) data_in <= contents[addr];
		else ack <= 0;
	end
	
endmodule