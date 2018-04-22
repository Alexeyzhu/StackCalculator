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
	
	reg NewToken = 0;
	reg Probe = 0;
	reg [3:0] OutBuffer;
	reg GapStage = 0;
	
	// Output wires and registers
	reg [3:0] Col;
	reg [3:0] DecodeOut;
	reg lock = 0;
	
	// Count register
	reg [19:0] sclk = 0;
	
	assign DecoderState = NewToken && ~lock;

// ==============================================================================================
// 												Implementation
// ==============================================================================================

	always @(posedge clk) begin	
		if (sclk == 20'b00000000000000000000)
				if (NewToken && Probe)
					lock <= 1;		
				else 	if (!NewToken && Probe) begin							
							DecodeOut <= OutBuffer;
							NewToken <= 1;
							if (lock)
								lock <= 0;
						end else if (NewToken && !Probe) begin
										NewToken <= 0;
										lock <= 0;
									end
		if (sclk == 20'b00000000000000000001)
			lock <= 1;
			
			// 1ms
			if (sclk == 20'b110000110101000000) begin
				//C1
				Col <= 4'b0111;
				sclk <= sclk + 1'b1;
				Probe <= 0;
			end
			
			// check row pins
			else if(sclk == 20'b110000110101001000) begin
				
				//R1
				if (Row == 4'b0111) begin
					OutBuffer <= 4'b0001;		//1
					Probe <= 1;
					lock <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					OutBuffer <= 4'b0100;		//4
						Probe <= 1;
						lock <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					OutBuffer <= 4'b0111;		//7
					Probe <= 1;
					lock <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					OutBuffer <= 4'b0000;		//0
					Probe <= 1;
					lock <= 1;
				end
				sclk <= sclk + 1'b1;
			end

			// 2ms
			else if(sclk == 20'b1100001101010000000) begin
				//C2
				Col<= 4'b1011;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b1100001101010001000) begin
				//R1
				if (Row == 4'b0111) begin
					OutBuffer <= 4'b0010;		//2
					Probe <= 1;
					lock <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					OutBuffer <= 4'b0101;		//5
					Probe <= 1;
					lock <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					OutBuffer <= 4'b1000;		//8
					Probe <= 1;
					lock <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					OutBuffer <= 4'b1111;		//F
					Probe <= 1;
					lock <= 1;
				end
				sclk <= sclk + 1'b1;
			end

			//3ms
			else if(sclk == 20'b10010010011111000000) begin
				//C3
				Col<= 4'b1101;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b10010010011111001000) begin
				//R1
				if(Row == 4'b0111) begin
					OutBuffer <= 4'b0011;		//3
					Probe <= 1;
					lock <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					OutBuffer <= 4'b0110;		//6
					Probe <= 1;
					lock <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					OutBuffer <= 4'b1001;		//9
					Probe <= 1;
					lock <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
					OutBuffer <= 4'b1110;		//E
						Probe <= 1;
						lock <= 1;
				end
				sclk <= sclk + 1'b1;
			end

			//4ms
			else if(sclk == 20'b11000011010100000000) begin
				//C4
				Col<= 4'b1110;
				sclk <= sclk + 1'b1;
			end

			// Check row pins
			else if(sclk == 20'b11000011010100001000) begin
				//R1
				if(Row == 4'b0111) begin
					OutBuffer <= 4'b1010;		//A
					Probe <= 1;
					lock <= 1;
				end
				//R2
				else if(Row == 4'b1011) begin
					OutBuffer <= 4'b1011;		//B
						Probe <= 1;
						lock <= 1;
				end
				//R3
				else if(Row == 4'b1101) begin
					OutBuffer <= 4'b1100;		//C
						Probe <= 1;
						lock <= 1;
				end
				//R4
				else if(Row == 4'b1110) begin
						OutBuffer <= 4'b1101;		//D
						Probe <= 1;
						lock <= 1;
				end
										
				sclk <= 20'b00000000000000000000;
			end

			// Otherwise increment
			else begin
				sclk <= sclk + 1'b1;
			end
		end
endmodule
