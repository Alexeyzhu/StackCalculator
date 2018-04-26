`timescale 1ns / 1ps

module VGABuffer(
	input clk,
	input [0:5] token_size,
	input [0:3] Token,
	input strobe,
	input clear,
	input ans_flag,
	output reg [0:383] buffer
);

reg [9:0] index;
initial
begin
	index = 383;
	buffer = 384'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
end
 
always@(posedge clk) begin
	if (clear)
	begin
		buffer = 384'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;		
		index = 383;
	end
	else if (strobe) begin								// If receiver enabled
//		if (token == 4'hf)
//			buffer = 0;
		buffer[index -: 4] = Token;
		index = index - 4;
	end
end

endmodule