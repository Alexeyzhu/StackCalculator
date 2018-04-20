/*
	The main module for Stack Calculator
	Authors: 	a guy from GitHub
					Muhammad Mavlyutov
*/

`timescale 1ns / 1ps

module StackCalc(
	input  clk,
	inout  [7:0] JA,
	output [31:0] answer,
	output [6:0] seg,
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
);


	// StackCalc states
	parameter fsm_IDLE			= 3'd0; // waiting for token
	parameter fsm_PR_TOKEN		= 3'd1; // Processing token
	parameter fsm_WAIT_NB 		= 3'd2; // Wait till Number Builder will be ready to get new token
	parameter fsm_CALC 			= 3'd3; // Calculation in progress
 	
	
	
	// Inputs
	reg strobe;
	reg [31:0] token;
	reg NB_strobe;

	// Outputs
	wire ready;
	wire builder_ready;
	//wire [3:0] answer;
	
	reg [3:0] state = fsm_IDLE;
	reg [3:0] next_state = fsm_IDLE;
	
	wire [31:0] decoded_token;
	wire decoder_ready;
	
	reg [3:0] token_sender;
	
	
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
	
	NumberBuilder builder(
			.clk(clk),
			.strobe(NB_strobe),
			.Token(token_sender),
			.Number(builded),
			.builder_ready(builder_ready)
	);
	
	//-----------------------------------------------
	//			Four Function Calculator
	//-----------------------------------------------
	ffCalc ff_calc(
		.clk(clk),
		.strobe(strobe),
		.token(token),
		.ready(ready),
		.answer(answer)
	);
	
	//-----------------------------------------------
	//  		VGA Display Controller
	//-----------------------------------------------
	VGA vga(
			.MAX10_CLK1_50(clk),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B)
	);
	
	
	wire is_number = (decoded_token < 4'b1010) & (decoded_token >= 4'b0000);
	
	wire is_equal = (decoded_token < 4'b1111) & (decoded_token > 4'b1101);
	
	
	always @(posedge clk) begin
		//if (clear) state <= fsm_IDLE;
		//else 
		state <= next_state;
   end
	
	 // next state logic
   always @* begin
		case (state)
			fsm_IDLE:		next_state = decoder_ready ? fsm_PR_TOKEN : fsm_IDLE;
			
			fsm_PR_TOKEN:	next_state = is_number ? fsm_WAIT_NB : (is_equal ? fsm_CALC : fsm_IDLE);
									
			fsm_WAIT_NB: 	next_state = builder_ready ? fsm_IDLE : fsm_WAIT_NB;

			fsm_CALC: 		next_state = ready ? fsm_IDLE : fsm_CALC;

		default: next_state = fsm_IDLE;
		endcase
	end
	
	always @(posedge clk) begin
			if (state == fsm_PR_TOKEN) begin
					if (is_number) 
					begin
						// Token is digit
						NB_strobe = 1;
						token_sender = decoded_token;
						//next_state = fsm_WAIT_NB;
					end
					else begin
						// Token is sign
						puttok(builded);
						case (decoded_token)
							4'b1010: puttok(32'h8000000A); // +
							4'b1011: puttok(32'h8000000B); // -
							4'b1100: puttok(32'h8000000C); // *
							4'b1101: puttok(32'h8000000D); // /
							4'b1110: begin 
								puttok(32'h8000000E); 			// =
								// next_state = fsm_CALC;
							end
							4'b1111: puttok(32'h8000000F); // CLR
						endcase
				end
			end
	end
		
	// 40MHz clock
	//always begin
	//	#12 clk = 0;
	//	#13 clk = 1;
	//end
	
	initial $monitor ("Ans = %d", answer);
	initial begin
		// create files for waveform viewer
		$dumpfile("ff_calc.lxt");
		$dumpvars;

		// Initialize Inputs
		//clk = 1;
		strobe = 0;
		token = 32'h0;

		// 18 + 4 =
		puttok(32'h8000000F); // clear
		puttok(32'd18); // 3
		puttok(32'h8000000A); // +
		puttok(32'd9); // 4
		puttok(32'h8000000E); // =

		// 7 - 8 / 4 =
		puttok(32'h8000000F); // clear
		puttok(4'h7); // 7
		puttok(32'h8000000B); // -
		puttok(4'h8); // 8
		puttok(32'h8000000D); // /
		puttok(4'h4); // 4
		puttok(32'h8000000E); // =

		// 3 + 4 * 2 - 1 =
		puttok(32'h8000000F); // clear
		puttok(4'h3); // 3
		puttok(32'h8000000A); // +
		puttok(4'h4); // 4
		puttok(32'h8000000C); // *
		puttok(4'h2); // 2
		puttok(32'h8000000B); // -
		puttok(4'h1); // 1
		puttok(32'h8000000E); // =

		// Finished
		#100 $display("finished");
		$finish;
	end

	// Send token to ffcalc
	task puttok;
		input [31:0] value;
		begin
			$display("New token: %d", value);
			wait(!clk) #1 token = value;
			wait(clk) #1 strobe = 1;
			wait(!clk);
			wait(clk) #1 strobe = 0;
			wait(!clk);
			wait(ready);
		end
	endtask
	
	// Send digit to Number Builder
	task putdig;
		input [3:0] value;
		begin
			$display("New token: %d", value);
			wait(!clk) #1 token = value;
			wait(clk) #1 strobe = 1;
			wait(!clk);
			wait(clk) #1 strobe = 0;
			wait(!clk);
			wait(ready);
		end
	endtask

endmodule