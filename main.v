module FPGAs(
    input clk,
    input vmir,
    input hmir,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
);

wire clk_25MHz, vaild;
wire [9:0] h_cnt, v_cnt;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_25MHz));
vga_controller VGA(.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), 
                    .valid(valid), .h_cnt(h_cnt), .v_cnt(v_cnt));




endmodule