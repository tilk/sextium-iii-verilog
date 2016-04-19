`define ST_DECODE 0
`define ST_HALT 1
`define ST_WAITACK 2
`define ST_WAITREADY 3
`define SYSCALL_HALT 0
`define SYSCALL_LOAD 1
`define SYSCALL_STORE 2
module iocontroller
(
	input clock,
	input reset,
	input runio,
	input [15:0] acc,
	input ioack,
	output reg iobusy,
	output reg io_read,
	output reg io_write,
	output reg acc_write
);

	reg [1:0] state;

	always @(posedge clock)
	begin
		if(~reset) begin
			iobusy <= 1;
			state <= `ST_DECODE;
			io_read <= 0;
			io_write <= 0;
			acc_write <= 0;
		end else begin
			case(state)
				`ST_DECODE: if (runio) begin
					case(acc)
						`SYSCALL_HALT: state <= `ST_HALT;
						`SYSCALL_LOAD: begin
							io_read <= 1;
							acc_write <= 1;
							state <= `ST_WAITACK;
						end
						`SYSCALL_STORE: begin
							io_write <= 1;
							state <= `ST_WAITACK;
						end
					endcase
				end
				`ST_HALT: state <= `ST_HALT;
				`ST_WAITACK: begin
					if (ioack) begin
						io_read <= 0;
						io_write <= 0;
						acc_write <= 0;
						iobusy <= 0;
						state <= `ST_WAITREADY;
					end
				end
				`ST_WAITREADY: begin
					iobusy <= 1;
					if (~ioack) state <= `ST_DECODE;
				end
			endcase
		end
	end

endmodule