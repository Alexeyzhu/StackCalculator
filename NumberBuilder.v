`timescale 1ns / 1ps

module NumberBuilder(
	input clk,
	input [3:0] Token,
	input strobe,
	input clear,
	output reg [31:0] number,
	output reg builder_ready
);

always@(posedge clk) begin
	if (strobe) begin								// If receiver enabled
		//number = (number * 4'b1010) + Token;  	// build a number
		number <= (number << 4) + Token;
		//number <= Token;
		builder_ready <= 1; 											// Leave a flag indicating that number building has finished
	end
end

endmodule