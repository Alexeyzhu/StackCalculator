`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Engineer: Michelle Yu  
//				 Josh Sackos
//
//
// Create Date:    	07/23/2012 
// Last modified:		17/04/2018
//
// Module Name:    Decoder
// Project Name:   StackCalc
// Target Devices: Max10
// Description: This file defines a component Decoder. The Decoder scans
//					 each column by asserting a low to the pin corresponding to the column at 1KHz. After a
//					 column is asserted low, each row pin is checked. When a row pin is detected to be low,
//					 the key that was pressed could be determined.
//
// Revision History: 
// 						Revision 0.01 - File Created (Michelle Yu)
//							Revision 0.02 - Converted from VHDL to Verilog (Josh Sackos)
//							Revision 0.03 - Added DecoderState
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================================
// 												Define Module
// ==============================================================================================
module Decoder(
    clk,
    Row,
    Col,
    DecodeOut,
	 DecoderState
    );

// ==============================================================================================
// 											Port Declarations
// ==============================================================================================
    input clk;						// 100MHz onboard clock
    input [3:0] Row;				// Rows on KYPD
    output [3:0] Col;			// Columns on KYPD
    output [3:0] DecodeOut;	// Output data
	 output DecoderState;		// 0 - no change, 1 - has new token

// ==============================================================================================
// 							  		Parameters, Regsiters, and Wires
// ==============================================================================================
	
	// Output wires and registers
	reg [3:0] Col;
	reg [3:0] DecodeOut;
	reg DecoderState;
	
	// Count register
	reg [19:0] sclk = 0;

// ==============================================================================================
// 												Implementation
// ==============================================================================================

	always @(posedge clk) begin
			DecoderState <= 0;
			// 1ms
			if (sclk == 20'b00011000011010100000) begin
				//C1
				Col <= 4'b0111;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b00011000011010101000) begin
				//R1
				if (Row == 4'b0111) begin
					DecodeOut <= 4'b0001;		//1
					DecoderState <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0100; 		//4
					DecoderState <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b0111; 		//7
					DecoderState <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b0000; 		//0
					DecoderState <= 1;
				end
				sclk <= sclk + 1'b1;
			end

			// 2ms
			else if(sclk == 20'b00110000110101000000) begin
				//C2
				Col<= 4'b1011;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b00110000110101001000) begin
				//R1
				if (Row == 4'b0111) begin
					DecodeOut <= 4'b0010; 		//2
					DecoderState <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0101; 		//5
					DecoderState <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1000; 		//8
					DecoderState <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1111; 		//F
					DecoderState <= 1;
				end
				sclk <= sclk + 1'b1;
			end

			//3ms
			else if(sclk == 20'b01001001001111100000) begin
				//C3
				Col<= 4'b1101;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b01001001001111101000) begin
				//R1
				if(Row == 4'b0111) begin
					DecodeOut <= 4'b0011; 		//3
					DecoderState <= 1;	
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0110; 		//6
					DecoderState <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1001; 		//9
					DecoderState <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1110; 		//E
					DecoderState <= 1;
				end

				sclk <= sclk + 1'b1;
			end

			//4ms
			else if(sclk == 20'b01100001101010000000) begin
				//C4
				Col<= 4'b1110;
				sclk <= sclk + 1'b1;
			end

			// Check row pins
			else if(sclk == 20'b01100001101010001000) begin
				//R1
				if(Row == 4'b0111) begin
					DecodeOut <= 4'b1010; //A
					DecoderState <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b1011; //B
					DecoderState <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1100; //C
					DecoderState <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1101; //D
					DecoderState <= 1;
				end
				sclk <= 20'b00000000000000000000;
			end

			// Otherwise increment
			else begin
				sclk <= sclk + 1'b1;
			end
			
	end

endmodule
