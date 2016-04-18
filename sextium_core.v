module sextium_core
(
   input clock,
   input reset,
	input ioack,
   inout [15:0] io_bus,
   inout [15:0] mem_bus,
   output [15:0] addr_bus,
	output mem_read,
	output mem_write,
	output io_read,
	output io_write
);

	wire acc_write, io_acc_write, ar_write, dr_write, ir_write, ip_write;
	wire [15:0] acc_in, acc_out, ar_in, ar_out, dr_in, dr_out, ir_in, ir_out, ip_in, ip_out, alu_out, swap_out;
	wire [15:0] ip_next, ip_src;
	wire accz, accn, runio, iobusy;

	wire [3:0] insn;
	wire seladdr, selswap, doswap, selip1, selip2;
	wire [1:0] selacc;
	wire [1:0] curinsn;
	wire [1:0] aluinsn;
	
	assign ar_in = acc_out;
	assign dr_in = acc_out;
	assign ir_in = mem_bus;
	
	assign mem_bus = mem_write ? acc_out : 16'bZ;
	assign io_bus = io_write ? acc_out : 16'bZ;
	
	assign ip_next = ip_out + 16'h1;
	
	assign accz = acc_out == 16'h0;
	assign accn = acc_out[15];
	
	register acc_register(.clock(clock), .reset(reset), .write(io_acc_write | acc_write), .indata(acc_in), .outdata(acc_out));
	register ar_register(.clock(clock), .reset(reset), .write(ar_write), .indata(ar_in), .outdata(ar_out));
	register dr_register(.clock(clock), .reset(reset), .write(dr_write), .indata(dr_in), .outdata(dr_out));
	register ir_register(.clock(clock), .reset(reset), .write(ir_write), .indata(ir_in), .outdata(ir_out));
	register ip_register(.clock(clock), .reset(reset), .write(ip_write), .indata(ip_in), .outdata(ip_out));
	
	controller sextium_controller(.clock(clock), .reset(reset), .insn(insn), .accz(accz), .accn(accn), .iobusy(iobusy),
		.mem_read(mem_read), .mem_write(mem_write), .ir_write(ir_write), .ip_write(ip_write), .acc_write(acc_write),
		.seladdr(seladdr), .selacc(selacc), .selswap(selswap), .doswap(doswap), .selip1(selip1), .selip2(selip2), 
		.curinsn(curinsn), .aluinsn(aluinsn), .runio(runio));
	
	iocontroller sextium_iocontroller(.clock(clock), .reset(reset), .runio(runio), .acc(acc_out), .ioack(ioack),
		.iobusy(iobusy), .io_read(io_read), .io_write(io_write), .acc_write(io_acc_write));
	
	mux16to4 insn_mux(.in(ir_out), .sel(curinsn), .out(insn));
	
	mux2#(16) ip_mux1(.sel(selip1), .in1(ip_next), .in2(ip_src), .out(ip_in));
	
	mux2#(16) ip_mux2(.sel(selip2), .in1(ar_out), .in2(acc_out), .out(ip_src));
	
	mux2#(16) addr_mux(.sel(seladdr), .in1(ip_out), .in2(ar_out), .out(addr_bus));
	
	mux2#(16) swap_mux(.sel(selswap), .in1(ar_out), .in2(dr_out), .out(swap_out));
	
	mux4#(16) acc_mux(.sel(selacc), .in1(mem_bus), .in2(io_bus), .in3(swap_out), .in4(alu_out), .out(acc_in));
	
	demux1to#(1) swap_demux(.sel(selswap), .in(doswap), .out({ar_write, dr_write}));
	
	alu sextium_alu(.dataa(acc_out), .datab(dr_out), .s(aluinsn), .result(alu_out));

endmodule