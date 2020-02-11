//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: MASTER CONTROLLER.v
// Author		: Nicholas DiPaolo
// Created		: Mar 14, 2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
//	Takes in the users input and stores each char into a 32 byte array.
//	Once the user sends 'ENTER' via serial port the 32-bit array is stored into a 8x32 memory, which is then displayed on the LED Display.

//Settings:
//	"<": //enables scrolling 
//	">": //disables scrolling 	
//	"0": //allows user to enter their own 4 letter word non-scrolling					
//	"1": //displays FLEX non-scrolling					
//	"2": //displays NICK non-scrolling					
							
// Notes:
//	When Scrolling text is selected:
//		-user can only input a string that is 32 or less char. if excceded,
//		 the last char of the string will be replaced with the last char inputed before hitting 'ENTER'
//		-inputing "ENTER" indicates you are finished entering the string and the text will begein to display.
		
//------------------------------------------------------------------------
// Changes: 
	//mar 15, 2019
//		Nick DiP: Added SETTINGS state, allowing the user to choose scrolling or non scrolling text and select the preset 4-letter words
	//Apr 11, 2019 
//		Nick DiP: Added continuous scolling
////----------------------------------------------------------------------
// 
//
 
module master_controller (
RST, //RESET  
sys_clk, //system Clock
char_in, //8-bit input from serial
newChar, //bit indicating new serial input
data_out, //data output to display
ce, //chip enable, enables writing to the display
rs, //register select, 0= writing to dot reg, 1 = writing to control register
serial_indicator, //indicating to the user with serial is enable or not. (1 = green light and serial is accepting inputs, 0 = red light and serial is NOT accepting inputs
scroll_indicator, //indicates wheather scrolling is on or off. (ON = RIGHT LED GREEN, OFF = RIGHT LED RED

char_read //Ued fortesting only, indicates when the char input i being read
//continuous_scoll_indicator
);

input wire RST;
input wire sys_clk;
input wire [7:0] char_in; 
input wire newChar; 

output reg 			char_read; //only used for testing
output wire 		data_out; 
output wire 		ce;  
output wire			rs;  
output wire 		serial_indicator;	  	
output wire 		scroll_indicator;



  
 
/****************register and wire declaration******************/ 
//---------------------------------------------------------------

reg [2:0] RX_state, nxt_RX_state; 	
reg [7:0] char_value; //temporary stores value of char in
reg  enable_serial; //1 = allows input from user, 0 = disables inputs from user
reg new_string;
reg daisyChain_en;
reg [7:0] stringArray [0:31]; //max 10 chars
reg [7:0] stringArrayTemp[0:31];
reg clear_integer;
reg scrolling_enable; //1 = scrolling text, 0 = display pre-set static text
reg  [1:0] staticWord_selc;
reg [5:0] count;
reg [7:0] char0, char1, char2, char3;
reg [5:0] char_count;
	
wire scrolling_clk; 
wire [7:0] stringArrayIndex;


assign  serial_indicator = enable_serial;	
assign	scroll_indicator = scrolling_enable;
assign stringArrayIndex = (char_count>=SIZE)? 0: stringArrayTemp[char_count-1]; //displays blank chars after the string is printed before scrolling through the string again	

//---------------------------------------------------------------------------------------------------------

