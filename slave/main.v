module slave (
    input clk,
    input rst,
    input MISO_1, // for rocker
    input MISO_2, // for rocker
    output SS_1, // for rocker
    output SS_2, // for rocker
    output MOSI_1, // for rocker
    output MOSI_2, // for rocker
    output SCLK_1, // for rocker
    output SCLK_2, // for rocker
    output l_move_left, // left rocker output
    output l_move_right, // left rocker output
    output l_move_up, // left rocker output
    output l_move_down, // left rocker output
    output l_click, // left rocker output
    output l_downclick, // left rocker output
    output r_move_left, // right rocker output
    output r_move_right, // right rocker output
    output r_move_up, // right rocker output
    output r_move_down // right rocker output
);

wire l_left, l_right, l_down, l_up, r_left, r_right, r_down, r_up;
wire [26:0] clk_div;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));

rocker1 rocker1(.clk(clk), .clk_div(clk_div[2]), .rst(rst), .MISO(MISO_1), .SS(SS_1), .MOSI(MOSI_1), .SCLK(SCLK_1),
.left(l_left), .right(l_right), .up(l_up), .down(l_down), .click(l_click), .down_click(l_down_click));

sender sender_l_move_left(.clk(clk), .rst(rst), .source(l_left), .source_out(l_move_left));
sender sender_l_move_right(.clk(clk), .rst(rst), .source(l_right), .source_out(l_move_right));
sender sender_l_move_up(.clk(clk), .rst(rst), .source(l_up), .source_out(l_move_up));
sender sender_l_move_down(.clk(clk), .rst(rst), .source(l_down), .source_out(l_move_down));

rocker2 rocker2(.clk(clk), .clk_div(clk_div[2]), .rst(rst), .MISO(MISO_2), .SS(SS_2), .MOSI(MOSI_2), .SCLK(SCLK_2),
.left(r_left), .right(r_right), .up(r_up), .down(r_down), .click(), .down_click());

sender sender_r_move_left(.clk(clk), .rst(rst), .source(r_left), .source_out(r_move_left));
sender sender_r_move_right(.clk(clk), .rst(rst), .source(r_right), .source_out(r_move_right));
sender sender_r_move_up(.clk(clk), .rst(rst), .source(r_up), .source_out(r_move_up));
sender sender_r_move_down(.clk(clk), .rst(rst), .source(r_down), .source_out(r_move_down));

endmodule
