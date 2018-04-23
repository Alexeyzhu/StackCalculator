/*
	The main module for Stack Calculator
	Authors: 	a guy from GitHub
					Muhammad Mavlyutov
*/

`timescale 1ns / 1ps

module StackCalc(
	input clk,
	input [9:0] SW,
	
	inout [7:0] JA,
	input [1:0] KEY,
	
	output [31:0] answer,
	
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5,
	output [9:0] LEDR
);

	wire reset = !KEY[0];

	// State machine states
	parameter s1 			= 3'd0; 	// IDLE 			Waiting for new token
	parameter s2 			= 3'd1; 	// NEW TOKEN 	Received new token
	parameter s3			= 3'd2; 	// SIGN 			New token is sign
	parameter s4			= 3'd3; 	// CALC 			Calculation
	parameter s5			= 3'd4; 	// WAIT RESET 	Result is ready, waiting for reset
	
	
	// Temporal registers
	reg [3:0] NB_token_sender;						// A place to store token to be sent to Number Builder
	reg NB_strobe; 									// Receiver enabler for Number Builder			
	reg [3:0] state = s1;	 							// Current state
	reg NB_send_clear = 1'b0;
	reg last_token_is_SIGN = 1'b1;
	
	
	// Helping signals
	wire decoder_ready; 							// Decoder has decoded new token
	wire [3:0] decoded_token;						// Token from decoder
	
	wire is_number = (decoded_token >= 4'h0 && decoded_token < 4'hA) ? 1'b1 : 1'b0;
	wire is_equal = (decoded_token == 4'hE) ? 1'b1 : 1'b0;
	wire NB_clear = (NB_send_clear || reset) ? 1'b1 : 1'b0;
	
	wire NB_write = (state==s1 && decoder_ready && is_number);
	wire BUFF_write = decoder_ready && ( (state==s1 && is_number) || (state==s3 && !is_number && !last_token_is_SIGN) );
	
	wire builder_ready;
	
	// Outputs
	wire [384:0] vgabuff;
	
	assign LEDR[5] = last_token_is_SIGN;	
	assign LEDR[7] = (is_equal);
	assign LEDR[8] = (decoder_ready);
	assign LEDR[9] = (is_number);
	
		
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

		
	//-----------------------------------------------
	//  		Number builder
	//			Makes number from sequence of digits
	//-----------------------------------------------
	NumberBuilder builder(
			.clk(clk),
			.strobe(NB_write),
			.clear(NB_clear),
			.Token(decoded_token),
			.number(answer),
			.builder_ready(builder_ready)
	);
	
	//-----------------------------------------------
	//  		VGA Buffer
	//			
	//-----------------------------------------------
	VGABuffer buffer(
			.clk(clk),
			.strobe(BUFF_write),
			.clear(reset),
			.Token(decoded_token),
			.buffer(vgabuff)
	);
	
	
	wire [ 31:0 ] h7segment = SW[0] ? vgabuff[31:0] : (SW[1] ? answer : state); //32'h00FFFFFF;
	
	assign HEX0 [7] = 1'b1;
   assign HEX1 [7] = 1'b1; 
   assign HEX2 [7] = 1'b1;
   assign HEX3 [7] = 1'b1;
   assign HEX4 [7] = 1'b1;
   assign HEX5 [7] = 1'b1;
	
	assign LEDR[0] = state == s1;
	assign LEDR[1] = state == s2;
	assign LEDR[2] = state == s3;
	assign LEDR[3] = state == s4;
	assign LEDR[4] = state == s5;
	
	sm_hex_display digit_5 ( h7segment [23:20] , HEX5 [6:0] );
   sm_hex_display digit_4 ( h7segment [19:16] , HEX4 [6:0] );
   sm_hex_display digit_3 ( h7segment [15:12] , HEX3 [6:0] );
   sm_hex_display digit_2 ( h7segment [11: 8] , HEX2 [6:0] );
   sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
   sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );
	
	
	//-----------------------------------------------
	//					State Machine
	// s1 		= 3'd0 	IDLE 			Waiting for new token
	// s2 		= 3'd1 	NEW TOKEN 	Received new token
	// s3			= 3'd2 	SIGN 			New token is sign
	// s4			= 3'd3 	CALC 			Calculation
	// s5			= 3'd4 	WAIT RESET 	Result is ready, waiting for reset
	//-----------------------------------------------
	
	// Acting according to step
	always @(state or reset) begin
	if (reset) 
	begin
		last_token_is_SIGN <= 1'b1;
		NB_send_clear <= 1'b1;
	end
	else
	begin
			NB_send_clear = 1'b0;
			case (state)
			s1: 	begin
						last_token_is_SIGN = 0;
					end
			s2:	begin
					end
			s3:	begin
						last_token_is_SIGN = 1;
						NB_send_clear = 1'b1;
					end
			s4:	begin
					end
			s5:	begin
					end
			endcase
	end
	end
	
	// State mover
	always @(*) begin
		if (reset) begin
			state = s1;
		end 
		else
		begin
			case (state)
				s1: 	begin			
							if (decoder_ready) 
							begin
								if (is_number) begin
									state = s1; 
								end
								else 
								begin
									if (is_equal)
									begin
										state = s4;
									end
									else
									begin
										state = s3;
									end
								end
							end
						end
						
				s2:	begin					
						end
						
				s3:	begin
							if (decoder_ready)
								if (is_number)
									state = s1;
						end
						
				s4:	begin
							state = s5;
						end
						
				s5:	begin
							if (reset)
								state = s1;
						end
			endcase
		end
	end

	
endmodule