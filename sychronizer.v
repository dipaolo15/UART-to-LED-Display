//---------------------------------------------------------------------
// Project		: LED Display 
// Module Name	: Synchronizer.v
// Author		: Nicholas DiPaolo
// Created		: Mar 15, 2019
// Company		: Flex
//----------------------------------------------------------------------
// Description : 
// synchronizes a 1-bit and 8-bit signal to the clcok

//------------------------------------------------------------------------
// Changes: 

////----------------------------------------------------------------------
// Notes:

module Synchronizer(d_in, byte_in, clk, RST, d_sysc, byte_sysc_byte);
	input d_in, clk, RST;
	input [7:0] byte_in;
	
	output reg d_sysc;
	output reg [7:0] byte_sysc_byte;
	 
	always@(posedge clk or negedge RST)begin
		if(!RST) begin
			byte_sysc_byte <= 0;
			d_sysc <= 0;
		end
		else begin
			byte_sysc_byte <= byte_in;
			d_sysc <= d_in;
		end
	end
endmodule
