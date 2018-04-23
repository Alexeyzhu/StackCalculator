`timescale 1ns / 1ps

module VGABuffer(
	input clk,
	input [3:0] Token,
	input strobe,
	input clear,
	output reg [384:0] buffer = 0
);

always@(posedge clk) begin
	if (clear)
		buffer <= 0;		
	else if (strobe) begin								// If receiver enabled
		buffer <= (buffer << 4) + Token;
	end
end

endmodule