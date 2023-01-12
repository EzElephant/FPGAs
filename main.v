module FPGAs(
    input clk,
    input rst,
    input move_left,
    input move_right,
    input move_up,
    input move_down,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output [7:0] LED,
    output [6:0] DISPLAY,
    output [3:0] DIGIT
);

wire move_left_pulse, move_right_pulse, move_up_pulse, move_down_pulse;
wire [26:0] clk_div;
wire [7:0] rand_test;
wire [4:0] i, j;
reg [4:0] choose_x, choose_y,next_choose_x, next_choose_y;
reg [8:0] write_count, next_write_count;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]), .anim_clk(clk_div[21]), .final_pixel({vgaRed, vgaGreen, vgaBlue}), .hsync(hsync), .vsync(vsync));
LSFR random_gen(.clk(clk_div[23]), .rand_num(rand_test), .rst(rst));

assign LED = rand_test;

special_one_pulse special_one_pulse_left(.clk(clk), .pb_in(move_left), .pb_out(move_left_pulse));
special_one_pulse special_one_pulse_right(.clk(clk), .pb_in(move_right), .pb_out(move_right_pulse));
special_one_pulse special_one_pulse_up(.clk(clk), .pb_in(move_up), .pb_out(move_up_pulse));
special_one_pulse special_one_pulse_down(.clk(clk), .pb_in(move_down), .pb_out(move_down_pulse));

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
    if (move_up_pulse && choose_y != 0)
        next_choose_y = choose_y - 1;
    if (move_down_pulse && choose_y != 14)
        next_choose_y = choose_y + 1;
    if (move_left_pulse && choose_x != 0)
        next_choose_x = choose_x - 1;
    if (move_right_pulse && choose_x != 19)
        next_choose_x = choose_x + 1;  
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