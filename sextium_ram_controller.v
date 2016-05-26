module sextium_ram_controller(
	input clock,
	input reset,
	input [15:0] addr_bus,
	output [15:0] mem_bus_in,
	input [15:0] mem_bus_out,
	input mem_read,
	input mem_write,
	output reg mem_ack,
	input clock_b,
	input [15:0] address_b,
	input [15:0] data_b,
	output [15:0] q_b,
	input wren_b,
	input enable_b,
	input [1:0] byteena_b
);

	initial mem_ack = 0;

	always @(posedge clock or negedge reset) 
	begin
		if (~reset) mem_ack <= 0;
		else mem_ack <= (mem_read | mem_write) & ~mem_ack;
	end

	sextium_ram memory(.clock_a(clock), .data_a(mem_bus_out), .q_a(mem_bus_in),
		.address_a(addr_bus), .wren_a(mem_write),
		.clock_b(clock_b), .data_b(data_b), .q_b(q_b), .enable_b(enable_b),
		.address_b(address_b), .wren_b(wren_b));

endmodule