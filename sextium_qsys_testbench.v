`timescale 1 ns / 1 ns
module sextium_qsys_testbench;

	reg clock = 0;
	reg reset = 0;
	wire mem_read, mem_write, mem_ack, io_read, io_write, ioack;
	wire [15:0] mem_bus_in, mem_bus_out, addr_bus, io_bus, io_bus_in, io_bus_out;
	wire [20:0] tcm_address_out;
	wire [19:0] SRAM_ADDR; 
	wire [15:0] SRAM_DQ; 
	wire SRAM_OE_N, SRAM_WE_N, SRAM_LB_N, SRAM_UB_N;

	assign io_bus_in = io_bus;
	assign io_bus = io_write ? io_bus_out : 16'bZ;
	
	assign SRAM_ADDR = tcm_address_out[20:1];

	sextium_core core(.clock(clock), .reset(reset), .ioack(ioack), .io_bus_in(io_bus_in), .io_bus_out(io_bus_out),
		.mem_bus_in(mem_bus_in), .mem_bus_out(mem_bus_out), .addr_bus(addr_bus), .mem_ack(mem_ack),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write));
	
//	simulated_memory mem(.read(mem_read), .write(mem_write), .addr(addr_bus), 
//		.data_in(mem_bus_in), .data_out(mem_bus_out), .ack(mem_ack));

	simulated_sram sram(.Address(SRAM_ADDR), .DataIO(SRAM_DQ), .OE_n(SRAM_OE_N), .CE_n(0), .WE_n(SRAM_WE_N),
		.LB_n(SRAM_LB_N), .UB_n(SRAM_UB_N));
	
	simulated_io io(.reset(reset), .io_read(io_read), .io_write(io_write), .ioack(ioack), .data(io_bus));
	
	sextium_sys sys
	(
/*		.character_lcd_external_interface_DATA(LCD_DATA),
		.character_lcd_external_interface_ON(LCD_ON),
		.character_lcd_external_interface_BLON(LCD_BLON),
		.character_lcd_external_interface_EN(LCD_EN),
		.character_lcd_external_interface_RS(LCD_RS),
		.character_lcd_external_interface_RW(LCD_RW),*/
		.sextium_mem_addr_bus(addr_bus),
		.sextium_mem_mem_bus_in(mem_bus_in),
		.sextium_mem_mem_bus_out(mem_bus_out),
		.sextium_mem_mem_read(mem_read),
		.sextium_mem_mem_write(mem_write),
		.sextium_mem_mem_ack(mem_ack),
/*		.sram_SRAM_DQ(SRAM_DQ),
		.sram_SRAM_ADDR(SRAM_ADDR),
		.sram_SRAM_LB_N(SRAM_LB_N),
		.sram_SRAM_UB_N(SRAM_UB_N),
		.sram_SRAM_OE_N(SRAM_OE_N),
		.sram_SRAM_WE_N(SRAM_WE_N), */
/*		.sram_bridge_tcm_address_out(tcm_address_out),
		.sram_bridge_tcm_byteenable_n_out({SRAM_UB_N, SRAM_LB_N}),
		.sram_bridge_tcm_outputenable_n_out(SRAM_OE_N),
//		.sram_bridge_tcm_begintransfer_n_out(SRAM_),
		.sram_bridge_tcm_write_n_out(SRAM_WE_N),
		.sram_bridge_tcm_data_out(SRAM_DQ),
//		.sram_bridge_tcm_chipselect_n_out(SRAM_CE_N),*/
		.clk_clk(clock),
		.reset_reset_n(reset),
		.slow_clk_clk(clock),
		.slow_reset_reset_n(reset)
	);
	
	always begin
		#20 clock <= ~clock;
	end
	
	initial begin
		reset = 0;
		#60 reset = 1;
		#10000 $stop;
	end

endmodule