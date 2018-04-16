`timescale 1ns / 1ps

module StackCalc(
	input clk,
	inout [7:0] JA,
	output[31:0] answer,
	output [6:0] seg
);

	// Inputs
	reg strobe;
	reg [31:0] token;

	// Outputs
	wire ready;
	//wire [3:0] answer;
	
	reg [31:0] decoded_token;
	reg decoder_state;
	
	//-----------------------------------------------
	//  		Keyboard Decoder
	//-----------------------------------------------
	Decoder C0(
			.clk(clk),
			.Row(JA[7:4]),
			.Col(JA[3:0]),
			.DecodeOut(decoded_token),
			.DecoderState(decoder_state)
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
	//  		Seven Segment Display Controller
	//-----------------------------------------------
	DisplayController C1(
			.DispVal(token),
			.segOut(seg)
	);
		
		
	always @(posedge clk) begin
		if (decoder_state == 1) begin
			puttok(decoded_token);
			decoder_state <= 0;
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

endmodule