/*
	The main module for Stack Calculator
	Authors: 	a guy from GitHub
					Muhammad Mavlyutov
*/

`timescale 1ns / 1ps

module StackCalc(
	//input				clk,
	input MAX10_CLK1_50,
	input [9:0] 	SW,
	
	inout [7:0] 	JA,
	input [1:0] 	KEY,
	
	output [31:0] 	answer,
	
	output [7:0] 	HEX0,
	output [7:0] 	HEX1,
	output [7:0] 	HEX2,
	output [7:0] 	HEX3,
	output [7:0] 	HEX4,
	output [7:0] 	HEX5,
	output [9:0] 	LEDR,
	output VGA_HS, 
	output VGA_VS, 
	output [3:0] VGA_R, 
	output [3:0] VGA_G, 
	output [3:0] VGA_B
);

	wire clk = MAX10_CLK1_50;

	wire clk_25;

	pll_bb p(.inclk0(MAX10_CLK1_50), .c0(clk_25));

	
	wire reset = !KEY[0];

	// State machine states
	/*parameter state1 = 3'd1; 	// IDLE 		Waiting for new token
	parameter state2 = 3'd2; 	// NEW TOKEN 	Received new token
	parameter state3 = 3'd3; 	// SIGN 		New token is sign
	parameter state4 = 3'd4; 	// CALC 		Calculation
	parameter state5 = 3'd5; 	// WAIT RESET 	Result is ready, waiting for reset*/
	
	
	// Temporal registers
	reg [3:0] NB_token_sender;						// A place to store token to be sent to Number Builder
	reg [3:0] BUFF_token_sender;
	
	reg NB_send_clear = 1'b0;
	//reg last_token_is_SIGN = 1'b1;
	
	wire [31:0] built_number;
	
	
	reg [3:0] wr_control;
   reg [3:0] reg_wr_control;
   reg [3:0] VGA_token_sender;
   reg [31:0] ff_token_sender;
   reg VGA_clear;
   reg NB_clear;
   reg CALC_reset;
   //reg [7:0] state;
   //reg [7:0] next_state;
	reg [31:0] reg_asnwer;
	parameter wait_token=0,build=1,send_number=2,sender_wait_1=3,ff_send_equal=4,calc_wait=5,send_answer=6,wait_reset=7;
	
	
	// Helping signals
	wire decoder_ready; 							// Decoder has decoded new token
	wire [3:0] decoded_token;						// Token from decoder
	
	wire is_number = (decoded_token >= 4'h0 && decoded_token < 4'hA) ? 1'b1 : 1'b0;
	wire is_equal = (decoded_token == 4'hE) ? 1'b1 : 1'b0;
	//wire NB_clear = (NB_send_clear || reset) ? 1'b1 : 1'b0;
	
	wire calc_ready;
	wire builder_ready;
	
	// Outputs
	wire [383:0] vgabuff;
	
	assign LEDR[5] = (calc_ready);	
	assign LEDR[7] = (is_equal);
	assign LEDR[8] = (decoder_ready);
	assign LEDR[9] = (is_number);
	
	wire [82:0] control_signals;
	wire [7:0] state = control_signals[81:74];
	
		
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
			.strobe(control_signals[0]),
			.clear(control_signals [82]),
			.Token(decoded_token),
			.number(built_number),
			.builder_ready(builder_ready)
	);
	
	//-----------------------------------------------
	//  		VGA Buffer
	//			
	//-----------------------------------------------
	
	
	reg flag; 
	initial flag <= 1;
	reg a;
	initial a <= 0;
	
	always@(posedge clk)
	begin
		if(!a)
			a <= 1;
		else 
			flag = 0;	
	end
	
	
	VGABuffer buffer(
			.clk(clk),
			.strobe(control_signals[1]),
			.clear(reset),
			.token_size(control_signals[9:4]),
			.Token(control_signals[41:10]),
			.answ_flag(flag),
			.answ_input(32'hffffff4f),//hffffff0f),
			.buffer(vgabuff)
	);
	
	/*ffCalc ffCalc(
		.clk(clk),
		.strobe(control_signals[2]),
		.token(control_signals[73:42]),
		.ready(calc_ready),
		.answer(reg_answer)
		
	);*/
	
	state_machine state_machine(
		.clock(clk),
		.reset(reset),
		.decoder_ready(decoder_ready),
		.is_number(is_number),
		.is_equal(is_equal),
		.calc_ready(1'b1),//calc_ready),
		.decoded_token(decoded_token),
		.built_number(built_number),
		.calc_answer(reg_answer),
		/*.wr_control(wr_control),
		.VGA_token_sender(VGA_token_sender),
		.ff_token_sender(ff_token_sender),
		.VGA_clear(VGA_clear),
		.NB_clear(NB_clear),
		.CALC_reset(CALC_reset)*/
		.control_signals(control_signals)
	);
	
	
	VGAController controller(//.reset(KEY),
							 .numbers(vgabuff),
							 .clk(clk_25),
							 .vga_h_sync(VGA_HS), 
							 .vga_v_sync(VGA_VS), 
							 .vga_R(VGA_R), 
							 .vga_G(VGA_G),
							 .vga_B(VGA_B));
							 
	
	wire [ 31:0 ] h7segment = SW[0] ? vgabuff[31:0] : (SW[1] ? built_number : (SW[3] ? reg_answer : state)); //32'h00FFFFFF;
	
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
	
	

	
endmodule