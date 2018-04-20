
module VGA(MAX10_CLK1_50, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);

input MAX10_CLK1_50;
output VGA_HS;
output VGA_VS;
output [3:0] VGA_R;
output [3:0] VGA_G;
output [3:0] VGA_B;

wire clk_25;

pll p(.inclk0(MAX10_CLK1_50), .c0(clk_25));

reg [383:0] numbers;

always@* numbers <= 384'h190419041904190419041904190419041904190419041904190419041904190419041904190419041904190419041904;

picture_generator p_g(//.reset(KEY),
							 .numbers(numbers),
							 .clk(clk_25),
							 .vga_h_sync(VGA_HS), 
							 .vga_v_sync(VGA_VS), 
							 .vga_R(VGA_R), 
							 .vga_G(VGA_G),
							 .vga_B(VGA_B));


endmodule