`define ST_DECODE 0
`define ST_HALT 1
`define ST_WAITACK 2
`define ST_WAITREADY 3
`define SYSCALL_HALT 0
`define SYSCALL_LOAD 1
`define SYSCALL_STORE 2
`define SYSCALL_FRAME_GET 3
`define SYSCALL_FRAME_PUT 4
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
	output acc_write,
	output selframe
);

	reg [1:0] state;
	
	reg io_read_reg, io_write_reg, selframe_reg;
	
	assign io_read = runio & ((state == `ST_DECODE) ? acc == `SYSCALL_LOAD : io_read_reg);
	assign io_write = runio & ((state == `ST_DECODE) ? acc == `SYSCALL_STORE : io_write_reg);
	assign acc_write = runio & io_read_reg;
	assign selframe = (state == `ST_DECODE) ? acc == `SYSCALL_FRAME_GET | acc == `SYSCALL_FRAME_PUT : selframe_reg;
	
	always @(posedge clock or negedge reset)
	begin
		if(~reset) begin
			iobusy <= 1;
			state <= `ST_DECODE;
			io_read_reg <= 0;
			io_write_reg <= 0;
			selframe_reg <= 0;
		end else begin
			case(state)
				`ST_DECODE: if (runio) begin
					case(acc)
						`SYSCALL_HALT: state <= `ST_HALT;
						`SYSCALL_LOAD: begin
							io_read_reg <= 1;
							state <= `ST_WAITACK;
						end
						`SYSCALL_STORE: begin
							io_write_reg <= 1;
							state <= `ST_WAITACK;
						end
						`SYSCALL_FRAME_GET: begin
							io_read_reg <= 1;
							selframe_reg <= 1;
							state <= `ST_WAITACK;
						end
						`SYSCALL_FRAME_PUT: begin
							io_write_reg <= 1;
							selframe_reg <= 1;
							state <= `ST_WAITACK;
						end
					endcase
				end
				`ST_HALT: state <= `ST_HALT;
				`ST_WAITACK: begin
					if (ioack) begin
						io_read_reg <= 0;
						io_write_reg <= 0;
						selframe_reg <= 0;
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