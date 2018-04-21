`timescale 1ns / 1ps

module NumberBuilder(
	input clk,
	input [3:0] Token,
	input strobe,
	input clear,
	output [31:0] number,
	output builder_ready
);

reg state = 0;
reg [31:0] builder = 0;
assign number = builder;
assign builder_ready = state;


always@(posedge clk) begin
	state = 0;
	if (clear) 
		builder = 0;
	else if (strobe) begin								// If receiver enabled
		builder = (builder * 4'b1010) + Token;  	// build a number
		state = 1; 											// Leave a flag indicating that number building has finished
	end
end

endmodule