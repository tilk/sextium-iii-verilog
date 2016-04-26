// states
`define START 0
`define IOWAIT 1
`define DECODE 2
`define NEXTINSN 3
`define WAIT 4
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

	reg [2:0] state;
	reg [2:0] delay;

	always @(posedge clock)
	begin
		if(~reset) begin
			state <= 0;
			mem_read <= 0;
			mem_write <= 0;
			ir_write <= 0;
			pc_write <= 0;
			acc_write <= 0;
			seladdr <= 0;
			curinsn <= 0;
			selswap <= 0;
			doswap <= 0;
			runio <= 0;
			diven <= 1; // TODO
		end else
		casez(state)
			`START: begin
				mem_read <= 1;
				ir_write <= 1;
				seladdr <= `SELADDR_PC;
				pc_write <= 1;
				selpc1 <= `SELPC1_NEXT;
				curinsn <= 0;
				state <= `WAIT;
			end
			`IOWAIT: begin 
				if(~iobusy) begin
					state <= `NEXTINSN;
					runio <= 0;
				end
			end
			`WAIT: begin
				mem_read <= 0;
				ir_write <= 0;
				pc_write <= 0;
				state <= `DECODE;
			end
			`DECODE: begin
				casez(insn)
					`NOP: state <= `NEXTINSN;
					`SYSCALL: begin
						state <= `IOWAIT;
						runio <= 1;
						selacc <= `SELACC_IO;
					end
					`LOAD: begin
						mem_read <= 1;
					   acc_write <= 1;
						selacc <= `SELACC_MEM;
						seladdr <= `SELADDR_AR;
						state <= `NEXTINSN;
					end
					`STORE: begin
						mem_write <= 1;
						seladdr <= `SELADDR_AR;
						state <= `NEXTINSN;
					end
					`SWAPA: begin
						acc_write <= 1;
						selacc <= `SELACC_SWAP;
						selswap <= `SELSWAP_AR;
						doswap <= 1;
						state <= `NEXTINSN;
					end
					`SWAPD: begin
						acc_write <= 1;
						selacc <= `SELACC_SWAP;
						selswap <= `SELSWAP_DR;
						doswap <= 1;
						state <= `NEXTINSN;
					end
					`BRANCHZ: begin
						if(accz) begin
							pc_write <= 1;
							selpc1 <= `SELPC1_REG;
							selpc2 <= `SELPC2_AR;
							curinsn <= 3;
						end
						state <= `NEXTINSN;
					end
					`BRANCHN: begin
						if(accn) begin
							pc_write <= 1;
							selpc1 <= `SELPC1_REG;
							selpc2 <= `SELPC2_AR;
							curinsn <= 3;
						end
						state <= `NEXTINSN;
					end
					`JUMP: begin
						pc_write <= 1;
						selpc1 <= `SELPC1_REG;
						selpc2 <= `SELPC2_ACC;
						curinsn <= 3;
						state <= `NEXTINSN;
					end
					`CONST: begin
						mem_read <= 1;
						acc_write <= 1;
						selacc <= `SELACC_MEM;
						seladdr <= `SELADDR_PC;
						pc_write <= 1;
						selpc1 <= `SELPC1_NEXT;
						state <= `NEXTINSN;
					end
					`ADD: begin
					   aluinsn <= 0;
						acc_write <= 1;
						selacc <= `SELACC_ALU;
						state <= `NEXTINSN;
					end
					`SUB: begin
					   aluinsn <= 1;
						acc_write <= 1;
						selacc <= `SELACC_ALU;
						state <= `NEXTINSN;
					end
					`MUL: begin
					   aluinsn <= 2;
						acc_write <= 1;
						selacc <= `SELACC_ALU;
						state <= `NEXTINSN;
					end
					`DIV: begin
					   aluinsn <= 3;
						delay <= 3'b111;
						selacc <= `SELACC_ALU;
						state <= `DIVWAIT;
					end
				endcase
			end
			`DIVWAIT: begin
				if(delay[0] == 0) begin
					acc_write <= 1;
					state <= `NEXTINSN;
				end else begin
					delay <= delay >> 1;
				end
			end
			`NEXTINSN: begin
			   mem_read <= 0;
				mem_write <= 0;
			   ir_write <= 0;
				pc_write <= 0;
				acc_write <= 0;
				doswap <= 0;
			   if (curinsn == 3) begin
				    state <= `START;
				end else state <= `DECODE;
			   curinsn <= curinsn + 2'b1;
			end
		endcase
	end
	
endmodule