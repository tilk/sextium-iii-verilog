module sextium_ram_avalon(
	input [15:0] address,
	input [1:0] byteenable,
	input chipselect,
	input clk,
	input clken,
	input reset,
	input reset_req,
	input write,
	input [15:0] writedata,
	output [15:0] readdata,
	
	output [15:0] mem_address,
	output [1:0] mem_byteena,
	output mem_clock,
	output mem_clocken,
	output [15:0] mem_data,
	input [15:0] mem_q,
	output mem_wren
);

	assign mem_address = address;
	assign mem_byteena = byteenable;
	assign mem_clock = clk;
	assign mem_clocken = clken & ~reset_req;
	assign mem_data = writedata;
	assign mem_wren = chipselect & write;
	assign readdata = mem_q;

endmodule