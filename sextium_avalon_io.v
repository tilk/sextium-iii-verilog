module sextium_avalon_io
#(
	parameter READ_FIFO_ADDR = 32'h200006,
	parameter WRITE_FIFO_ADDR = 32'h200008
)
(
	input clk,
	input reset,
	
	output [31:0] address,
	output read,
	input [31:0] readdata,
	input waitrequest,
	output write,
	output [31:0] writedata,
	output [3:0] byteenable,
	
	output [15:0] io_bus_in,
	input [15:0] io_bus_out,
	input io_read,
	input io_write,
	output io_ack
);

	assign address = io_read ? READ_FIFO_ADDR : WRITE_FIFO_ADDR;
	
	assign byteenable = 4'b0011;
	
	assign read = io_read;
	assign write = io_write;
	assign writedata = io_bus_out;
	assign io_bus_in = readdata;
	assign io_ack = (io_read | io_write) & ~waitrequest;
	
endmodule