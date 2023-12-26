package mux_header;

	parameter LENGHT_RAM = 131072; //16K 1024 * 32 8192
	parameter LENGHT_RAM_Rx = 12288;
	parameter WIDTH_RAM = 32;
	parameter RANG_RAM = 31;
	parameter MSB_RAM = 31;
	parameter MSB_CNT_DATA = 19;
	parameter RANG_RAM_RX = 29;
	parameter RANG_CNT_TX = 31;
	parameter MSB_LENGHT_REG_BRAM_CNT = 24;
	parameter LENGHT_CNT_RX = 24;
	parameter LAST_TACT_DATA_IN_N = 28;
	parameter LAST_TACT_DATA_IN_V = 24;
	parameter CNT_VSK_PACK = 16;
	//parameter LENGHT_RAM_ADDR = LENGHT_RAM * WIDTH_RAM;
    parameter MSB_ADDR_VSK = 16;
    parameter BIT_ONCE_VSK = 6;
    parameter BIT_ONCE_NSK = 7;
    ///////////////////////////////////13 - 1 
    //parameter MSB_RAM_WIDTH = ($clog2(LENGHT_RAM)) - ONE;
	parameter MSB_RAM_RX_WIDTH = 19;//13
	parameter MSB_RAM_TX_WIDTH = 12;
	//parameter MSB_WIIGHT_PACK_RX = 19;
	
	parameter LENGHT_BRAM_NSK = 2048;
	parameter LENGHT_BRAM_VSK = 131072;
	
	parameter CODE_NSK = 36000;
	parameter CODE_VSK = 6;

	parameter NULL 	= 0;
	parameter ONE 	= 1;
	parameter TWO 	= 2;
	parameter THREE = 3;
	parameter FOUR 	= 4;
	parameter FIVE 	= 5;
	parameter SIX 	= 6;
	parameter SEVEN	= 7;
	parameter IEGHT	= 8;
	parameter NINE	= 9;
	parameter TEN = 10;
	
	parameter LIMIT_VSK_IN = 1024;
	parameter LIMIT_NSK_IN = 512;
	
	parameter WINDOW_CUT = 511;
	parameter WINDOW_CUT_0_5 = 255;



















endpackage: mux_header