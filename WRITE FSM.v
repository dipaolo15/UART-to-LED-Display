//Description:
/*
This module handles the timing needed for writing to the dot register and the control register
----------------------------------------------------------------------------------------------
Notes:
--------Dot Register Notes-----------
There are 160 Dot registers, four 5x8 matrixs.
Row 0 of each matrix does not include an Led 
High = LED on
LOW = LED off

--------Control Register Notes-----------
Control register is 2 words (16 bits) and is writen from the MSB to LSB

word 0 bit representation:
	D7 - select control word (Low = writing to word 0, High = writing to word 1)
	D6 - sleep mode (HIgh = normal operation, Low = disables display)
	D5/D4 - Peak current brightness control   (2'b10 = 4mA,
												2'b01 = 6.4mA
												2'b00 = 9.3mA
												2'b11 = 12.8mA)
	D3/D2/D1/D0 - PWM Brightness contro
	
Word 1 bit representation: 
	D7 - select control word (Low = writing to word 0, High = writing to word 1)
	D6/D5/D4/D3/D2 - Not used, must be set low
	D1 - External Display Osccillator prescaler (High = Oscillator Freq 8, Low = Oscillator Freq 1
	D0 - PWM Brightness contro
-----------------------------------------------------	


---------------------------

*/
module led_write#(parameter BRIGHTNESS_LEVEL = 63) //63 is full brightness

(
	input led_clk, //clk controlling the fsm
	input rstn,   //global reset (active low)
	input [7:0] char0, //character 0 / the next character in scrolling display
	input [7:0] char1, //character 1 (not used when scrolling_enable = 1)
	input [7:0] char2, //character 2 (not used when scrolling_enable = 1)
	input [7:0] char3, //character  3 (not used when scrolling_enable = 1)
	input scrolling_enable, //1 = scrolling display, 0 = static display
	input [7:0] control_word,
	input control_write, // 1= writing to control reg (ignored if already writing)
	input dot_write, // 1 = writing to dot reg (ignored if already writing)
	//dot_write and control_write can not both be high at the same time
	
	output reg data_out, //the data being writen to dot/control reg register
	output reg write_end,	//end of writing to control/dot register
	output reg chip_enable, // 1 = no writing, 0 = writing to dot/control reg
	output reg control_rstn, // 1 = normal operation, 0 = resets control register to all zeros
	output reg rs, // 1 = writing to control reg, 0 = writing to dot reg
	output wire blank //blanks the display
		
);


//Reg and Wire assignments

reg [7:0] char0_reg;
reg [7:0] char1_reg;
reg [7:0] char2_reg;
reg [7:0] char3_reg;
reg [7:0] control_reg;
reg output_en;
reg [2:0] led_state, led_nxt_state;
reg [1:0] state, nxt_state;
reg [7:0] count;
reg [5:0] bit_count;
reg [7:0] map_addr;
reg [1:0] char;


wire [39:0] dot_map_reg;
wire latch_char_regs;




//Assign Statments
assign latch_char_regs = !output_en && chip_enable;

//latch inputs when in the middle of writing sequence


always@(posedge led_clk or negedge rstn) begin

	if(!rstn) begin
		char0_reg <= 0;
		char1_reg <= 0;
		char2_reg <= 0;
		char3_reg <= 0;
		control_reg <= 0;
	end
	else begin
		if(latch_char_regs) begin
				char0_reg <= char0;
				char1_reg <= char1;
				char2_reg <= char2;
				char3_reg <= char3;
				control_reg <= control_word;
			
		end
	end

end




localparam 	RESET 			= 	0;
localparam	INIT_DOT_REG 	=	1;
localparam	INIT_CTRL_REG 	=	2;
localparam 	IDLE 			=	3;
localparam	DOT_WRITE		=	4;
localparam	CONTROL_WRITE	=	5;


/*************************************************************************
******************************OPERATION FSM*******************************
**************************************************************************/

always@(negedge led_clk or negedge rstn) begin
	if(!rstn) 
		led_state <= RESET;
		
		else
			led_state <= led_nxt_state;

end


always@(*)begin
	case(led_state)
	
		RESET:
			begin
				write_end = 0;
				rs = 1;
				output_en = 0;
				
				led_nxt_state = IDLE;
			end
		
		IDLE:
			begin
				write_end = 0;
				rs = 0;
			
				output_en = 0;
				
				if(control_write)
					led_nxt_state = CONTROL_WRITE;
				else if(dot_write)
					led_nxt_state = DOT_WRITE;
				else
					led_nxt_state = IDLE;
			end
			
			
			
		DOT_WRITE:
			begin
				write_end = 0;
				rs = 0;
			
				output_en = 1;
				
					case(scrolling_enable)
					
					0://no scrolling, need to writing all 4 char at once (160 bits at once)
						begin
							if(count == 159) begin
								led_nxt_state = IDLE;
								write_end = 1;
							end
							else begin
								led_nxt_state = DOT_WRITE;
								write_end = 0;
							end
						end
					
					1://scrolling, write one char at a time (40 bits)
						begin
							if(count == 39) begin
								led_nxt_state = IDLE;
								write_end = 1;
							end
							else begin
								led_nxt_state = DOT_WRITE;
								write_end = 0;
							end
						end
					endcase
			end
			
			
		CONTROL_WRITE:
			begin
				write_end = 0;
				rs = 1;
				
				output_en = 1;
				
				if(count == 7) begin
					led_nxt_state = IDLE;
					write_end = 1;
				end
				else begin
					led_nxt_state = CONTROL_WRITE;
					write_end = 0;
				end
			
			end
			
		default: led_nxt_state = RESET;
		
		
	endcase
end


always@(negedge led_clk or negedge rstn) begin //counter for the fsm 
	if(!rstn)
		count <= 0;
	else if(count == 159)
		count <= 0;
	else if(output_en)
		count <= count + 1;
	else 
		count <= 0;
end

always@(negedge led_clk or negedge rstn) begin //used to send each bit of the 40 bit char representation
	if(!rstn)
		bit_count <= 0;
	else if(bit_count == 39)
		bit_count <= 0;
	else if(output_en)
		bit_count <= bit_count + 1;
	else 
		bit_count <= 0;

end



always@(negedge led_clk or negedge rstn) begin
	if(!rstn)
		char <= 0;
	else if(scrolling_enable)
		char <= 0;
	else if(bit_count == 39) 
		char <= char + 1;
	else
		char <= char;
	
end

always@(negedge led_clk or negedge rstn) begin
	if(!rstn)
		map_addr <=0;
	else
		case(char)
		2'b00:
				map_addr <= char0_reg;
		2'b01:
				map_addr <= char1_reg;
		2'b10:
				map_addr <= char2_reg;
		2'b11:
				map_addr <= char3_reg;
		endcase		
end

dot_map test(
	.addr(map_addr),
	.rstn(rstn),
	.dout(dot_map_reg)
	);    

always@(output_en or bit_count) begin
	if(!rstn)
		data_out = 0;
	else 
		chip_enable = !output_en;
		if(output_en)
			case(rs)
				0: 
					
					data_out = dot_map_reg[39-bit_count];
					
					
				1:
					data_out = control_word[7-bit_count];
				
				default: data_out = 0;
					
			endcase
		else	
			data_out = 0;
	
end







endmodule