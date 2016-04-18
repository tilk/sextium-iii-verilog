// states
`define START 0
`define IOWAIT 1
`define DECODE 2
`define NEXTINSN 3
`define WAIT 4
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
`define SELADDR_IP 0
`define SELADDR_AR 1
`define SELACC_MEM 0
`define SELACC_IO 1
`define SELACC_SWAP 2
`define SELACC_ALU 3
`define SELSWAP_AR 0
`define SELSWAP_DR 1
`define SELIP1_NEXT 0
`define SELIP1_REG 1
`define SELIP2_AR 0
`define SELIP2_ACC 1
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
	output reg ip_write,
	output reg acc_write,
	output reg seladdr, // 0 - IP, 1 - AR
	output reg [1:0] selacc,  // 0 - MEM, 1 - IO, 2 - SWAP, 3 - ALU
	output reg selswap, // 0 - AR, 1 - DR
	output reg doswap,
	output reg selip1, // 0 - next, 1 - reg
	output reg selip2, // 0 - DR, 1 - ACC
	output reg [1:0] curinsn,
	output reg [1:0] aluinsn,
	output reg runio
);

	reg [2:0] state;

	always @(posedge clock)
	begin
		if(~reset) begin
			state <= 0;
			mem_read <= 0;
			mem_write <= 0;
			ir_write <= 0;
			ip_write <= 0;
			acc_write <= 0;
			seladdr <= 0;
			curinsn <= 0;
			selswap <= 0;
			doswap <= 0;
			runio <= 0;
		end else
		casez(state)
			`START: begin
				mem_read <= 1;
				ir_write <= 1;
				seladdr <= `SELADDR_IP;
				ip_write <= 1;
				selip1 <= `SELIP1_NEXT;
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
				ip_write <= 0;
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
							ip_write <= 1;
							selip1 <= `SELIP1_REG;
							selip2 <= `SELIP2_AR;
						end
						state <= `NEXTINSN;
					end
					`BRANCHN: begin
						if(accn) begin
							ip_write <= 1;
							selip1 <= `SELIP1_REG;
							selip2 <= `SELIP2_AR;
						end
						state <= `NEXTINSN;
					end
					`JUMP: begin
						ip_write <= 1;
						selip1 <= `SELIP1_REG;
						selip2 <= `SELIP2_ACC;
						state <= `NEXTINSN;
					end
					`CONST: begin
						mem_read <= 1;
						acc_write <= 1;
						selacc <= `SELACC_MEM;
						seladdr <= `SELADDR_IP;
						ip_write <= 1;
						selip1 <= `SELIP1_NEXT;
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
						acc_write <= 1;
						selacc <= `SELACC_ALU;
						state <= `NEXTINSN;
					end
				endcase
			end
			`NEXTINSN: begin
			   mem_read <= 0;
				mem_write <= 0;
			   ir_write <= 0;
				ip_write <= 0;
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