/**********************************************************************************************************
*****************************************RX FSM**************************************************
**********************************************************************************************************/
//---------------------------------------------------------------------------------------------------------
	integer INDEX = 0; //
	integer SIZE = 0;

	
	
	localparam RESET 		= 0;
	localparam IDLE 		= 1;
	localparam STORE_VALUE 	= 2;
	localparam SETTINGS		= 3;
	localparam CLEAR_STRING	= 4;
	localparam WRITING_TEMP_STRING 	= 5;
	localparam CLEAR_TEMP_STRING = 6;
	
 
	
	
	always@(posedge newChar or posedge clear_integer) begin
		if(clear_integer)begin
			INDEX = 0;
		end
		else begin
			if(INDEX == 32)
				INDEX = INDEX;
					else
						INDEX = INDEX + 1;
			
		end
		
	end
	
	
	
	always@(posedge sys_clk or negedge RST)begin
		if(!RST)
			RX_state <= IDLE;
		else
			RX_state <= nxt_RX_state;
	end
	
	always@(*) begin
		case(RX_state)
		
			RESET:
				begin
					
					scrolling_enable = 1;//default is scrolling enabled
					new_string = 0;
					nxt_RX_state = 0;
					enable_serial = 0; //stops user from inputing any values well writing
					nxt_RX_state = IDLE;
					clear_integer = 1;
					staticWord_selc = 0;
					daisyChain_en = 0;
				end
				
			IDLE:
				begin
						char_read = 0;
						clear_integer = 0;
						enable_serial = 1;
						new_string = 0;
						
						if(!newChar)begin
							nxt_RX_state = IDLE;
						end
						else begin
															
								case(char_in)
								
									8'h0D: 
										begin
											case(stringArray[0])
												
												"<", ">", "1", "2", "0":
																	begin
																		if(INDEX == 2)
																			nxt_RX_state = SETTINGS;
																		else
																			nxt_RX_state = CLEAR_TEMP_STRING;
																	end
																		
												default:			
																		nxt_RX_state = CLEAR_TEMP_STRING;
																		
											endcase
										end
										default:
										begin
											char_value = char_in;
											nxt_RX_state = STORE_VALUE;
										end
							endcase
						end
				end
	
			STORE_VALUE: //Storing into string
				begin
					char_read = 1;
					clear_integer = 0;
					enable_serial = 0; //stops user from inputing values well storing the value
					stringArray[INDEX - 1] = char_value;
					nxt_RX_state = IDLE;
				end
				
				
			SETTINGS:
				begin
					case(stringArray[0])
						"<": //enables scrolling 
							begin
								scrolling_enable = 1;
								staticWord_selc = staticWord_selc;
								nxt_RX_state = CLEAR_STRING;
							end
						">": //disables scrolling 
							begin
								scrolling_enable = 0;
								staticWord_selc = staticWord_selc;
								nxt_RX_state = CLEAR_STRING;
							end
						"0": //allows user to enter their own 4 letter word non-scrolling
							begin
								staticWord_selc = 0;
								nxt_RX_state = CLEAR_STRING;
								scrolling_enable = scrolling_enable;
							end
							
						"1": //displays FLEX non-scrolling
							begin
								staticWord_selc = 1;
								nxt_RX_state = CLEAR_STRING;
								scrolling_enable = scrolling_enable;
							end
							
						"2": //displays NICK non-scrolling
							begin
								staticWord_selc = 2;
								nxt_RX_state = CLEAR_STRING;
								scrolling_enable = scrolling_enable;
							end
						"[": //displays NICK non-scrolling
							begin
								daisyChain_en = 0;
								staticWord_selc = staticWord_selc;
								nxt_RX_state = CLEAR_STRING;
								scrolling_enable = scrolling_enable;
							end
						"]": //displays NICK non-scrolling
							begin
								daisyChain_en = 1;
								staticWord_selc = staticWord_selc;
								nxt_RX_state = CLEAR_STRING;
								scrolling_enable = scrolling_enable;
							end
						default:
							begin
								staticWord_selc = staticWord_selc;
								scrolling_enable = scrolling_enable;
								nxt_RX_state = CLEAR_STRING;
							end
					endcase
					
					
				end
				
			CLEAR_TEMP_STRING:
				begin
					char_read = 1;
					clear_integer = 0;
					enable_serial = 0;
					new_string = 1;
					if(count == 31)
						nxt_RX_state = WRITING_TEMP_STRING;
					else begin
						stringArrayTemp[count] = 0;
						nxt_RX_state = CLEAR_TEMP_STRING;
					end
					
				
				end
			WRITING_TEMP_STRING:
				begin
					clear_integer = 0;
					enable_serial = 0;
					new_string = 1;
					SIZE = INDEX;
					if(count == INDEX)
						nxt_RX_state = CLEAR_STRING;
							else begin
								stringArrayTemp[count] = stringArray[count];
								nxt_RX_state = WRITING_TEMP_STRING;
							end
							
				end
				
			CLEAR_STRING:
				begin
					clear_integer = 1;
					enable_serial = 0;
					new_string = 0;
					if(count == 31)
						nxt_RX_state = IDLE;
					else begin
						stringArray[count] = 0;
						nxt_RX_state = CLEAR_STRING;
					end
				end
				
			default:
				nxt_RX_state = IDLE;
		endcase
		
	end	
	always@(posedge sys_clk)begin
		case(RX_state)
		
			RESET:
				begin
					count <= 0;
				end
				
			IDLE, STORE_VALUE, SETTINGS :
											count <= 0;
											
					
			CLEAR_TEMP_STRING, CLEAR_STRING:
				begin
					if(count == 31)
						count <= 0;
					else
						count <= count + 1;
				end
				
			WRITING_TEMP_STRING:
				begin
					if(count == INDEX)
						count <= 0;
					else
						count <= count + 1;

							
				end
			
			default:
				count <= 0;
		endcase
		
	end
	
	/********************************************************************************
	********************************************************************************
	**********************************************************************************/
	//Scrolling clock. speed of the letters appearing on to the display when scrolling
	
	
//dclock #(.divider(1040000)) scrollin_speed( // 0.5 secs	
dclock #(.divider(346666)) scrollin_speed( // 0.166 secs

	.clk(sys_clk),
	.reset(RST),
	.clko(scrolling_clk)
	);
	
	
	
	
	
	



	always@(posedge scrolling_clk or negedge RST) begin
	
		if(!RST)
			char_count <= 0;
		else if(new_string)
			char_count <= 0;
		else if(char_count == SIZE + 4)
			char_count <= 0;
		else
			char_count <= char_count + 1;
			
	end
	
	
	
always@(scrolling_enable or staticWord_selc)begin
	if(!scrolling_enable) begin
		case(staticWord_selc)
			0:
				begin
						char0 = stringArrayTemp[0];
						char1 = stringArrayTemp[1];
						char2 = stringArrayTemp[2];
						char3 = stringArrayTemp[3];
					
				end
			
			1:
				begin
						char0 = "F";
						char1 = "L";
						char2 = "E"; 
						char3 = "X";
					
				end
			
			2:
				begin
						char0 = "N";
						char1 = "I";
						char2 = "C";
						char3 = "K";
					
				end
			
			default:
				begin
						char0 = 0;
						char1 = 0;
						char2 = 0;
						char3 = 0;
						
					end
		endcase
	end	
	else begin
						char0 = stringArrayIndex;
						char1 = 0;
						char2 = 0;
						char3 = 0;
	end
end
	
lcd_controller led_FSM(
.led_clk(sys_clk),
.scrolling_clk(scrolling_clk),
.scrolling_enable(scrolling_enable),
.char0(char0), //character 0 / the next character in scrolling display
.char1(char1), //character 1 (not used when scrolling_enable = 1)
.char2(char2), //character 2 (not used when scrolling_enable = 1)
.char3(char3), //character  3 (not used when scrolling_enable = 1)
.start(!new_string),
.write_char_done(),
.rstn(RST),
.data_out(data_out),
.ce(ce),
.rs(rs)

);
	
	
endmodule

