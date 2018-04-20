//http://www.fpga4fun.com/PongGame.html

module picture_generator
#(parameter maxInput = 384,
  parameter VIDEO_W	= 640,
  parameter VIDEO_H	= 480)
(clk, numbers, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B);

input clk;
input [15:0] numbers;

output vga_h_sync, vga_v_sync;
output [3:0] vga_R;
output [3:0] vga_G;
output [3:0] vga_B;

wire in_display_area;
wire [9:0] x;
wire [9:0] y;

VGA_sync sync_gen(.clk(clk), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
						.in_display_area(in_display_area), .x(x), .y(y));
				
reg [11:0] rgb_data;

//
//https://github.com/bogini/Pong/blob/master/font_test_gen.v#L22
// signal declaration
reg [5:0] char_addr;
wire [10:0] rom_addr;
wire [3:0] row_addr;
wire [2:0] bit_addr;
wire [7:0] font_word;
wire font_bit, text_bit_on;

// body
// instantiate font ROM
font_rom font_unit
(.clk(clk), .addr(rom_addr), .data_reg(font_word));
// font ROM interface

assign row_addr = y[3:0];
assign rom_addr = {char_addr, row_addr};
assign bit_addr = x[2:0];
assign font_bit = font_word[~bit_addr];

always@(*)
begin
if((y/16)*640 + x < maxInput * 2)
case(numbers[(y/16*80) + ((x+1)/8)*4 +:4])

	4'h0: char_addr <= 6'h30;
	4'h1: char_addr <= 6'h31;
	4'h2: char_addr <= 6'h32;
	4'h3: char_addr <= 6'h33;
	4'h4: char_addr <= 6'h34;
	4'h5: char_addr <= 6'h35;
	4'h6: char_addr <= 6'h36;
	4'h7: char_addr <= 6'h37;
	4'h8: char_addr <= 6'h38;
	4'h9: char_addr <= 6'h39;
	4'ha: char_addr <= 6'h2b;
	4'hb: char_addr <= 6'h2d;
	4'hc: char_addr <= 6'h2a;
	4'hd: char_addr <= 6'h2f;
	4'he: char_addr <= 6'h3d;
endcase

else char_addr <= 6'h00;

end

assign text_bit_on =  (y[9:8] == 0)? font_bit : 1'b0;

 // rgb multiplexing circuit
 always@(*)
   if (~in_display_area)
     rgb_data = 12'h000; // blank
   else
     if (text_bit_on)
        rgb_data = 12'h000;  // white
     else
        rgb_data = 12'hfff;  // black


assign vga_R=rgb_data[11:8];
assign vga_G=rgb_data[7:4];
assign vga_B=rgb_data[3:0]; 


endmodule