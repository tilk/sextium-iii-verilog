module sextium_testbench;

	reg clock = 0;
	reg reset = 0;
	wire mem_read, mem_write, io_read, io_write;
	wire [15:0] mem_bus, addr_bus;

	sextium_core core(.clock(clock), .reset(reset), .mem_bus(mem_bus), .addr_bus(addr_bus),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write));
	
	simulated_memory mem(.mem_read(mem_read), .mem_write(mem_write), .addr(addr_bus), .data(mem_bus));
	
	always begin
		#20 clock <= ~clock;
	end
	
	initial begin
		reset = 0;
		#60 reset = 1;
		#2500 $stop;
	end

endmodule