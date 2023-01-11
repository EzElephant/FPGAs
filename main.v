module FPGAs(
    input clk,
    input rst,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output [7:0] LED
);

wire [26:0] clk_div;
wire [7:0] rand_test;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]), .anim_clk(clk_div[21]), .final_pixel({vgaRed, vgaGreen, vgaBlue}), .hsync(hsync), .vsync(vsync));
LSFR random_gen(.clk(clk_div[23]), .rand_num(rand_test), .rst(rst));

assign LED = rand_test;

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