module state_machine (
    clock,reset,decoder_ready,built_number[31:0],is_number,calc_ready,is_equal,calc_answer[31:0],decoded_token[3:0],
    control_signals[49:0]);

    input clock;
    input reset;
    input decoder_ready;
    input is_number;
    input calc_ready;
    input is_equal;
	 input [31:0] built_number;
	 input [31:0] calc_answer;
	 input [3:0] decoded_token;
    tri0 reset;
    tri0 decoder_ready;
    tri0 is_number;
	 tri0 [31:0] built_number;
    tri0 [31:0] calc_answer;
    tri0 calc_ready;
    tri0 is_equal;
	 tri0 [3:0] decoded_token;
    output [49:0] control_signals;
    reg [49:0] control_signals;
    reg [49:0] reg_control_signals = 50'b0;
    reg [7:0] fstate;
    reg [7:0] reg_fstate;
	 reg last_token_is_SIGN = 1;
    parameter wait_token=0,build=1,send_number=2,sender_wait_1=3,ff_send_equal=4,calc_wait=5,send_answer=6,wait_reset=7;


    always @(posedge clock)
    begin
        if (clock) begin
            fstate <= reg_fstate;
        end
    end

    always @(fstate or reset or decoder_ready or is_number or calc_ready or is_equal or reg_control_signals)
    begin
        if (reset) begin
            reg_fstate <= wait_token;
            reg_control_signals <= 50'b0;
            control_signals <= 50'b0;
        end
        else begin
            reg_control_signals <= 50'b0;
            control_signals <= 50'b0;
				control_signals[49:43] <= fstate;
            case (fstate)
                wait_token: begin
                    if ((decoder_ready & is_number))
                        reg_fstate <= build;
                    else if (((decoder_ready & ~(is_number)) & ~(last_token_is_SIGN)))
                        reg_fstate <= send_number;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= wait_token;
                end
                build: begin
                    reg_fstate <= wait_token;
						  last_token_is_SIGN <= 0;
                    reg_control_signals [7:4] <= decoded_token;
                    reg_control_signals [3:0] <= 4'b0011;;
                end
                send_number: begin
                    reg_fstate <= sender_wait_1;
						  last_token_is_SIGN <= 1;
                    reg_control_signals [7:4] <= decoded_token; // send sign
                    reg_control_signals [39:8] <= built_number;
                    reg_control_signals [3:0] <= 4'b0110;
                end
                sender_wait_1: begin
                    if ((calc_ready & is_equal))
                        reg_fstate <= ff_send_equal;
                    else if ((calc_ready & ~(is_equal)))
                        reg_fstate <= wait_token;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= sender_wait_1;
                end
                ff_send_equal: begin
                    reg_fstate <= calc_wait;
                    reg_control_signals [39:8] <= 32'h8000000E;
                    reg_control_signals [3:0] <= 4'b0100;
                end
                calc_wait: begin
                    if (calc_ready)
                        reg_fstate <= send_answer;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= calc_wait;
                end
                send_answer: begin
                    reg_fstate <= wait_reset;

                    reg_control_signals [7:4] <= calc_answer;

                    reg_control_signals [3:0] <= 4'b0010;
                end
                wait_reset: begin
                    reg_fstate <= wait_reset;

                    reg_control_signals [40] <= 1'b1;

                    reg_control_signals [41] <= 1'b1;
                end
            endcase
            control_signals <= reg_control_signals;
        end
    end
endmodule // state_machine
