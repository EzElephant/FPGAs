module FPGAs(
    input clk,
    input rst,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
);

integer i, j;

wire clk_25MHz, vaild;
wire [9:0] h_cnt, v_cnt;
reg [3:0] pic_num [0:19] [0:14];  

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_25MHz));

vga_controller VGA(.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), 
                    .valid(valid), .h_cnt(h_cnt), .v_cnt(v_cnt));

always @(*) begin
    if(rst)
        for(i = 0;i < 20;i = i + 1)
            for(j = 0;j < 15;j = j + 1)
                pic_num[i][j] = 1;
    else    
        for(i = 0;i < 20;i = i + 1)
            for(j = 0;j < 15;j = j + 1)
                pic_num[i][j] = 1;
end





endmodule