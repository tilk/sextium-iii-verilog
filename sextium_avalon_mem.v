module sextium_avalon_mem
(
	input clk,
	input reset,
	
	output [31:0] address,
	output read,
	input [15:0] readdata,
	input waitrequest,
	output write,
	output [15:0] writedata,
	
	input [15:0] addr_bus,
	output mem_ack,
	output [15:0] mem_bus_in,
	input [15:0] mem_bus_out,
	input mem_read,
	input mem_write
);

	// asynchronous access
	assign address = addr_bus*2;
	assign mem_bus_in = readdata;
	assign writedata = mem_bus_out;
	assign read = mem_read;
	assign write = mem_write;
	assign mem_ack = (mem_read | mem_write) & ~waitrequest;

endmodule