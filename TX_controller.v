//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: TX_controller.v
// Author		: Nicholas DiPaolo
// Created		: Mar 14, 2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
//  This module outputs to the serial monitor the chars that are inputed by the user 

//------------------------------------------------------------------------
// Changes: 

////----------------------------------------------------------------------
// Notes:


module TX_controller(
RST, //RESET
sys_clk, //system Clock
char_in, //8-bit input from serial
newChar, //bit indicating new serial input
enable_serial, //disables user from inputing values well writing to the display
TX_en, //enable serial output
serial_out//char that will be output to serial
);
	
	input RST;
	input sys_clk;
	input [7:0] char_in;
	input newChar;
	input enable_serial;
	
	output reg TX_en;
	output reg [7:0] serial_out;
	
	reg [1:0] TX_state, nxt_TX_state; 
	
	localparam RESET 			= 0;
	localparam IDLE 			= 1;
	localparam SETTING_DISPLAY 	= 2;
	localparam TX_HIGH 			= 3;
	localparam TX_LOW 			= 4;
	
	
	
	always@(posedge sys_clk or negedge RST)begin
		if(!RST)
			TX_state <= IDLE;
		else 
			TX_state <= nxt_TX_state;
			
	end
	always@(*)begin
		case(TX_state)
			RESET:
				begin
					TX_en = 0;
					nxt_TX_state = IDLE;
				end
			IDLE:
				begin
					TX_en = 0;
					if(!newChar || !enable_serial)begin
					
						nxt_TX_state = IDLE;
					end
					else begin
						case(char_in)
						
							8'h0D: //user inputs 'enter'
								begin
									serial_out = 8'h0A; //prints a new line
									nxt_TX_state = TX_HIGH;
								end
								
							default:
								begin
									serial_out = char_in;//prints what ever was typed
									nxt_TX_state = TX_HIGH;
								end
						
						endcase
												
					end
				end
			
			TX_HIGH:
				begin
					TX_en = 1; //print serial out
					nxt_TX_state = TX_LOW;
				end
				
			TX_LOW:
				begin
					TX_en = 0;
					nxt_TX_state = IDLE;
					
				end
			default:
				begin
					TX_en = 0;
					nxt_TX_state = IDLE;
				end
		endcase
	end
endmodule