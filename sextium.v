
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

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

	wire clock, reset;
	wire mem_read, mem_write, io_read, io_write;
	wire [15:0] mem_bus, addr_bus;
	wire [4:0] slowclock;
	
//=======================================================
//  Structural coding
//=======================================================

//	assign clock = CLOCK_50;
	assign reset = KEY[0];
	assign SRAM_LB_N = 0;
	assign SRAM_UB_N = 0;
	assign SRAM_CE_N = 0;
	assign SRAM_OE_N = ~mem_read;
	assign SRAM_WE_N = ~mem_write;
	assign SRAM_DQ = mem_bus;
	assign SRAM_ADDR[15:0] = addr_bus;
	assign SRAM_ADDR[19:16] = 0;

	sextium_core core(.clock(clock), .reset(reset), .mem_bus(mem_bus), .addr_bus(addr_bus),
		.mem_read(mem_read), .mem_write(mem_write), .io_read(io_read), .io_write(io_write));
		
	slowclock clockgen(.areset(reset), .inclk0(CLOCK_50), .c0(clock));

endmodule
