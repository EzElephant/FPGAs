module FPGAs(
    input clk,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
);

wire clk_25MHz;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_25MHz));
VGA VGA(.clk_25MHz(clk_25MHz), .pixel({vgaRed, vgaGreen, vgaBlue}), .hsync(hsync), .vsync(vsync));


endmodule