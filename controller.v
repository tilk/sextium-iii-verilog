// states
`define START 0
`define IOWAIT 1
`define DECODE 2
`define NEXTINSN 3
`define DIVWAIT 5
// instructions
`define NOP 0
`define SYSCALL 1
`define LOAD 2
`define STORE 3
`define SWAPA 4
`define SWAPD 5
`define BRANCHZ 6
`define BRANCHN 7
`define JUMP 8
`define CONST 9
`define ADD 10
`define SUB 11
`define MUL 12
`define DIV 13
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
	output reg [1:0] aluinsn,
	output reg runio,
	output reg diven
);

	reg [2:0] state; //, nextstate;
	reg [2:0] delay;

	// accumulator logic
	always @(*)
	begin
		selacc = `SELACC_MEM;
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
				endcase
		endcase
	end
	
	// swap logic
	always @(*)
	begin
		selswap = `SELSWAP_AR;
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
		seladdr = `SELADDR_PC;
		casez(state)
			`START: begin mem_read = 1; seladdr = `SELADDR_PC; end
			`DECODE:
				casez(insn)
					`LOAD: begin mem_read = 1; seladdr = `SELADDR_AR; end
					`STORE: begin mem_write <= 1; seladdr <= `SELADDR_AR; end
					`CONST: begin mem_read = 1; seladdr = `SELADDR_PC; end
				endcase
		endcase
	end
	
	// ALU logic
	always @(*)
	begin
		aluinsn = 0;
		casez(state)
			`DIVWAIT: aluinsn = 3;
			`DECODE:
				casez(insn)
					`ADD: aluinsn = 0;
					`SUB: aluinsn = 1;
					`MUL: aluinsn = 2;
					`DIV: aluinsn = 3;
				endcase
		endcase
	end
	
	// PC logic
	always @(*)
	begin
		selpc1 = `SELPC1_NEXT;
		pc_write = 0;
		casez(state)
			`START: begin pc_write = 1; selpc1 = `SELPC1_NEXT; end
			`DECODE:
				casez(insn)
					`BRANCHZ: if (accz) begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_AR; end
					`BRANCHN: if (accn) begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_AR; end
					`JUMP: begin pc_write = 1; selpc1 = `SELPC1_REG; selpc2 = `SELPC2_ACC; end
					`CONST: begin pc_write = 1; selpc1 = `SELPC1_NEXT; end
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
	
	// nextstate logic
/*	always @(*)
	begin
		casez(state)
			`START: if(mem_ack) nextstate = `DECODE; else nextstate = `START;
			`IOWAIT: if(iobusy) nextstate = `IOWAIT; else if (curinsn == 0) nextstate = `START; else nextstate = `DECODE;
			`DIVWAIT: if(delay[0] != 0) nextstate = `DIVWAIT; else if (curinsn == 0) nextstate = `START; else nextstate = `DECODE;
			`DECODE: begin
				if (curinsn == 3) nextstate = `START;
				else nextstate = `DECODE;
				casez(insn)
					`SYSCALL: nextstate = `IOWAIT;
					
				endcase
			end
		endcase
	end*/
	
	always @(posedge clock)
	begin
		if(~reset) begin
			state <= 0;
			curinsn <= 0;
			diven <= 1; // TODO
		end else
		casez(state)
			`START: begin
				curinsn <= 0;
				if (mem_ack) state <= `DECODE;
			end
			`IOWAIT: begin 
				if(~iobusy) begin
					if(curinsn == 0) state <= `START;
					else state <= `DECODE;
				end
			end
			`DECODE: begin
				if(curinsn == 3) state <= `START;
				else state <= `DECODE;
				curinsn <= curinsn + 2'b1;
				casez(insn)
					`SYSCALL: state <= `IOWAIT;
					`LOAD: if(~mem_ack) begin curinsn <= curinsn; state <= `DECODE; end
					`STORE: if(~mem_ack) begin curinsn <= curinsn; state <= `DECODE; end
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
					if(curinsn == 0) state <= `START;
					else state <= `DECODE;
				end else begin
					delay <= delay >> 1;
				end
			end
		endcase
	end
	
endmodule