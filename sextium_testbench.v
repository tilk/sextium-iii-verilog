module sextium_testbench;

	reg clock = 0;
	reg reset = 0;
	wire mem_read, mem_write, io_read, io_write, ioack;
	wire [15:0] mem_bus, mem_bus_in, mem_bus_out, addr_bus, io_bus, io_bus_in, io_bus_out;

	assign io_bus_in = io_bus;
	assign mem_bus_in = mem_bus;
	assign io_bus = io_write ? io_bus_out : 16'bZ;
	assign mem_bus = mem_write ? mem_bus_out : 16'bZ;
	
	sextium_core core(.clock(clock), .reset(reset), .ioack(ioack), .io_bus_in(io_bus_in), .io_bus_out(io_bus_out),
		.mem_bus_in(mem_bus_in), .mem_bus_out(mem_bus_out), .addr_bus(addr_bus),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write));
	
	simulated_memory mem(.mem_read(mem_read), .mem_write(mem_write), .addr(addr_bus), .data(mem_bus));
	
	simulated_io io(.reset(reset), .io_read(io_read), .io_write(io_write), .ioack(ioack), .data(io_bus));
	
	always begin
		#80 clock <= ~clock;
	end
	
	initial begin
		reset = 0;
		#250 reset = 1;
		#50000 $stop;
	end

endmodule