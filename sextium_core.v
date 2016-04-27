module sextium_core
(
   input clock,
   input reset,
	input ioack,
	input mem_ack,
   input [15:0] io_bus_in,
   input [15:0] mem_bus_in,
   output [15:0] io_bus_out,
   output [15:0] mem_bus_out,
   output [15:0] addr_bus,
	output mem_read,
	output mem_write,
	output io_read,
	output io_write,
	// for visualization
	output [3:0] insn
);

	wire acc_write, io_acc_write, ar_write, dr_write, ir_write, pc_write;
	wire [15:0] acc_in, acc_out, ar_in, ar_out, dr_in, dr_out, ir_in, ir_out, pc_in, pc_out, alu_out, swap_out;
	wire [15:0] pc_next, pc_src;
	wire accz, accn, runio, iobusy;

	wire seladdr, selswap, doswap, selpc1, selpc2;
	wire [1:0] selacc;
	wire [1:0] curinsn;
	wire [1:0] aluinsn;
	wire diven;
	
	assign ar_in = acc_out;
	assign dr_in = acc_out;
	assign ir_in = mem_bus_in;
	
	assign mem_bus_out = acc_out;
	assign io_bus_out = dr_out;
		
	assign pc_next = pc_out + 16'h1;
	
	assign accz = acc_out == 16'h0;
	assign accn = acc_out[15];
	
	register acc_register(.clock(clock), .reset(reset), .write(io_acc_write | acc_write), .indata(acc_in), .outdata(acc_out));
	register ar_register(.clock(clock), .reset(reset), .write(ar_write), .indata(ar_in), .outdata(ar_out));
	register dr_register(.clock(clock), .reset(reset), .write(dr_write), .indata(dr_in), .outdata(dr_out));
	register ir_register(.clock(clock), .reset(reset), .write(ir_write), .indata(ir_in), .outdata(ir_out));
	register pc_register(.clock(clock), .reset(reset), .write(pc_write), .indata(pc_in), .outdata(pc_out));
	
	controller sextium_controller(.clock(clock), .reset(reset), .insn(insn), .accz(accz), .accn(accn), .iobusy(iobusy),
		.mem_read(mem_read), .mem_write(mem_write), .ir_write(ir_write), .pc_write(pc_write), .acc_write(acc_write),
		.seladdr(seladdr), .selacc(selacc), .selswap(selswap), .doswap(doswap), .selpc1(selpc1), .selpc2(selpc2), 
		.curinsn(curinsn), .aluinsn(aluinsn), .runio(runio), .diven(diven), .mem_ack(mem_ack));
	
	iocontroller sextium_iocontroller(.clock(clock), .reset(reset), .runio(runio), .acc(acc_out), .ioack(ioack),
		.iobusy(iobusy), .io_read(io_read), .io_write(io_write), .acc_write(io_acc_write));
	
	mux16to4 insn_mux(.in(ir_out), .sel(curinsn), .out(insn));
	
	mux2#(16) pc_mux1(.sel(selpc1), .in1(pc_next), .in2(pc_src), .out(pc_in));
	
	mux2#(16) pc_mux2(.sel(selpc2), .in1(ar_out), .in2(acc_out), .out(pc_src));
	
	mux2#(16) addr_mux(.sel(seladdr), .in1(pc_out), .in2(ar_out), .out(addr_bus));
	
	mux2#(16) swap_mux(.sel(selswap), .in1(ar_out), .in2(dr_out), .out(swap_out));
	
	mux4#(16) acc_mux(.sel(selacc), .in1(mem_bus_in), .in2(io_bus_in), .in3(swap_out), .in4(alu_out), .out(acc_in));
	
	demux1to#(1) swap_demux(.sel(selswap), .in(doswap), .out({ar_write, dr_write}));
	
	alu sextium_alu(.diven(diven), .clock(clock), .dataa(acc_out), .datab(dr_out), .s(aluinsn), .result(alu_out));

endmodule