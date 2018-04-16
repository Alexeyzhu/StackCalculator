/*
	Shunting Yard Parser
	Outputs an RPN (postfix notation) expression from an infix input.
	Must enter an '=' at end of expression to flush stack to output queue.
	wr_en is used to enter a new token
	tokens are BCD 0 through 9, plus
		A : + (addition)
		B : - (subtraction)
		C : * (multiplication)
		D : / (division)
		E : = (equals)
		F : clear
	rd_en is used to read the next output from the queue
	By far, the most complicated part of this module is the logic to pop the
	function stack to the output queue. Addition and subtraction are lowest
	precedence, and will pop everything off the stack.  Multiplication and
	division will only pop off other multiplication and division operators,
	stopping at the first addition or subtraction encountered.  The euquals
	operator is special.  It will pop everything off the stack and then be
	pushed directly to the output queue.
*/

module ShuntingYard (

	input clk,					// clock
	input rd_en,				// active-high synchrounous read enable
	input wr_en,				// active-high synchronous write enable
	input [31:0] token,			// infix expression input

	output ready,				// active-high ready to accept next token
	output [31:0] output_queue	// postfix expression output
);

	reg [31:0] stack[0:31];
	reg [31:0] wr_index = 32'd0;
	reg [4:0] stack_pointer = 5'd0;

	// functions
	parameter token_ADD	= 32'h8000000A;
	parameter token_SUB	= 32'h8000000B;
	parameter token_MUL	= 32'h8000000C;
	parameter token_DIV	= 32'h8000000D;
	parameter token_EQU	= 32'h8000000E;
	parameter token_CLR	= 32'h8000000F;

	// shunting yard states
	parameter fsm_IDLE			= 3'd0; // waiting for token
	parameter fsm_PUSH_NUMBER	= 3'd1; // push numbers into output queue
	parameter fsm_OPERATOR		= 3'd2; // check operator precedence
	parameter fsm_PUSH_FUNCTION	= 3'd3; // push function onto stack
	parameter fsm_POP_FUNCTION  = 3'd4; // pop function from stack to output queue

	// helper signals
	wire clear = wr_en & (token_CLR==token);
	wire is_number = (output_queue < 32'h8000000A) | (output_queue > 32'h8000000F);
	wire is_equal = (token_EQU==token);
	wire pop = (stack_pointer > 0) && ( // check operator precedence
		(token_ADD==token) ||
		(token_SUB==token) ||
		((token_MUL[31:1]==token[31:1]) && (token_MUL[31:1]==stack[stack_pointer-1][31:1])) ||
		(token_EQU==token)
	);

	// shunting yard FSM
	reg [2:0] state = fsm_IDLE;
	reg [2:0] next_state = fsm_IDLE;
	
	always @(posedge clk) begin
	  if (clear) state <= fsm_IDLE;
	  else state <= next_state;
	end

	// next state logic
	always @* begin
	  case (state)
		// idle, wait for a token and parse
		fsm_IDLE  : if (wr_en) next_state = is_number ? fsm_PUSH_NUMBER : fsm_OPERATOR;
					else next_state = fsm_IDLE;

		// push number into output queue
		fsm_PUSH_NUMBER : next_state = fsm_IDLE;

		// push function onto stack
		// first check operator precedence, if the function on the stack is higher or equal precedence then pop it to the output queue
		// the '=' operator wil pop everything off the stack and then be pushed to the output queue
		fsm_OPERATOR : if (pop) next_state = fsm_POP_FUNCTION;
					   else next_state = is_equal ? fsm_PUSH_NUMBER : fsm_PUSH_FUNCTION; // push the '=' directly to the output queue
		fsm_POP_FUNCTION : next_state = fsm_OPERATOR; // pop function from stack to output queue
		fsm_PUSH_FUNCTION : next_state = fsm_IDLE; // push function onto stack

		default: next_state = fsm_IDLE;
	  endcase
	end

	// FSM outputs
	assign ready = (fsm_IDLE==state);

	// output queue
	reg [31:0] queue[0:31];
	always @(posedge clk) begin
		if (fsm_PUSH_NUMBER==state) queue[wr_index] <= token;
		else if (fsm_POP_FUNCTION==state) queue[wr_index] <= stack[stack_pointer-1];
	end

	
	always @(posedge clk) begin
		if (clear) wr_index <= 4'd0;
		else if ((fsm_PUSH_NUMBER==state) || (fsm_POP_FUNCTION==state)) wr_index <= wr_index + 1'd1;
	end

	reg [31:0] rd_index = 4'd0;
	always @(posedge clk) begin
		if (clear) rd_index <= 4'd0;
		else if (rd_en) rd_index <= rd_index + 1'd1;
	end
	assign output_queue = queue[rd_index];

	// function stack
	
	always @(posedge clk) begin
		if (fsm_PUSH_FUNCTION==state) stack[stack_pointer] <= token;
	end

	
	always @(posedge clk) begin
		if (clear) stack_pointer <= 5'd0;
		else if (fsm_PUSH_FUNCTION==state) stack_pointer <= stack_pointer + 1'd1;
		else if (fsm_POP_FUNCTION==state) stack_pointer <= stack_pointer - 1'd1;
	end

endmodule