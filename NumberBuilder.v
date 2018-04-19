`timescale 1ns / 1ps

module NumberBuilder(
	input clk,
	input [3:0] Token,
	input strobe,
	input reset,
	output reg [31:0] Number,
	// output reg [31:0] sign,
	output builder_ready
);

reg state;
reg [31:0] builder;
assign number = builder;
assign builder_ready = state;

always@(posedge clk) begin
	if (sstrobe)
		builder = (builder * 4'b1010) + Token;  // build a number
	state = 1;
	/*case (DecodeOut)
				4'b1111 : begin
				builded <= number;
				sign <= 32'h8000000F; //F Clr
				end
				4'b1110 : begin
				builded <= number;
				sign <= 32'h8000000E; //E Equal
				end
				4'b1111 : begin
				builded <= number;
				sign <= 32'h8000000D; //D Division
				end
				4'b1111 : begin
				builded <= number;
				sign <= 32'h8000000C; //C Multiplication
				end
				4'b1111 : begin
				builded <= number;
				sign <= 32'h8000000B; //B Subtraction
				end
				4'b1111 : begin
				builded <= number;
				sign <= 32'h8000000A; //A Addition
				end
				default: begin 
					number <= (number * 4'd10) + DecodeOut;  //build a number
				end 
	endcase*/

end

endmodule