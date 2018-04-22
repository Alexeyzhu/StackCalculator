/*
	The main module for Stack Calculator
	Authors: 	a guy from GitHub
					Muhammad Mavlyutov
*/

`timescale 1ns / 1ps

module StackCalc(
	input  clk,
	inout  [7:0] JA,
	input 	reset,
	output [31:0] answer,
	
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5,
	
	output [9:0] LEDR
);

	// State machine states
	parameter fsm_IDLE 			= 3'd0; 		// Waiting for new token
	parameter fsm_SEND_NB		= 3'd1; 		// Sending token to NumberBuilder - Stage 1

	wire [3:0] decoded_token;				// Token from decoder
	reg [3:0] NB_token_sender;				// A place to store token to be sent to Number Builder

	reg NB_strobe; 						// Receiver enabler for Number Builder
	wire decoder_ready; 					// Decoder has decoded new token
			
	reg state = fsm_IDLE; 				// Current state
	reg next_state = fsm_IDLE;
	
	assign LEDR[0] = decoder_ready;
	
	//-----------------------------------------------
	//  		Keyboard Decoder
	//-----------------------------------------------
	Decoder C0(
			.clk(clk),
			.Row(JA[7:4]),
			.Col(JA[3:0]),
			.DecodeOut(decoded_token),
			.DecoderState(decoder_ready)
	);
	
	wire NB_write = (decoder_ready);
	
	//-----------------------------------------------
	//  		Number builder
	//			Makes number from sequence of digits
	//-----------------------------------------------
	NumberBuilder builder(
			.clk(clk),
			.strobe(decoder_ready),
			.clear(reset),
			.Token(decoded_token),
			.number(answer),
			.builder_ready(builder_ready)
	);

	
	//-----------------------------------------------
	//  		Seven Segment Display Controller
	//-----------------------------------------------
	/*DisplayController C1(
			.DispVal(answer),
			.segOut(seg1)
	);*/
	
	wire [ 31:0 ] h7segment = answer; //32'h00FFFFFF;
	
	assign HEX0 [7] = 1'b1;
   assign HEX1 [7] = 1'b1;
   assign HEX2 [7] = 1'b1;
   assign HEX3 [7] = 1'b1;
   assign HEX4 [7] = 1'b1;
   assign HEX5 [7] = 1'b1;
	
	sm_hex_display digit_5 ( h7segment [23:20] , HEX5 [6:0] );
   sm_hex_display digit_4 ( h7segment [19:16] , HEX4 [6:0] );
   sm_hex_display digit_3 ( h7segment [15:12] , HEX3 [6:0] );
   sm_hex_display digit_2 ( h7segment [11: 8] , HEX2 [6:0] );
   sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
   sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );
	
	
	//-----------------------------------------------
	//					State Machine
	//-----------------------------------------------
	
	/*		
	always @(state) begin
		case (state)
			fsm_IDLE : NB_token_sender <= 0;
			fsm_SEND_NB : NB_token_sender <= decoded_token;
			default: NB_token_sender <= decoded_token;
		endcase
	end

	
	always @(posedge clk or posedge reset) begin
		if (reset) state <= fsm_IDLE;
		else
			case (state)
				fsm_IDLE: 		state <= decoder_ready ? fsm_SEND_NB : fsm_IDLE;
				fsm_SEND_NB:	state <= builder_ready ? fsm_IDLE : fsm_SEND_NB;
			default: state <= fsm_IDLE;
			endcase
	end
	*/
	
endmodule