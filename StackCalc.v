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
	
	output [6:0] seg 
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
	
	wire NB_write = (state == fsm_SEND_NB && clk && decoder_ready);
	
	//-----------------------------------------------
	//  		Number builder
	//			Makes number from sequence of digits
	//-----------------------------------------------
	NumberBuilder builder(
			.clk(clk),
			.strobe(NB_write),
			.clear(reset),
			.Token(NB_token_sender),
			.number(answer),
			.builder_ready(builder_ready)
	);
	
	
	//-----------------------------------------------
	//  		Seven Segment Display Controller
	//-----------------------------------------------
	DisplayController C1(
			.DispVal(builder_ready),
			.segOut(seg)
	);
	
	
	
	//-----------------------------------------------
	//					State Machine
	//-----------------------------------------------
			
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
	
	
endmodule