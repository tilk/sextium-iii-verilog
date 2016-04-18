module simulated_memory
#(parameter memdata = "test1.txt")
(
	input mem_read,
	input mem_write,
	input [15:0] addr,
	inout [15:0] data
);

	reg [15:0] contents[65535:0];
	
	assign data = mem_read ? contents[addr] : 16'bZ;
	
	initial begin
		$readmemh(memdata, contents);
	end

	always @(*) begin
		if (mem_write) contents[addr] <= data;
	end
	
endmodule