`timescale 1 ns / 1 ns
module sextium_testbench;

	reg clock = 0;
	reg reset = 0;
	wire mem_read, mem_write, mem_ack, io_read, io_write, ioack, frame_ack, frame_read, frame_write;
	wire [15:0] mem_bus_in, mem_bus_out, addr_bus, io_bus, io_bus_in, io_bus_out,
        frame_bus_in, frame_bus_out, disp_acc, disp_ar, disp_dr, disp_pc;
    wire [3:0] insn;
    wire [1:0] state;
    wire [13:0] statebits;

	sextium_core core(.clock(clock), .reset(reset), .ioack(ioack), .io_bus_in(io_bus_in), .io_bus_out(io_bus_out),
		.mem_bus_in(mem_bus_in), .mem_bus_out(mem_bus_out), .addr_bus(addr_bus), .mem_ack(mem_ack),
        .frame_bus_in(frame_bus_in), .frame_bus_out(frame_bus_out), .frame_ack(frame_ack),
        .frame_read(frame_read), .frame_write(frame_write),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write),
        .disp_acc(disp_acc), .disp_ar(disp_ar), .disp_dr(disp_dr), .disp_pc(disp_pc), .insn(insn), .state(state), .statebits(statebits));
	
	simulated_memory mem(.read(mem_read), .write(mem_write), .addr(addr_bus), 
		.data_in(mem_bus_in), .data_out(mem_bus_out), .ack(mem_ack));
	
	simulated_memory fmem(.read(frame_read), .write(frame_write), .addr(addr_bus), 
		.data_in(frame_bus_in), .data_out(frame_bus_out), .ack(frame_ack));
	
	simulated_io io(.clock(clock), .reset(reset), .io_read(io_read), .io_write(io_write), .ioack(ioack), 
        .data_in(io_bus_in), .data_out(io_bus_out));
	
	always begin
		#20 clock <= ~clock;
	end
	
	initial begin
        $monitor("mem in=%x out=%x addr=%x read=%d write=%d ack=%d io in=%x out=%x read=%d write=%d ack=%d acc=%x ar=%x dr=%x pc=%x insn=%x state=%x statebits=%b %x %x",
            mem_bus_in, mem_bus_out, addr_bus, mem_read, mem_write, mem_ack, io_bus_in, io_bus_out, io_read, io_write, ioack, disp_acc, disp_ar, disp_dr, disp_pc, insn, state, statebits,
            io.inaddr, io.outaddr);
		reset = 0;
		#60 reset = 1;
		#10000 $stop;
	end

endmodule
