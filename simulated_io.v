module simulated_io
(
	input io_read,
	input io_write,
	output ioack,
	inout [15:0] data
);

	reg [15:0] inputs[65535:0];
	reg [15:0] outputs[65535:0];
	
	reg [15:0] inaddr, outaddr;

	assign data = (io_read) ? inputs[inaddr] : 16'bZ;
	assign ioack = io_read | io_write;
	
	initial begin
		inaddr <= 0;
		outaddr <= 0;
	end
	
	always @(negedge io_read)
	begin
		inaddr <= inaddr + 1;
	end
	
	always @(posedge io_write or negedge io_write)
	begin
		if (io_write) begin
			outputs[outaddr] <= data;
		end 
		else outaddr <= outaddr + 1;
	end
	
endmodule