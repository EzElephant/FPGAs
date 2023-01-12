`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////


module vga(
    input clk_25MHz,
    input [3:0] animation_count,
    input [1:0] player_state,
    input [1:0] knight_state,
    input [1:0] wizard_state,
    input monster_state,
    input [8:0] action_pos,
    input [8:0] selected_pos,
    input [8:0] knight_pos,
    input [8:0] wizard_pos,
    output reg [11:0] final_pixel,
    output hsync,
    output vsync
);

wire valid;
wire [9:0] h_cnt, v_cnt;
wire [11:0] pixel;
wire [11:0] knight_pixel;
wire [11:0] wizard_pixel;
wire [11:0] skeleton_pixel;
wire [11:0] eye_pixel;
wire [11:0] goblin_pixel;
wire [11:0] mushroom_pixel;
reg [11:0] first_layer_pixel;
reg [13:0] pixel_addr;
reg [12:0] knight_addr;
reg [12:0] wizard_addr;
reg [12:0] monster_addr;
reg [8:0] map_addr;
reg [3:0] write_texture_num;
wire [3:0] texture_num;

parameter move = 2'b00;
parameter attack = 2'b01;
parameter hit = 2'b10;
parameter idle = 2'b11;

// view starting point
// reg [x:0] start;

reg [8:0] skeleton_pos [3:0];
reg [8:0] eye_pos [3:0];
reg [8:0] goblin_pos [3:0];
reg [8:0] mushroom_pos [3:0];

// animation frames
reg [2:0] knight_anim_num, next_knight_anim;
reg [2:0] wizard_anim_num, next_wizard_anim;
reg [2:0] monster_anim_num, next_monster_anim;

// integers
integer i;


vga_controller VGA(.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), 
                    .valid(valid), .h_cnt(h_cnt), .v_cnt(v_cnt));

blk_mem_gen_0 blk_mem_gen_0_inst(.clka(clk_25MHz), .addra(pixel_addr), .douta(pixel));
blk_mem_gen_1 map_num(.clka(clk_25MHz), .addra(map_addr), .wea(1'b0), .dina(write_texture_num), .douta(texture_num));
blk_mem_gen_2 knight_num(.clka(clk_25MHz), .addra(knight_addr), .douta(knight_pixel));
blk_mem_gen_3 wizard_num(.clka(clk_25MHz), .addra(wizard_addr), .douta(wizard_pixel));
blk_mem_gen_4 skeleton_num(.clka(clk_25MHz), .addra(monster_addr), .douta(skeleton_pixel));
blk_mem_gen_5 eye_num(.clka(clk_25MHz), .addra(monster_addr), .douta(eye_pixel));
blk_mem_gen_6 goblin_num(.clka(clk_25MHz), .addra(monster_addr), .douta(goblin_pixel));
blk_mem_gen_7 mushroom_num(.clka(clk_25MHz), .addra(monster_addr), .douta(mushroom_pixel));

// attach gamecontrol module or that part here


// write initial mob position... with a terrible way
initial begin
    skeleton_pos[3] = 63;
    skeleton_pos[2] = 97;
    skeleton_pos[1] = 94;
    skeleton_pos[0] = 89;

    eye_pos[3] = 144;
    eye_pos[2] = 157;
    eye_pos[1] = 149;
    eye_pos[0] = 214;

    goblin_pos[3] = 77;
    goblin_pos[2] = 197;
    goblin_pos[1] = 194;
    goblin_pos[0] = 248;

    mushroom_pos[3] = 137;
    mushroom_pos[2] = 176;
    mushroom_pos[1] = 256;
    mushroom_pos[0] = 257;
end


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

// monster addr
always @(*) begin 
    monster_addr = (h_cnt & 5'b11111) + 32 * ((v_cnt & 5'b11111) + monster_anim_num * 32);
end

// background addr
always @(*) begin
    pixel_addr = (h_cnt & 5'b11111) + 32 * ((v_cnt & 5'b11111) + texture_num * 32);
end

// first_layer
always @(*) begin
    if(map_addr == knight_pos)
        if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
            first_layer_pixel = 12'hE00;    // TODO
        else if(knight_pixel != 12'h000 && knight_state == hit && animation_count > 12)
            first_layer_pixel = knight_pixel + 12'h100;
        else if(knight_pixel != 12'h000)
            first_layer_pixel = knight_pixel;
        else
            first_layer_pixel = pixel;
    else if(map_addr == wizard_pos)
        if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
            first_layer_pixel = 12'hE00;    // TODO
        else if(wizard_pixel != 12'h000 && wizard_state == hit && animation_count > 12)
            first_layer_pixel = wizard_pixel + 12'h100;
        else if(wizard_pixel != 12'h000)
            first_layer_pixel = wizard_pixel;
        else
            first_layer_pixel = pixel;
    else
        for(i = 0;i < 4;i = i + 1) begin
            if(map_addr == skeleton_pos[i])
                if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
                    first_layer_pixel = 12'hE00;    // TODO
                else if(skeleton_pixel != 12'h000)
                    first_layer_pixel = skeleton_pixel;
                else
                    first_layer_pixel = pixel;
            else if(map_addr == eye_pos[i])
                if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
                    first_layer_pixel = 12'hE00;    // TODO
                else if(eye_pixel != 12'h000)
                    first_layer_pixel = eye_pixel;
                else
                    first_layer_pixel = pixel;
            else if(map_addr == goblin_pos[i])
                if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
                    first_layer_pixel = 12'hE00;    // TODO
                else if(goblin_pixel != 12'h000)
                    first_layer_pixel = goblin_pixel;
                else
                    first_layer_pixel = pixel;
            else if(map_addr == mushroom_pos[i])
                if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4)  // 2 pixel for blood
                    first_layer_pixel = 12'hE00;    // TODO
                else if(mushroom_pixel != 12'h000)
                    first_layer_pixel = mushroom_pixel;
                else
                    first_layer_pixel = pixel;
            else
                first_layer_pixel = pixel;
        end
end

// final_pixel
always @(*) begin
    if (valid)
        // selected block
        if(map_addr == selected_pos)
            case(player_state)
                move:  // selected block for movement
                    if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                        final_pixel = 12'h4Af;
                    else
                        final_pixel = first_layer_pixel + 12'h010;
                attack:  // selected block for attack
                    if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                        final_pixel = 12'hF22;
                    else
                        final_pixel = first_layer_pixel + 12'h100;
                default:
                    final_pixel = first_layer_pixel;
            endcase
        else if(action_pos == knight_pos)   // select range for knight
            case(player_state)
                move:  // move
                    if((map_addr == action_pos - 1 || map_addr == action_pos + 1 || map_addr == action_pos - 20 || map_addr == action_pos + 20) && texture_num < 3)   // 4-direction
                        if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                            final_pixel = 12'h4Af;
                        else
                            final_pixel = first_layer_pixel;
                    else
                        final_pixel = first_layer_pixel;
                attack:  // attack
                    if((map_addr == action_pos - 1 || map_addr == action_pos + 1 || map_addr == action_pos - 20 || map_addr == action_pos + 20) && texture_num < 3)   // 4-direction
                        if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                            final_pixel = 12'hF22;
                        else
                            final_pixel = first_layer_pixel;
                    else
                        final_pixel = first_layer_pixel;
                default:
                    final_pixel = first_layer_pixel;
            endcase
        else    // select range for wizard
            case(player_state)
                move:  // move
                    if((map_addr / 20 == action_pos / 20 || map_addr % 20 == action_pos % 20) && texture_num < 3)   // 大十字
                        if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                            final_pixel = 12'h4Af;
                        else
                            final_pixel = first_layer_pixel;
                    else
                        final_pixel = first_layer_pixel;
                attack:  // attack
                    if((map_addr / 20 == action_pos / 20 || map_addr % 20 == action_pos % 20) && texture_num < 3)   
                        if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                            final_pixel = 12'hF22;
                        else
                            final_pixel = first_layer_pixel;
                    else
                        final_pixel = first_layer_pixel;
                default:
                    final_pixel = first_layer_pixel;
            endcase
    else
        final_pixel = 0;
end

// knight animation num
always @(posedge clk_25MHz) begin
    knight_anim_num <= next_knight_anim;
end

always @(*) begin
    case(knight_state)
        attack:
                if(animation_count < 4)
                    next_knight_anim = 2;
                else if(animation_count < 8)
                    next_knight_anim = 3;
                else if(animation_count < 12)
                    next_knight_anim = 4;
                else 
                    next_knight_anim = 5;
        default:
                if(animation_count < 8)
                    next_knight_anim = 0;
                else 
                    next_knight_anim = 1;
    endcase
end

// wizard animation num
always @(posedge clk_25MHz) begin
    wizard_anim_num <= next_wizard_anim;
end

always @(*) begin
    case(wizard_state)
        attack:
                // anim_num 2~6
                if(animation_count < 3)
                    next_wizard_anim = 2;
                else if(animation_count < 6)
                    next_wizard_anim = 3;
                else if(animation_count < 9)
                    next_wizard_anim = 4;
                else if(animation_count < 12)
                    next_wizard_anim = 5;
                else
                    next_wizard_anim = 6;
        default:
                if(animation_count < 8)
                    next_wizard_anim = 0;
                else 
                    next_wizard_anim = 1;
    endcase
end

// monster animation num
always @(posedge clk_25MHz) begin
    monster_anim_num <= next_monster_anim;
end

always @(*) begin
    case(monster_state)
        attack:
                if(animation_count < 4)
                    next_monster_anim = 2;
                else if(animation_count < 8)
                    next_monster_anim = 3;
                else if(animation_count < 12)
                    next_monster_anim = 4;
                else if(animation_count < 15)
                    next_monster_anim = 5;
                else
                    next_monster_anim = 0;
        default:
                if(animation_count < 8)
                    next_monster_anim = 0;
                else 
                    next_monster_anim = 1;
    endcase
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
