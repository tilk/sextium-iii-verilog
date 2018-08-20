// states
`define START 0
`define IOWAIT 1
`define DECODE 2
`define DIVWAIT 3
// instructions
`define NOP 4'd0
`define SYSCALL 4'd1
`define LOAD 4'd2
`define STORE 4'd3
`define SWAPA 4'd4
`define SWAPD 4'd5
`define BRANCHZ 4'd6
`define BRANCHN 4'd7
`define JUMP 4'd8
`define CONST 4'd9
`define ADD 4'd10
`define SUB 4'd11
`define MUL 4'd12
`define DIV 4'd13
`define SHIFT 4'd14
`define NAND 4'd15
// constants for multiplexing
`define SELADDR_PC 0
`define SELADDR_AR 1
`define SELACC_MEM 0
`define SELACC_IO 1
`define SELACC_SWAP 2
`define SELACC_ALU 3
`define SELSWAP_AR 0
`define SELSWAP_DR 1
`define SELPC1_NEXT 0
`define SELPC1_REG 1
`define SELPC2_AR 0
`define SELPC2_ACC 1
module controller
(
	input clock,
	input reset,
	input [3:0] insn,
	input accz, // is ACC zero?
	input accn, // is ACC negative?
	input iobusy, // are we waiting for IO?
	input mem_ack,
	output reg mem_read,
	output reg mem_write,
	output reg ir_write,
	output reg pc_write,
	output reg acc_write,
	output reg seladdr, // 0 - PC, 1 - AR
	output reg [1:0] selacc,  // 0 - MEM, 1 - IO, 2 - SWAP, 3 - ALU
	output reg selswap, // 0 - AR, 1 - DR
	output reg doswap,
	output reg selpc1, // 0 - next, 1 - reg
	output reg selpc2, // 0 - DR, 1 - ACC
	output reg [1:0] curinsn,
	output reg [2:0] aluinsn,
	output reg runio,
	output reg diven,
	// for visualization
	output [1:0] stateout
);

	reg [1:0] state;
	
	assign stateout = state;

	reg [2:0] delay;
	reg cycwait;

	// accumulator logic
	always @(*)
	begin
		selacc = 1'bX;
		acc_write = 0;
		casez(state)
			`IOWAIT: selacc = `SELACC_IO;
			`DIVWAIT: begin selacc = `SELACC_ALU; if(delay[0] == 0) acc_write = 1; end 
			`DECODE:
				casez(insn)
					`SYSCALL: selacc = `SELACC_IO;
					`LOAD: begin selacc = `SELACC_MEM; acc_write = 1; end
					`SWAPA: begin selacc = `SELACC_SWAP; acc_write = 1; end
					`SWAPD: begin selacc = `SELACC_SWAP; acc_write = 1; end
					`CONST: begin selacc = `SELACC_MEM; acc_write = 1; end
					`ADD: begin selacc = `SELACC_ALU; acc_write = 1; end
					`SUB: begin selacc = `SELACC_ALU; acc_write = 1; end
					`MUL: begin selacc = `SELACC_ALU; acc_write = 1; end
					`DIV: selacc = `SELACC_ALU;
					`SHIFT: begin selacc = `SELACC_ALU; acc_write = 1; end
					`NAND: begin selacc = `SELACC_ALU; acc_write = 1; end
				endcase
		endcase
	end
	
	// swap logic
	always @(*)
	begin
		selswap = 1'b0;
		doswap = 0;
		casez(state)
			`DECODE:
				casez(insn)
					`SWAPA: begin selswap = `SELSWAP_AR; doswap = 1; end
					`SWAPD: begin selswap = `SELSWAP_DR; doswap = 1; end
				endcase
		endcase
	end
	
	// IR logic
	always @(*)
	begin
		ir_write = 0;
		casez(state)
			`START: ir_write = 1;
		endcase
	end
	
	// memory logic
	always @(*)
	begin
		mem_read = 0;
		mem_write = 0;
		seladdr = 1'bX;
		casez(state)
			`START: begin mem_read = 1; seladdr = `SELADDR_PC; end
			`DECODE:
				casez(insn)
					`LOAD: begin mem_read = 1; seladdr = `SELADDR_AR; end
					`STORE: begin mem_write = 1; seladdr = `SELADDR_AR; end
					`CONST: begin mem_read = 1; seladdr = `SELADDR_PC; end
					`SYSCALL: seladdr = `SELADDR_AR;
				endcase
		endcase
	end
	
	// ALU logic
	always @(*)
	begin
		aluinsn = 2'bX;
		casez(state)
			`DIVWAIT: aluinsn = 3;
			`DECODE:
				casez(insn)
					`ADD: aluinsn = 0;
					`SUB: aluinsn = 1;
					`MUL: aluinsn = 2;
					`DIV: aluinsn = 3;
					`SHIFT: aluinsn = 4;
					`NAND: aluinsn = 5;
				endcase
		endcase
	end
	
	// PC logic
	always @(*)
	begin
		selpc1 = 1'bX;
		selpc2 = 1'bX;
		pc_write = 0;
		casez(state)
			`START: if (mem_ack) begin pc_write = 1; selpc1 = `SELPC1_NEXT; end
			`DECODE:
				casez(insn)
					`BRANCHZ: if (accz) begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_AR; end
					`BRANCHN: if (accn) begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_AR; end
					`JUMP: begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_ACC; end
					`CONST: if (mem_ack) begin pc_write = 1; selpc1 = `SELPC1_NEXT; end
				endcase
		endcase
	end
	
	// IO logic
	always @(*)
	begin
		runio = 0;
		casez(state)
			`IOWAIT: if (iobusy) runio = 1;
			`DECODE: 
				casez(insn)
					`SYSCALL: runio = 1;
				endcase
		endcase
	end
	
	always @(posedge clock or negedge reset)
	begin
		if(~reset) begin
			state <= 0;
			curinsn <= 0;
			diven <= 1; // TODO
		end else
		casez(state)
			`START: begin
				curinsn <= 0;
				if(mem_ack) state <= `DECODE; 
			end
			`IOWAIT: begin 
				if(~iobusy) begin
					if(curinsn == 2'd0) state <= `START;
					else state <= `DECODE;
				end
			end
			`DECODE: begin
				if(curinsn == 2'd3) state <= `START;
				else state <= `DECODE;
				curinsn <= curinsn + 2'b1;
				casez(insn)
					`SYSCALL: state <= `IOWAIT;
					`LOAD: if(~mem_ack) begin curinsn <= curinsn; state <= `DECODE; end
					`STORE: if(~mem_ack) begin curinsn <= curinsn; state <= `DECODE; end
					`CONST: if(~mem_ack) begin curinsn <= curinsn; state <= `DECODE; end
					`BRANCHZ: if(accz) begin curinsn <= 0; state <= `START; end
					`BRANCHN: if(accn) begin curinsn <= 0; state <= `START; end
					`JUMP: begin curinsn <= 0; state <= `START; end
					`DIV: begin
						delay <= 3'b111;
						state <= `DIVWAIT;
					end
				endcase
			end
			`DIVWAIT: begin
				if(delay[0] == 0) begin
					if(curinsn == 2'd0) state <= `START;
					else state <= `DECODE;
				end else begin
					delay <= delay >> 1;
				end
			end
		endcase
	end
	
endmodule
