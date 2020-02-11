//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: TX_controller.v
// Author		: Nicholas DiPaolo
// Created		: Mar 14, 2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
//  This module toggles between writing and not writing to the display

//------------------------------------------------------------------------
// Changes: 

////----------------------------------------------------------------------
// Notes:
//Every posedge scrolling_clk scrolling writes to the display.
//If scrolling is enabled, then after every char is writen it will go to IDLE and wait until the next clock cycle to write the next char
//If non_scrolling, then all 4 char are wrtten. Once wrtten it wll go to IDLE state and wait till the next posedge will write all 4 char again

module lcd_controller(
led_clk,
scrolling_clk,
scrolling_enable,
char0,
char1,
char2,
char3,
start,
write_char_done,
rstn,
data_out,
ce,
rs  
 
);

  
input led_clk;
input scrolling_clk;
input scrolling_enable; 
input [7:0] char0;
input [7:0] char1;
input [7:0] char2;
input [7:0] char3;
input start;
input rstn;
output write_char_done;
output data_out;
output ce;
output rs;


reg start_control_write; 
reg start_dot_write;
reg [1:0] state, nxt_state;

wire write_end;
wire CLOCK;

assign write_char_done = write_end;
assign CLOCK =(scrolling_enable)?scrolling_clk:led_clk;
 



	localparam RESET = 0;
	localparam IDLE = 1;
	localparam WRITE_DOT = 2;
	localparam hold = 3;
	
	
	
	
	always@(posedge scrolling_clk or negedge rstn or posedge write_end)begin
	
		if(!rstn) begin
			state <= RESET;
			
		end
		else if(write_end)
			state <= IDLE;
		else begin
			state <= nxt_state;
			
		
		end
	end
	
	
	
	always@(*)begin
		case(state)
		
		
		RESET:
			begin
					start_control_write = 0;
					start_dot_write = 0;
					nxt_state = IDLE;
				
					
			end
			
		IDLE:
			begin
					start_control_write = 0;
					start_dot_write = 0;
					if(start) 
						nxt_state = WRITE_DOT;
					else
						nxt_state = IDLE;
					
			end
			 
	
		WRITE_DOT:
			begin
					start_control_write = 0;
					start_dot_write = 1;
					nxt_state = hold;
					
			end
			
		hold:
			begin
					start_control_write = 0;
					start_dot_write = 0;
			
			end
					
				
			
		
			
			default: begin
				start_control_write = 0;
					start_dot_write = 0;
					nxt_state = RESET;
			end
			
		
		endcase
	end
	
	led_write led_FSM(
	.led_clk(led_clk), //clk controlling the fsm
	.rstn(rstn),   //global reset (active low)
	.char0(char0), //character 0 / the next character in scrolling display
	.char1(char1), //character 1 (not used when scrolling_enable = 1)
	.char2(char2), //character 2 (not used when scrolling_enable = 1)
	.char3(char3), //character  3 (not used when scrolling_enable = 1)
	.scrolling_enable(scrolling_enable), //1 = scrolling display, 0 = static display
	.control_word(8'b01001111),
	.control_write(start_control_write), // 1= writing to control reg (ignored if already writing)
	.dot_write(start_dot_write), // 1 = writing to dot reg (ignored if already writing)
	//dot_write and control_write can not both be high at the same time
	
	.data_out(data_out), //the data being writen to dot/control reg register
	.write_end(write_end),	//end of writing to control/dot register
	.chip_enable(ce), // 1 = no writing, 0 = writing to dot/control reg
	.control_rstn(), // 1 = normal operation, 0 = resets control register to all zeros
	.rs(rs) // 1 = writing to control reg, 0 = writing to dot reg
	);
endmodule