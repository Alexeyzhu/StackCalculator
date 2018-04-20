module VGABuffer
	(
	input [3:0] symbol,
	input symbol_flag,
	input [31:0] answer,
	input ans_flag,
	output symbol_received,
	output ans_received,
	output reg [799:0] token_to_vga
	);
	
	reg [9:0] index;
	reg [9:0] radix [3:0];
	reg [31:0] a;
	
	initial index <= 0;
	
	always@(symbol_flag) begin
		symbol_received = 0;
		if (symbol == 4'hf)
			token_to_vga = 0;
			
		token_to_vga[index +: 4] = symbol;
		symbol_received = 1;
		index = index + 4;
	end
	
	reg not_zero;
	
	always@(ans_flag)
	begin
		ans_received = 0;
		a = answer;
		token_to_vga[index +: 4] = 4'he; // = sign
		index = index + 4;
		
		if(a == 0) 
		begin 
			token_to_vga[index +: 4] = 4'h0;
			index = index + 4;
		end
		
		else 
		begin
			not_zero = 0;
			
			if(a[31] == 1)
			begin
				a = ~(a - 1);
				token_to_vga[index +: 4] = 4'hb; // - sign
				index = index + 4;
			end
		
			for(i=0, i < 10, i = i + 1 )begin
				radix[9-i] = a%(10**(i+1);
				a = a/10**(i+1);
			end
		
			for(i=0, i<10, i++)
			begin
				if(radix[i] != 0 || not_zero)
					begin
					not_zero = 1;
					token_to_vga[index +: 4] = radix[i];
					index = index + 4;
					end
			end		
		
		end
		ans_received = 1;
	end

endmodule