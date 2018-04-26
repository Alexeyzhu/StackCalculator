`timescale 1ns / 1ps

module VGABuffer(
	input clk,
	input [5:0] token_size,
	input [3:0] Token,
	input strobe,
	input clear,
	output reg [384:0] buffer = 0
);

always@(posedge clk) begin
	if (clear)
		buffer <= 0;		
	else if (strobe) begin								// If receiver enabled
		buffer <= (buffer << token_size) + Token;
	end
end

endmodule