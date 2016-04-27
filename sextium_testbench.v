`timescale 1 ns / 1 ns
module sextium_testbench;

	reg clock = 0;
	reg reset = 0;
	wire mem_read, mem_write, mem_ack, io_read, io_write, ioack;
	wire [15:0] mem_bus_in, mem_bus_out, addr_bus, io_bus, io_bus_in, io_bus_out;

	assign io_bus_in = io_bus;
	assign io_bus = io_write ? io_bus_out : 16'bZ;
	
	sextium_core core(.clock(clock), .reset(reset), .ioack(ioack), .io_bus_in(io_bus_in), .io_bus_out(io_bus_out),
		.mem_bus_in(mem_bus_in), .mem_bus_out(mem_bus_out), .addr_bus(addr_bus), .mem_ack(mem_ack),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write));
	
	simulated_memory mem(.clock(clock), .read(mem_read), .write(mem_write), .addr(addr_bus), 
		.data_in(mem_bus_in), .data_out(mem_bus_out), .ack(mem_ack));
	
	simulated_io io(.reset(reset), .io_read(io_read), .io_write(io_write), .ioack(ioack), .data(io_bus));
	
	always begin
		#20 clock <= ~clock;
	end
	
	initial begin
		reset = 0;
		#60 reset = 1;
		#10000 $stop;
	end

endmodule