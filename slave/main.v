module moduleName (
    input clk,
    input rst,
    input MISO,
    output SS,
    output MOSI,
    output SCLK,
    output move_left,
    output move_right,
    output move_up,
    output move_down
);

wire [26:0] clk_div;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));

rocker rocker1(.clk(clk), .clk_div(clk_div[2]), .rst(rst), .MISO(MISO), .SS(SS), .MOSI(MOSI), .SCLK(SCLK),
.left(move_left), .right(move_right), .up(move_up), .down(move_down), .click(), .down_click());

endmodule
