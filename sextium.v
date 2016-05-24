
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module sextium(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,

	//////////// LED //////////
	output		     [8:0]		LEDG,
	output		    [17:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		    [17:0]		SW,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	output		     [6:0]		HEX6,
	output		     [6:0]		HEX7,

	//////////// LCD //////////
	output		          		LCD_BLON,
	inout 		     [7:0]		LCD_DATA,
	output		          		LCD_EN,
	output		          		LCD_ON,
	output		          		LCD_RS,
	output		          		LCD_RW,

	//////////// RS232 //////////
	input 		          		UART_CTS,
	output		          		UART_RTS,
	input 		          		UART_RXD,
	output		          		UART_TXD,

	//////////// PS2 for Keyboard and Mouse //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// SDCARD //////////
	output		          		SD_CLK,
	inout 		          		SD_CMD,
	inout 		     [3:0]		SD_DAT,
	input 		          		SD_WP_N,

	//////////// I2C for EEPROM //////////
	output		          		EEP_I2C_SCLK,
	inout 		          		EEP_I2C_SDAT,

	//////////// USB 2.0 OTG (Cypress CY7C67200) //////////
	output		     [1:0]		OTG_ADDR,
	output		          		OTG_CS_N,
	inout 		    [15:0]		OTG_DATA,
	input 		          		OTG_INT,
	output		          		OTG_RD_N,
	output		          		OTG_RST_N,
	output		          		OTG_WE_N,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [31:0]		DRAM_DQ,
	output		     [3:0]		DRAM_DQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_WE_N,

	//////////// SRAM //////////
	output		    [19:0]		SRAM_ADDR,
	output		          		SRAM_CE_N,
	inout 		    [15:0]		SRAM_DQ,
	output		          		SRAM_LB_N,
	output		          		SRAM_OE_N,
	output		          		SRAM_UB_N,
	output		          		SRAM_WE_N,

	//////////// Flash //////////
	output		    [22:0]		FL_ADDR,
	output		          		FL_CE_N,
	inout 		     [7:0]		FL_DQ,
	output		          		FL_OE_N,
	output		          		FL_RST_N,
	input 		          		FL_RY,
	output		          		FL_WE_N,
	output		          		FL_WP_N,

	// VGA
	output		     [7:0]		VGA_R,
	output		     [7:0]		VGA_G,
	output		     [7:0]		VGA_B,
	output                     VGA_CLK,
	output                     VGA_BLANK_N,
	output                     VGA_HS,
	output                     VGA_VS,
	output                     VGA_SYNC_N,
	
	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

	wire clock, reset;
	wire selclock, stepclock;
	wire mem_read, mem_write, mem_ack, frame_read, frame_write, frame_ack, io_read, io_write, io_mem_write, io_ack;
	wire [15:0] mem_bus_in, mem_bus_out, frame_bus_in, frame_bus_out, frame_addr_bus, io_bus_in, io_bus_out, addr_bus;
	wire [3:0] insn;
	wire [2:0] state;
	wire [15:0] dispval, dispreg;
	wire [15:0] dispregs[3:0];
	wire [6:0] disp7reg1, disp7reg2;

	wire ram_clock, ram_clocken, ram_wren;
	wire [15:0] ram_address, ram_data, ram_q;
	wire [1:0] ram_byteena;
	wire frame_clock, frame_clocken, frame_wren;
	wire [15:0] frame_address, frame_data, frame_q;
	wire [1:0] frame_byteena;
	
	reg [17:0] sw_syn;
	
//=======================================================
//  Structural coding
//=======================================================

	assign reset = KEY[0];
	assign selclock = sw_syn[17];

	assign LEDG[0] = clock;
	assign LEDG[2] = mem_ack;
	assign LEDG[3] = mem_read;
	assign LEDG[4] = mem_write;
	assign LEDG[5] = io_ack;
	assign LEDG[6] = io_read;
	assign LEDG[7] = io_write;

	always @(posedge CLOCK_50)
	begin
		sw_syn <= SW;
	end
	
	sextium_core core(.clock(clock), .reset(reset), .mem_bus_in(mem_bus_in), .mem_bus_out(mem_bus_out), .addr_bus(addr_bus),
		.io_bus_in(io_bus_in), .io_bus_out(io_bus_out),
		.mem_read(mem_read), .mem_write(mem_write), .mem_ack(mem_ack),
		.io_read(io_read), .io_write(io_write), .ioack(io_ack),
		.frame_read(frame_read), .frame_write(frame_write), .frame_ack(frame_ack),
		.frame_bus_in(frame_bus_in), .frame_bus_out(frame_bus_out), .frame_addr_bus(frame_addr_bus),
		.insn(insn), .state(state), .statebits(LEDR[11:0]), 
		.disp_acc(dispregs[0]), .disp_ar(dispregs[1]), .disp_dr(dispregs[2]), .disp_pc(dispregs[3]));
	
	mux2#(16) dispmux(.sel(SW[0]), .in1(addr_bus), .in2(dispreg), .out(dispval));
	mux4#(16) dispregmux(.sel({SW[1], SW[2]}), .in1(dispregs[0]), .in2(dispregs[1]), .in3(dispregs[2]), .in4(dispregs[3]), .out(dispreg));
	
	mux2#(7) disp7seg1(.sel(SW[0]), .in1(~7'b1110111), .in2(disp7reg1), .out(HEX5));
	mux2#(7) disp7seg2(.sel(SW[0]), .in1(~7'b1011110), .in2(disp7reg2), .out(HEX4));
	mux4#(7) dispreg7seg1(.sel({SW[1], SW[2]}), .in1(~7'b1110111), .in2(~7'b1110111), .in3(~7'b1011110), .in4(~7'b1110011), .out(disp7reg1));
	mux4#(7) dispreg7seg2(.sel({SW[1], SW[2]}), .in1(~7'b1011000), .in2(~7'b1010000), .in3(~7'b1010000), .in4(~7'b1011000), .out(disp7reg2));

	segment7_hex_decoder insn_s7(.oe(1), .hex(insn), .out(HEX6));
	segment7_hex_decoder state_s7(.oe(1), .hex(state), .out(HEX7));
	
	segment7_hex_decoder_x4 addr_s7(.oe(1), .hex(dispval), .out1(HEX0), .out2(HEX1), .out3(HEX2), .out4(HEX3));

	mux2#(1) clockmux(.sel(selclock), .in1(CLOCK_50), .in2(stepclock), .out(clock));
	
	step_clock_gen scgen(.clock(CLOCK_50), .pushbtn(~KEY[1]), .stepclock(stepclock));
	
	sextium_ram_controller ramctl(.clock(clock), .reset(reset),
		.addr_bus(addr_bus), .mem_bus_in(mem_bus_in),
		.mem_bus_out(mem_bus_out), .mem_read(mem_read), .mem_write(mem_write), .mem_ack(mem_ack),
		.clock_b(ram_clock), .enable_b(ram_clocken), .address_b(ram_address), 
		.byteena_b(ram_byteena), .data_b(ram_data), .q_b(ram_q), .wren_b(ram_wren)
		);

	sextium_ram_controller framectl(.clock(clock), .reset(reset),
		.addr_bus(frame_addr_bus), .mem_bus_in(frame_bus_in),
		.mem_bus_out(frame_bus_out), .mem_read(frame_read), .mem_write(frame_write), 
		.mem_ack(frame_ack),
		.clock_b(frame_clock), .enable_b(frame_clocken), .address_b(frame_address), 
		.byteena_b(frame_byteena), .data_b(frame_data), .q_b(frame_q), .wren_b(frame_wren)
		);
	
	sextium_sys sys
	(
		.character_lcd_DATA(LCD_DATA),
		.character_lcd_ON(LCD_ON),
		.character_lcd_BLON(LCD_BLON),
		.character_lcd_EN(LCD_EN),
		.character_lcd_RS(LCD_RS),
		.character_lcd_RW(LCD_RW),
		.sextium_ram_address(ram_address),
		.sextium_ram_byteena(ram_byteena),
		.sextium_ram_clock(ram_clock),
		.sextium_ram_clocken(ram_clocken),
		.sextium_ram_data(ram_data),
		.sextium_ram_q(ram_q),
		.sextium_ram_wren(ram_wren),
		.sextium_framebuffer_address(frame_address),
		.sextium_framebuffer_byteena(frame_byteena),
		.sextium_framebuffer_clock(frame_clock),
		.sextium_framebuffer_clocken(frame_clocken),
		.sextium_framebuffer_data(frame_data),
		.sextium_framebuffer_q(frame_q),
		.sextium_framebuffer_wren(frame_wren),
		.vga_CLK(VGA_CLK),
		.vga_HS(VGA_HS),
		.vga_VS(VGA_VS),
		.vga_BLANK(VGA_BLANK_N),
		.vga_SYNC(VGA_SYNC_N),
		.vga_R(VGA_R),
		.vga_G(VGA_G),
		.vga_B(VGA_B),
/*		.sextium_mem_addr_bus(addr_bus),
		.sextium_mem_mem_bus_in(mem_bus_in),
		.sextium_mem_mem_bus_out(mem_bus_out),
		.sextium_mem_mem_read(mem_read),
		.sextium_mem_mem_write(mem_write),
		.sextium_mem_mem_ack(mem_ack),*/
		.sextium_io_io_bus_in(io_bus_in),
		.sextium_io_io_bus_out(io_bus_out),
		.sextium_io_io_read(io_read),
		.sextium_io_io_write(io_write),
		.sextium_io_io_ack(io_ack),
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
		.clk_clk(CLOCK_50),
		.reset_reset_n(reset),
		.slow_clk_clk(clock),
		.slow_reset_reset_n(reset)
	);
	
endmodule
