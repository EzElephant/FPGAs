module FPGAs(
    input clk,
    input rst,
    input MISO_1,
    input MISO_2,
    output SS_1,
    output SS_2,
    output MOSI_1,
    output MOSI_2,
    output SCLK_1,
    output SCLK_2,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output [7:0] LED,
    output [6:0] DISPLAY,
    output [3:0] DIGIT
);

wire move_left, move_right, move_up, move_down;
wire scroll_left, scroll_right, scroll_up, scroll_down;
wire [26:0] clk_div;
wire [7:0] rand_test;
wire [4:0] i, j;
reg [4:0] choose_x, choose_y, next_choose_x, next_choose_y;
reg [8:0] write_count, next_write_count;
reg [8:0] scroll_x, scroll_y, next_scroll_x, next_scroll_y;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]), .anim_clk(clk_div[21]), .final_pixel({vgaRed, vgaGreen, vgaBlue}), .hsync(hsync), .vsync(vsync));
LSFR random_gen(.clk(clk_div[23]), .rand_num(rand_test), .rst(rst));

assign LED = rand_test;

rocker1 rocker1(.clk(clk), .rst(rst), .MISO(MISO_1), .SS(SS_1), .MOSI(MOSI_1), .SCLK(SCLK_1),
.left(move_left), .right(move_right), .up(move_up), .down(move_down), .click(), .down_click());

rocker2 rocker2(.clk(clk), .rst(rst), .MISO(MISO_2), .SS(SS_2), .MOSI(MOSI_2), .SCLK(SCLK_2),
.left(scroll_right), .right(scroll_left), .up(scroll_up), .down(scroll_down), .click(), .down_click());

seven_segment Seven_segment(.clk_div(clk_div[15]), .data0(choose_x), .data1(choose_y), .DISPLAY(DISPLAY), .DIGIT(DIGIT));

always @(posedge clk) begin
    if (rst) begin
        choose_x <= 7;
        choose_y <= 7;
        scroll_x <= 0;
        scroll_y <= 0;
    end
    else begin
        choose_x <= next_choose_x;
        choose_y <= next_choose_y;
        scroll_x <= next_scroll_x;
        scroll_y <= next_scroll_y;
    end
end

always @(*) begin
    next_choose_x = choose_x;
    next_choose_y = choose_y;
    if (move_up && choose_y != 0)
        next_choose_y = choose_y - 1;
    if (move_down && choose_y != 14)
        next_choose_y = choose_y + 1;
    if (move_left && choose_x != 0)
        next_choose_x = choose_x - 1;
    if (move_right && choose_x != 19)
        next_choose_x = choose_x + 1;  
end

always @(*) begin
    next_scroll_x <= scroll_x;
    next_scroll_y <= scroll_y;
    if (scroll_up && choose_y != 0)
        next_scroll_y = choose_y - 1;
    if (scroll_down && choose_y != 480)
        next_scroll_y = choose_y + 1;
    if (scroll_left && choose_x != 0)
        next_scroll_x = choose_x - 1;
    if (scroll_right && choose_x != 640)
        next_scroll_x = choose_x + 1;  
end

endmodule

module LSFR(
    input rst,
    input clk,
    output reg [7:0] rand_num
);

reg [7:0] next_rand;

always @(posedge clk) begin
    if(rst)
        rand_num <= 8'b0001_1100;
    else
        rand_num <= next_rand;
end

always @(*) begin
    next_rand = {(rand_num[4] ^ rand_num[3] ^ rand_num[2]), rand_num[7:1]};
end

endmodule