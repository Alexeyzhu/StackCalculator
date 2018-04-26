`timescale 1ns / 1ps

module VGABuffer(
	input clk,
	input [0:5] token_size,
	input [0:3] Token,
	input strobe,
	input clear,
	output reg [0:384] buffer = 0
);

always@(posedge clk) begin
	if (clear)
		buffer <= 0;		
	else if (strobe) begin								// If receiver enabled
		buffer <= (buffer >> token_size) + Token;
	end
end

endmodule