//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: dot_map.v
// Author		: Nicholas DiPaolo
// Created		: Mar 1, 2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
// Takes an ASCII value and outputs the corrsponding 40-bit repersentation of the value for the LED Display (HCMS-290x)

//------------------------------------------------------------------------
// Changes: 

////----------------------------------------------------------------------
// Notes:
//This LUT has 40-bit repersentations for ASCII values A to Z,".", "'", and " ".

module dot_map(
addr,
rstn,
dout
);
input [7:0] addr;
input rstn;
output reg[39:0] dout;

always@(addr)begin
		if(!rstn)
			dout = 0;
		else
			case(addr)
				8'b00://null
				
							dout = 0;	
								/*
								00000;
								00000;
								00000;
								00000;
								00000;
								00000;
								00000;	
								*/
				
				"A","a":
							dout= 40'b0111100000001110000010010000111001111000;
								/*
								00100
								01010
								01010
								11111
								10001
								10001
								10001
								*/

				"B","b":
							dout= 40'b0111111101001001010010010100100100111110;
								/*
								11110
								10001
								10001
								11111
								10001
								10001
								11110
								*/

				"C","c":
							dout= 40'b0111111101000001010000010100000101000001;
								/*
								11111
								10000
								10000
								10000
								10000
								10000
								11111
								*/

				"D","d":
							dout= 40'b0111111101000001010000010100000100111110;
								/*
								11110
								10001
								10001
								10001
								10001
								10001
								11110
								*/

				"E","e": 
							dout = 40'b0111111101001001010010010100100101000001;
									/*
									11111;
									10000;
									10000;
									11110;
									10000;
									10000;
									11111;
									*/

				"F","f": 
						
							dout = 40'b0111111100001001000010010000100100000001;
							
									/*
									11111;
									10000;
									10000;
									11110;
									10000;
									10000;
									10000;
									*/
				
				"G","g":
							dout= 40'b0111111101000001010010010100100101111001;
									/*
									11111
									10000
									10000
									10111
									10001
									10001
									11111
									*/
				"H", "h":
				
							dout = 40'b0111111100001000000010000000100001111111;	
									/*
									10001
									10001
									10001
									11111
									10001
									10001
									10001
									*/
						
				"I", "i":
				
							dout = 40'b0100000101000001011111110100000101000001;	
									/*
									11111
									00100
									00100
									00100
									00100
									00100
									11111	
									*/
					
				"J", "j":
				
							dout = 40'b0111000101000001011111110000000100000001;	
								/*
								11111
								00100
								00100
								00100
								10100
								10100
								11100	
								*/
				"K", "k":
				
							dout = 40'b0111111100001000000101000010001001000001;	
								/*
								10001
								10010
								10100
								11000
								10100
								10010
								10001	
								*/
				
				"L","l": 
							dout = 40'b0111111101000000010000000100000001000000;
								/*
								10000
								10000
								10000
								10000
								10000
								10000
								11111
								*/	
						
					
				"M", "m":
				
							dout = 40'b0111111100000010000011000000001001111111;	
								/*
								10001
								11011
								10101
								10001
								10001
								10001
								10001	
								*/
					
				"N", "n":
				
							dout = 40'b0111111100000011000111000110000001111111;	
								/*
								11001
								11001
								10101
								10101
								10101
								10011
								10011	
								*/
								
				"O", "o":
				
							dout = 40'b0011111001000001010000010100000100111110;	
								/*
								01110
								10001
								10001
								10001
								10001
								10001
								01110
								*/
						
				"P", "p":
				
							dout = 40'b0111111100001001000010010000100100001111;	
								/*
								11111;
								10001;
								10001;
								11111;
								10000;
								10000;
								10000;	
								*/	
								
				"Q", "q":
				
							dout = 40'b0001111000100001001100010010000101011110;	
								/*
								01110
								10001
								10001
								10001
								10101
								01110
								00001
								*/
					
				"R", "r":
				
							dout = 40'b0111111100001001000110010010100101001111;	
								/*
								11111
								10001
								10001
								11111
								10100
								10010
								10001	
								*/	
								
								
				"S", "s":
				
							dout = 40'b0100011001001001010010010100100100110001;	
								/*
								01111
								10000
								10000
								01110
								00001
								00001
								11110	
								*/
					
				"T", "t":
				
							dout = 40'b0000000100000001011111110000000100000001;	
								/*
								11111
								00100
								00100
								00100
								00100
								00100
								00100	
								*/
								
				"U", "u":
				
							dout = 40'b0011111101000000010000000100000000111111;	
								/*
								10001
								10001
								10001
								10001
								10001
								10001
								01110	
								*/
								
				"V", "v":
				
							dout = 40'b0001111100100000010000000010000000011111;	
								/*
								10001
								10001
								10001
								10001
								10001
								01010
								00100	
								*/
				"W", "w":
				
							dout = 40'b0111111100100000000110000010000001111111;	
								/*
								10001
								10001
								10001
								10101
								10101
								11011
								10001	
								*/
								
					
				"X","x": 
							dout = 40'b0100000100100010000111000010001001000001;
								/*
									10001
									01010
									00100
									00100
									00100
									01010
									10001
									*/	

				"Y", "y":
				
							dout = 40'b0000001100000100011110000000010000000011;	
								/*
								10001
								10001
								01010
								00100
								00100
								00100
								00100
								*/
								
				"Z", "z":
				
							dout = 40'b0110000101010001010010010100010101000011;	
								/*
								11111
								00001
								00010
								00100
								01000
								10000
								11111
								*/
								
				" ":
				
							dout = 0;	
								/*
								00000
								00000
								00000
								00000
								00000
								00000
								00000	
								*/
				
				//numbers
				
				"0":
								dout = 40'b0111111101000001010000010100000101111111;	
								/*
								11111
								10001
								10001
								10001
								10001
								10001
								11111
								*/
				"1":
								dout = 40'b0100010001000010011111110100000001000000;	
								/*
								00100
								01100
								10100
								00100
								00100
								00100
								11111	
								*/
				"2":
								dout = 40'b0110001001010001010010010100010101000010;	
								/*
								01110
								10001
								00010
								00100
								01000
								10000
								11111	
								*/
				"3":
								dout = 40'b0100100101001001010010010101010100100010;	
								/*
								11110
								00001
								00010
								11100
								00010
								00001
								11110	
								*/
				
				"4":
								dout = 40'b0000111100001000000010000000100001111111;	
								/*
								10001
								10001
								10001
								11111
								00001
								00001
								00001	
								*/
				"5":
								dout = 40'b0010111101001001010010010100100100110001;	
								/*
								11111
								10000
								10000
								11110
								00001
								10001
								01110	
								*/
				"6":
								dout = 40'b0011100001001100010010100100100100110001;	
								/*
								00011
								00100
								01000
								11110
								10001
								10001
								01110	
								*/
				"7":
								dout = 40'b0110100100011001000010010000110100001011;	
								/*
								11111
								00001
								00010
								11111
								01000
								10000
								10000	
								*/
				"8":
								dout = 40'b0011011001001001010010010100100100110110;
									/*
								01110
								10001
								10001
								01110
								10001
								10001
								01110
								*/
				"9":
								dout = 40'b0100011001001001010010010010100100011110;	
								/*
								01110
								10001
								10001
								01111
								00001
								00010
								11100	
								*/
								
				
				
				
				//Speical Chars
				//-----------------------------------------------------------------------------
				".":
							dout = 40'b0100000000000000000000000000000000000000;
								/*
								00000
								00000
								00000
								00000
								00000
								00000
								10000	
								*/
								
				"'":
							dout = 40'b0000001100000000000000000000000000000000;
								/*
								10000
								10000
								00000
								00000
								00000
								00000
								00000	
								*/
				
				"!":
							dout = 40'b0000000000000000010111110000000000000000;
								/*
								00100
								00100
								00100
								00100
								00100
								00000
								00100	
								*/
				
				"#":
							dout = 40'b0001010000110110000101000011111000010100;
								/*
								00000
								01010
								11111
								01010
								11111
								01010
								00000	
								*/
								
								
				"?":
							dout = 40'b0000001000000001010110010000010100000010;
								/*
								01110
								10001
								00010
								00100
								00100
								00000
								00100	
								*/
								
				
					default:
											
							dout = 0;	
								/*
								00000
								00000
								00000
								00000
								00000
								00000
								00000	
								*/
				endcase
	
	endendmodule	