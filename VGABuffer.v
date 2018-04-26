`timescale 1ns / 1ps

module VGABuffer(
	input clk,
	input [0:5] token_size,
	input [0:3] Token,
	input strobe,
	input clear,
	input answ_flag,
	input [0:31] answ_input,
	output reg answ_received,
	output reg [0:383] buffer
);

reg [9:0] index;
reg start;
initial
begin
	index = 383;
	buffer = 384'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
end

reg [31:0] answ;

reg   [31:0] counter;
reg   [3:0]  ones;
reg   [3:0]  tens;
reg   [3:0]  hundreds;
reg   [3:0]  thousands;
reg 	[3:0]  thousands10;
reg 	[3:0]  thousands100;
reg	[3:0]  millions;
reg	[3:0]  millions10;
reg	[3:0]  millions100;
reg	[3:0]  billions;

always@(posedge clk) begin
	if (clear)
	begin
		buffer = 384'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;		
		index = 383;
	end
	else
	begin
		if (strobe && !start && !answ_flag) begin								// If receiver enabled
			buffer[index -: 4] = Token;
			index = index - 4;
		end
		
		if(answ_flag)begin 
			start = 1'b1;
			counter <= 32'b0;
			//buffer[index -: 4] = 4'he;
			//index = index - 4;
			answ = answ_input;
			if(answ[31] == 1) begin
				answ = ~(answ - 1);
				buffer[index -: 4] = 4'hb; // - sign
				index = index - 4;
			end
						
		end		
		
		if(start)
		begin
			if(counter == answ) begin
				answ_received = 1;	
				
				if(billions != 0) begin
					buffer[index -: 4] = billions;
					index = index - 4;	
				end
				if(millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = millions100;
					index = index - 4;	
				end
				if(millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = millions10;
					index = index - 4;	
				end
				if(millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = millions;
					index = index - 4;	
				end
				if(thousands100 != 0 || millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = thousands100;
					index = index - 4;	
				end
				if(thousands10 != 0 || thousands100 != 0 || millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = thousands10;
					index = index - 4;	
				end
				if(thousands != 0 || thousands10 != 0 || thousands100 != 0 || millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = thousands;
					index = index - 4;					
				end
				if(hundreds != 0 || thousands != 0 || thousands10 != 0 || thousands100 != 0 || millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = hundreds;
					index = index - 4;
				end
				if(tens != 0 || hundreds != 0 || thousands != 0 || thousands10 != 0 || thousands100 != 0 || millions != 0 || millions10 != 0 ||  millions100 != 0 ||  billions != 0) begin
					buffer[index -: 4] = tens;
					index = index - 4;
				end
				buffer[index -: 4] = ones;
				index = index - 4;		
				
				
				start = 0;
				
			end
			else begin
				counter <= counter + 1;
				ones <= ones == 9 ? 0 : ones + 1;
				if(ones == 9) begin
					tens <= tens == 9 ? 0 : tens + 1;
					if(tens == 9) begin
						hundreds <= hundreds == 9 ? 0 : hundreds + 1;
						if(hundreds == 9) begin
                     thousands <= thousands == 9 ? 0 : thousands + 1; 
							if(thousands == 9) begin
								thousands10 <= thousands10 == 9 ? 0 : thousands10 + 1;
								if(thousands10 == 9) begin
									thousands100 <= thousands100 == 9 ? 0 :  thousands100 + 1;
									if(thousands100 == 9) begin
										millions <= millions == 9 ? 0 :  millions + 1;
										if(millions == 9) begin
											millions10 <= millions10 == 9 ? 0 :  millions10 + 1;
											if(millions10 == 9) begin
												millions100 <= millions100 == 9 ? 0 : millions100 + 1;
												if(billions == 9) 
													billions <= billions == 9 ? 0 :  billions + 1;
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end	
end

endmodule