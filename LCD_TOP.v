//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: LCD_TOP.v
// Author		: Nicholas DiPaolo
// Created		: 02/028/2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
/*
This Project  performs the following functions
	Takes in users input via Serial console and outputs it onto HCMS-290x LED Display.
	
	User can choose from scrolling or non scrolling Text by inputing the folling:
	
		"<" = scrolling text, user then can type any string into the serial console (up to 32 char) and the string will be displayed 
				on the LED display.
			
		">" = Non-scrolling text, user can select from preset 4 letter words to be displayed. 
				preset words can be select by enetering "1" or "2":
					"1" = FLEX
					"2" = NICK
				"0" allows user to enter any 4 letter they wish to display
*/ 
//------------------------------------------------------------------------
// Notes: 
//Middle LED indicates whether the serial console is accepting user input:
//		- GREEN = input is enabled
//		- RED = input is disabled

//Right LED indicates whether the display is set to scrolling or non-scrolling text:
//		- GREEN = scrolling
//		- RED = non-scrolling

 ////----------------------------------------------------------------------
// Modification history : 
//Mar 14, 2019:
//Nick DiP: Output users input to the display via scrolling text (32 Char Max)

//Mar 15, 2019:
//Nick DiP: Allows user to select scrolling or non scrolling text. Non scolling text displayes preset
//			4 letter words that are selected by user

//
 ////----------------------------------------------------------------------
 
module LCD_TOP (  
					 	   
					   
						input  	wire   		UART_RX,
						
                      
						output 	wire 		data_out,
						output 	wire		chip_en,
						output 	wire   		reg_selc,
						output 	wire 		sys_clk,
						output 	wire 		UART_TX,
			 			output 	wire 		GREEN_LIGHT_MID, 
						output 	wire		RED_LIGHT_MID,
						output  wire 		GREEN_LIGHT_RIGHT,
						output  wire 		RED_LIGHT_RIGHT
						
        ); 
 
	wire RST;
	assign RST = 1; //RST is always disabled, dont have an RST button/switch
		
//Internal Oscillator instantiation
//assign sys_clk = SYS_CLK; //use this for external 10MHz oscillator

wire sys_clk,mem_clk;
//defparam OSCH_inst.NOM_FREQ = "7.00";// This is the default frequency
defparam OSCH_inst.NOM_FREQ = "2.08"; //MHz
OSCH OSCH_inst
( 
.STDBY(1'b0), // 0=Enabled, 1=Disabled; also Disabled with Bandgap=OFF
.OSC(sys_clk), // Disable this for external oscillator
.SEDSTDBY()// this signal is not required if not using SED
); 

GSR     GSR_INST (.GSR (RST)); //inferring global reset

	wire serial_indicator;
	wire scroll_indicator;
	
	assign GREEN_LIGHT_MID = serial_indicator; //serial is enable
	assign RED_LIGHT_MID = !serial_indicator; //serial is disabled
	 
	assign GREEN_LIGHT_RIGHT = scroll_indicator; //scrolling is enable
	assign RED_LIGHT_RIGHT = !scroll_indicator;	//scrolling is disabled
	
	
	wire  [7:0] uart_8bit_uart;
	wire  uart_read_done_uart;
	wire [7:0] char_in_sync;
	wire newChar_sync;
	
	wire [7:0] TX;
	wire TX_start;
	
uart_rx #(.CLKS_PER_BIT(18))  uart_rx1  // 60(original code for 7MHz) for internal 7MHz sysclk and 18 for 2MHz 
( 
  	.i_Rx_Serial     (UART_RX),
	.i_Clock         (sys_clk),
	.o_Rx_Byte       (uart_8bit_uart),//8-bit
	.o_Rx_DV       	 (uart_read_done_uart) 
);
	
uart_tx #(.CLKS_PER_BIT(18))  uart_tx1  // 61 for internal 7MHz sysclk and 18 for 2MHz
( 
  	.i_Clock         (sys_clk),
	.i_Tx_Byte       (TX),//8-bit
	.i_Tx_DV       	 (TX_start), 
	.o_Tx_Serial     (UART_TX),//UART_TX
	.o_Tx_Active     (),
	.o_Tx_Done	     (uart_tx_done)
	
);

	
	
Synchronizer syscUART( //synchronize inputs from UART
	.d_in(uart_read_done_uart),
	.byte_in(uart_8bit_uart),
	.clk(sys_clk),
	.RST(RST),
	.d_sysc(newChar_sync),
	.byte_sysc_byte(char_in_sync)
);
	
	
	
TX_controller serialOUTPUT( //controlling what is being outputed to the serial console
	.RST(RST), 
	.sys_clk(sys_clk) ,
	.char_in(char_in_sync),
	.newChar(newChar_sync),
	.enable_serial(serial_indicator),
	.TX_en(TX_start), 
	.serial_out(TX)
);
	
master_controller masterCONTROLLER( //Reads users input and display it to the display
	.RST(RST), 
	.sys_clk(sys_clk) , 
	.char_in(char_in_sync),
	.newChar(newChar_sync),
	.data_out(data_out), 
	.ce(chip_en), 
	.rs(reg_selc),
	.serial_indicator(serial_indicator), 
	.scroll_indicator(scroll_indicator)
);
	

	
		
endmodule 




