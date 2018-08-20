module simulated_io
(
    input clock,
	input reset,
	input io_read,
	input io_write,
	output ioack,
	output [15:0] data_in,
	input [15:0] data_out
);

	reg [15:0] inputs[65535:0];
	reg [15:0] outputs[65535:0];
	
	reg [15:0] inaddr, outaddr;

    reg prev_io_read, prev_io_write;

	assign data_in = (io_read) ? inputs[inaddr] : 16'bx;
	assign ioack = io_read | io_write;
	
	initial begin
		$readmemh("test2in.txt", inputs);
	end

    always @(posedge clock) begin
        prev_io_read <= io_read;
        prev_io_write <= io_write;
    end

	always @(posedge clock)
        if (~reset) inaddr <= 16'b0;
        else if (!io_read && prev_io_read)
            inaddr <= inaddr + 1;
	
	always @(posedge clock)
        if (~reset) outaddr <= 16'b0;
		else if (io_write && !prev_io_write) begin
			outputs[outaddr] <= data_out;
            outaddr <= outaddr + 1;
        end

endmodule
