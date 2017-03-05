`define ST_DECODE 0
`define ST_HALT 1
`define ST_WAITREADY 2
`define SYSCALL_HALT 0
`define SYSCALL_LOAD 1
`define SYSCALL_STORE 2
`define SYSCALL_FRAME_GET 3
`define SYSCALL_FRAME_PUT 4
`define SYSCALL_IO_GET 5
`define SYSCALL_IO_PUT 6
module iocontroller
(
	input clock,
	input reset,
	input runio,
	input [15:0] acc,
	input ioack,
	output reg iobusy,
	output io_read,
	output io_write,
	output io_use_addr,
	output acc_write,
	output selframe
);

	reg [1:0] state;
	
	reg [15:0] acc_copy;
	reg next;
	
	wire [15:0] syscall;
	
	assign syscall = next ? acc_copy : acc;
	assign io_read = runio & state == `ST_DECODE & (syscall == `SYSCALL_LOAD | syscall == `SYSCALL_FRAME_GET | syscall == `SYSCALL_IO_GET);
	assign io_write = runio & state == `ST_DECODE & (syscall == `SYSCALL_STORE | syscall == `SYSCALL_FRAME_PUT | syscall == `SYSCALL_IO_PUT);
	assign io_use_addr = runio & state == `ST_DECODE & (syscall == `SYSCALL_IO_GET | syscall == `SYSCALL_IO_PUT);
	assign acc_write = io_read;
	assign selframe = syscall == `SYSCALL_FRAME_GET | syscall == `SYSCALL_FRAME_PUT;
	
	always @(posedge clock or negedge reset)
	begin
		if(~reset) begin
			iobusy <= 1;
			state <= `ST_DECODE;
			next <= 0;
		end else begin
			case(state)
				`ST_DECODE: if (runio) begin
					next <= 1;
					if (~next) acc_copy <= acc;
					case(syscall)
						`SYSCALL_HALT: state <= `ST_HALT;
						default: if (ioack) begin
							iobusy <= 0;
							next <= 0;
							state <= `ST_WAITREADY;
						end
					endcase
				end
				`ST_HALT: state <= `ST_HALT;
				`ST_WAITREADY: begin
					iobusy <= 1;
					if (~ioack) state <= `ST_DECODE;
				end
			endcase
		end
	end

endmodule