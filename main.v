module FPGAs(
    input clk,
    input rst,
    input MISO,
    output SS,
    output MOSI,
    output SCLK,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output [6:0] DISPLAY,
    output [3:0] DIGIT
);

wire  move_left, move_right, move_up, move_down;
wire [26:0] clk_div;
wire [4:0] i, j;
reg [4:0] choose_x, choose_y,next_choose_x, next_choose_y;
reg [8:0] write_count, next_write_count;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]), .final_pixel({vgaRed, vgaGreen, vgaBlue}), .hsync(hsync), .vsync(vsync));

rocker rocker1(.clk(clk), .rst(rst), .MISO(MISO), .SS(SS), .MOSI(MOSI), .SCLK(SCLK),
.left(move_left), .right(move_right), .up(move_up), .down(move_down), .click(), .down_click());

seven_segment Seven_segment(.clk_div(clk_div[15]), .data0(choose_x), .data1(choose_y), .DISPLAY(DISPLAY), .DIGIT(DIGIT));

always @(posedge clk) begin
    if (rst) begin
        choose_x <= 7;
        choose_y <= 7;
    end
    else begin
        choose_x <= next_choose_x;
        choose_y <= next_choose_y;
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


endmodule