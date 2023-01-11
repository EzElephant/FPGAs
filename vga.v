`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////


module vga(
    input clk_25MHz,
    input anim_clk,
    output reg [11:0] final_pixel,
    output hsync,
    output vsync
);

wire valid;
wire [9:0] h_cnt, v_cnt;
wire [11:0] pixel;
wire [11:0] knight_pixel;
wire [11:0] wizard_pixel;
reg [11:0] first_layer_pixel;
reg [13:0] pixel_addr;
reg [12:0] knight_addr;
reg [12:0] wizard_addr;
reg [8:0] map_addr;
reg [3:0] write_texture_num;
wire [3:0] texture_num;

// view starting point
// reg [x:0] start;

// record which block has knight
// in 20 * 15 map, 0 for h_cnt, 1 for v_cnt
reg [8:0] action_pos;
reg [8:0] selected_pos = 125;
reg [8:0] knight_pos = 125; 
reg [8:0] wizard_pos = 167;

// animation counter
reg [3:0] animation_count;

// animation frames
reg [2:0] knight_anim_num, next_knight_anim;
reg [2:0] wizard_anim_num, next_wizard_anim;


vga_controller VGA(.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), 
                    .valid(valid), .h_cnt(h_cnt), .v_cnt(v_cnt));

blk_mem_gen_0 blk_mem_gen_0_inst(.clka(clk_25MHz), .addra(pixel_addr), .douta(pixel));
blk_mem_gen_1 map_num(.clka(clk_25MHz), .addra(map_addr), .wea(1'b0), .dina(write_texture_num), .douta(texture_num));
blk_mem_gen_2 knight_num(.clka(clk_25MHz), .addra(knight_addr), .douta(knight_pixel));
blk_mem_gen_3 wizard_num(.clka(clk_25MHz), .addra(wizard_addr), .douta(wizard_pixel));


// map_addr
always @(*) begin
    map_addr = (h_cnt >> 5) + 20 * (v_cnt >> 5);
end

// knight addr
always @(*) begin 
    knight_addr = (h_cnt & 5'b11111) + 32 * ((v_cnt & 5'b11111) + knight_anim_num * 32);
end

// wizard addr
always @(*) begin 
    wizard_addr = (h_cnt & 5'b11111) + 32 * ((v_cnt & 5'b11111) + wizard_anim_num * 32);
end

// background addr
always @(*) begin
    pixel_addr = (h_cnt & 5'b11111) + 32 * ((v_cnt & 5'b11111) + texture_num * 32);
end

// first_layer
always @(*) begin
    if(map_addr == knight_pos)
        if((v_cnt & 5'b11111) < 2)  // 2 pixel for blood
            first_layer_pixel = 12'hB00;
        else if(knight_pixel != 12'h000)
            first_layer_pixel = knight_pixel;
        else
            first_layer_pixel = pixel;
    else if(map_addr == wizard_pos)
        if((v_cnt & 5'b11111) < 2)  // 2 pixel for blood
            first_layer_pixel = 12'hB00;
        else if(wizard_pixel != 12'h000)
            first_layer_pixel = wizard_pixel;
        else
            first_layer_pixel = pixel;
    else
        first_layer_pixel = pixel;
end

// final_pixel
always @(*) begin
    if (valid)
        // if this block has player
        if(map_addr == selected_pos)
            if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                final_pixel = 12'h4Af;
            else
                final_pixel = first_layer_pixel + 12'h010;
        else
            final_pixel = first_layer_pixel;
    else
        final_pixel = 0;
end

// TODO...
// action character position
always @(posedge clk_25MHz) begin
    action_pos <= knight_pos;
end

// animation counter
always @(posedge anim_clk) begin
    animation_count <= animation_count + 1;
end

// knight animation num
always @(posedge clk_25MHz) begin
    knight_anim_num <= next_knight_anim;
end

always @(*) begin
    // case(state)
    //     attack:
                // if(animation_count < 4)
                //     next_knight_anim = 2;
                // else if(animation_count < 8)
                //     next_knight_anim = 3;
                // else if(animation_count < 12)
                //     next_knight_anim = 4;
                // else 
                //     next_knight_anim = 5;
    //     idle:
                if(animation_count < 8)
                    next_knight_anim = 0;
                else 
                    next_knight_anim = 1;
    // endcase
end

// wizard animation num
always @(posedge clk_25MHz) begin
    wizard_anim_num <= next_wizard_anim;
end

always @(*) begin
    // case(state)
    //     attack:
                // anim_num 2~6
                // if(animation_count < 4)
                //     next_wizard_anim = 2;
                // else if(animation_count < 8)
                //     next_wizard_anim = 3;
                // else if(animation_count < 12)
                //     next_wizard_anim = 4;
                // else 
                //     next_wizard_anim = 5;
    //     idle:
                if(animation_count < 8)
                    next_wizard_anim = 0;
                else 
                    next_wizard_anim = 1;
    // endcase
end


endmodule

module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;

endmodule
