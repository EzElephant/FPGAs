`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////


module vga(
    input clk_25MHz,
    input [3:0] game_state,
    input [3:0] animation_count,
    input [1:0] player_state,
    input [1:0] knight_state,
    input [1:0] wizard_state,
    input monster_state,
    input [10:0] scroll_x,
    input [10:0] scroll_y,
    input [8:0] action_pos,
    input [10:0] selected_pos,
    input [8:0] knight_pos,
    input [8:0] wizard_pos,
    input [6:0] knight_blood,
    input [6:0] wizard_blood,
    input [6:0] skeleton_blood_1,
    input [6:0] skeleton_blood_2,
    input [6:0] skeleton_blood_3,
    input [6:0] skeleton_blood_4,
    input [6:0] eye_blood_1,
    input [6:0] eye_blood_2,
    input [6:0] eye_blood_3,
    input [6:0] eye_blood_4,
    input [6:0] goblin_blood_1,
    input [6:0] goblin_blood_2,
    input [6:0] goblin_blood_3,
    input [6:0] goblin_blood_4,
    input [6:0] mushroom_blood_1,
    input [6:0] mushroom_blood_2,
    input [6:0] mushroom_blood_3,
    input [6:0] mushroom_blood_4,
    output reg [11:0] final_pixel,
    output hsync,
    output vsync
);

wire valid;
wire [10:0] ori_h_cnt, ori_v_cnt;
wire [11:0] pixel;
wire [11:0] knight_pixel;
wire [11:0] wizard_pixel;
wire [11:0] skeleton_pixel;
wire [11:0] eye_pixel;
wire [11:0] goblin_pixel;
wire [11:0] mushroom_pixel;
wire [11:0] title_pixel;
wire [11:0] lost_scene_pixel;
wire [11:0] win_scene_pixel;
reg [11:0] first_layer_pixel;
reg [13:0] pixel_addr;
reg [12:0] knight_addr;
reg [12:0] wizard_addr;
reg [12:0] monster_addr;
reg [14:0] title_addr;
reg [14:0] lost_scene_addr;
reg [14:0] win_scene_addr;
reg [10:0] h_cnt, v_cnt;
reg [10:0] map_addr;
reg [3:0] write_texture_num;
wire [3:0] texture_num;

parameter move = 2'b00;
parameter attack = 2'b01;
parameter hit = 2'b10;
parameter idle = 2'b11;

// view starting point
// reg [x:0] start;

reg [8:0] skeleton_pos [0:3];
reg [8:0] eye_pos [0:3];
reg [8:0] goblin_pos [0:3];
reg [8:0] mushroom_pos [0:3];

// animation frames
reg [2:0] knight_anim_num, next_knight_anim;
reg [2:0] wizard_anim_num, next_wizard_anim;
reg [2:0] monster_anim_num, next_monster_anim;



vga_controller VGA(.pclk(clk_25MHz), .reset(rst), .hsync(hsync), .vsync(vsync), 
                    .valid(valid), .h_cnt(ori_h_cnt), .v_cnt(ori_v_cnt));

blk_mem_gen_0 blk_mem_gen_0_inst(.clka(clk_25MHz), .addra(pixel_addr), .douta(pixel));

// blk_mem_gen_1 for map, if change this, remember to change blk_mem_gen_8 too.
blk_mem_gen_1 map_num(.clka(clk_25MHz), .addra(map_addr), .wea(1'b0), .dina(write_texture_num), .douta(texture_num));
blk_mem_gen_2 knight_num(.clka(clk_25MHz), .addra(knight_addr), .douta(knight_pixel));
blk_mem_gen_3 wizard_num(.clka(clk_25MHz), .addra(wizard_addr), .douta(wizard_pixel));
blk_mem_gen_4 skeleton_num(.clka(clk_25MHz), .addra(monster_addr), .douta(skeleton_pixel));
blk_mem_gen_5 eye_num(.clka(clk_25MHz), .addra(monster_addr), .douta(eye_pixel));
blk_mem_gen_6 goblin_num(.clka(clk_25MHz), .addra(monster_addr), .douta(goblin_pixel));
blk_mem_gen_7 mushroom_num(.clka(clk_25MHz), .addra(monster_addr), .douta(mushroom_pixel));

// blk_mem_gen_scene for scene
blk_mem_gen_scene_0 title(.clka(clk_25MHz), .addra(title_addr), .douta(title_pixel));
blk_mem_gen_scene_1 lost_scene(.clka(clk_25MHz), .addra(lost_scene_addr), .douta(lost_scene_pixel));
blk_mem_gen_scene_2 win_scene(.clka(clk_25MHz), .addra(win_scene_addr), .douta(win_scene_pixel));

// attach gamecontrol module or that part here


// write initial mob position... with a terrible way
initial begin
    skeleton_pos[3] = 63;
    skeleton_pos[2] = 97;
    skeleton_pos[1] = 94;
    skeleton_pos[0] = 89;

    eye_pos[3] = 144;
    eye_pos[2] = 167;
    eye_pos[1] = 129;
    eye_pos[0] = 214;

    goblin_pos[3] = 77;
    goblin_pos[2] = 197;
    goblin_pos[1] = 194;
    goblin_pos[0] = 248;

    mushroom_pos[3] = 137;
    mushroom_pos[2] = 176;
    mushroom_pos[1] = 256;
    mushroom_pos[0] = 252;
end

// caculate scroll window h_cnt v_cnt
always @(*) begin
    h_cnt = ori_h_cnt + scroll_x;
    v_cnt = ori_v_cnt + scroll_y;
    // h_cnt = ori_h_cnt;
    // v_cnt = ori_v_cnt;
end


// map_addr
always @(*) begin
    map_addr = (h_cnt >> 5) + 40 * (v_cnt >> 5);
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

// title addr
always @(*) begin
    title_addr = (h_cnt >> 2) + 160 * (v_cnt >> 2);
end

// lost_scene addr
always @(*) begin
    lost_scene_addr = (h_cnt >> 2) + 160 * (v_cnt >> 2);
end

// win_scene addr
always @(*) begin
    win_scene_addr = (h_cnt >> 2) + 160 * (v_cnt >> 2);
end

// first_layer
always @(*) begin
    if(map_addr == knight_pos)
        if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && knight_blood > 0)  // 2 pixel for blood
            if(h_cnt[4:0] < (32 * knight_blood / 127))
                first_layer_pixel = 12'hC00;
            else
                first_layer_pixel = 12'hFFF;
        else if(knight_pixel != 12'h000 && knight_state == hit && animation_count > 8)
            first_layer_pixel = knight_pixel + 12'h200;
        else if(knight_pixel != 12'h000 && knight_blood > 0)
            first_layer_pixel = knight_pixel;
        else
            first_layer_pixel = pixel;
    else if(map_addr == wizard_pos)
        if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && wizard_blood > 0)  // 2 pixel for blood
            if(h_cnt[4:0] < (32 * wizard_blood / 80))
                first_layer_pixel = 12'hC00;
            else
                first_layer_pixel = 12'hFFF;
        else if(wizard_pixel != 12'h000 && wizard_state == hit && animation_count > 8)
            first_layer_pixel = wizard_pixel + 12'h200;
        else if(wizard_pixel != 12'h000 && wizard_blood > 0)
            first_layer_pixel = wizard_pixel;
        else
            first_layer_pixel = pixel;
    else
        if(map_addr == skeleton_pos[0])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && skeleton_blood_1 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * skeleton_blood_1 / 40))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(skeleton_pixel != 12'h000 && skeleton_blood_1 > 0)
                first_layer_pixel = skeleton_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == eye_pos[0])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && eye_blood_1 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * eye_blood_1 / 25))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(eye_pixel != 12'h000 && eye_blood_1 > 0)
                first_layer_pixel = eye_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == goblin_pos[0])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && goblin_blood_1 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * goblin_blood_1 / 16))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(goblin_pixel != 12'h000 && goblin_blood_1 > 0)
                first_layer_pixel = goblin_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == mushroom_pos[0])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && mushroom_blood_1 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * mushroom_blood_1 / 60))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(mushroom_pixel != 12'h000 && mushroom_blood_1 > 0)
                first_layer_pixel = mushroom_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == skeleton_pos[1])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && skeleton_blood_2 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * skeleton_blood_2 / 40))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(skeleton_pixel != 12'h000 && skeleton_blood_2 > 0)
                first_layer_pixel = skeleton_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == eye_pos[1])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && eye_blood_2 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * eye_blood_2 / 25))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(eye_pixel != 12'h000 && eye_blood_2 > 0)
                first_layer_pixel = eye_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == goblin_pos[1])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && goblin_blood_2 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * goblin_blood_2 / 16))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(goblin_pixel != 12'h000 && goblin_blood_2 > 0)
                first_layer_pixel = goblin_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == mushroom_pos[1])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && mushroom_blood_2 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * mushroom_blood_2 / 40))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(mushroom_pixel != 12'h000 && mushroom_blood_2 > 0)
                first_layer_pixel = mushroom_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == skeleton_pos[2])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && skeleton_blood_3 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * skeleton_blood_3 / 40))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(skeleton_pixel != 12'h000 && skeleton_blood_3 > 0)
                first_layer_pixel = skeleton_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == eye_pos[2])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && eye_blood_3 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * eye_blood_3 / 25))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(eye_pixel != 12'h000 && eye_blood_3 > 0)
                first_layer_pixel = eye_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == goblin_pos[2])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && goblin_blood_3 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * goblin_blood_3 / 16))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(goblin_pixel != 12'h000 && goblin_blood_3 > 0)
                first_layer_pixel = goblin_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == mushroom_pos[2])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && mushroom_blood_3 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * mushroom_blood_3 / 60))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(mushroom_pixel != 12'h000 && mushroom_blood_3 > 0)
                first_layer_pixel = mushroom_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == skeleton_pos[3])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && skeleton_blood_4 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * skeleton_blood_4 / 40))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(skeleton_pixel != 12'h000 && skeleton_blood_4 > 0)
                first_layer_pixel = skeleton_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == eye_pos[3])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && eye_blood_4 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * eye_blood_4 / 25))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(eye_pixel != 12'h000 && eye_blood_4 > 0)
                first_layer_pixel = eye_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == goblin_pos[3])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && goblin_blood_4 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * goblin_blood_4 / 16))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(goblin_pixel != 12'h000 && goblin_blood_4 > 0)
                first_layer_pixel = goblin_pixel;
            else
                first_layer_pixel = pixel;
        else if(map_addr == mushroom_pos[3])
            if((v_cnt & 5'b11111) > 1 && v_cnt[4:0] < 4 && mushroom_blood_4 > 0)  // 2 pixel for blood
                if(h_cnt[4:0] < (32 * mushroom_blood_4 / 60))
                    first_layer_pixel = 12'hC00;
                else
                    first_layer_pixel = 12'hFFF;
            else if(mushroom_pixel != 12'h000 && mushroom_blood_4 > 0)
                first_layer_pixel = mushroom_pixel;
            else
                first_layer_pixel = pixel;
        else
            first_layer_pixel = pixel;        
end

// final_pixel
always @(*) begin
    if (valid)
        case (game_state)
            0: begin // TITLE
                final_pixel = title_pixel;
            end
            2: begin // LOST
                final_pixel = lost_scene_pixel;
            end
            3: begin // WIN
                final_pixel = win_scene_pixel;
            end
            default: begin // GAME
                // selected block
                if(map_addr == selected_pos)
                    case(player_state)
                        move:  // selected block for movement
                            if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                                final_pixel = 12'h4Af;
                            else if ((first_layer_pixel == 12'hFFF) || (first_layer_pixel == 12'hC00))
                                final_pixel = first_layer_pixel;
                            else
                                final_pixel = first_layer_pixel + 12'h010;
                        attack:  // selected block for attack
                            if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                                final_pixel = 12'hF22;
                            else if ((first_layer_pixel == 12'hFFF) || (first_layer_pixel == 12'hC00))
                                final_pixel = first_layer_pixel;
                            else
                                final_pixel = first_layer_pixel + 12'h100;
                        default:
                            final_pixel = first_layer_pixel;
                    endcase
                else if(action_pos == knight_pos)   // select range for knight
                    case(player_state)
                        move:  // move
                            if((map_addr == action_pos - 1 || map_addr == action_pos + 1 || map_addr == action_pos - 40 || map_addr == action_pos + 40) && texture_num < 3)   // 4-direction
                                if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                                    final_pixel = 12'h4Af;
                                else
                                    final_pixel = first_layer_pixel;
                            else
                                final_pixel = first_layer_pixel;
                        attack:  // attack
                            if((map_addr == action_pos - 1 || map_addr == action_pos + 1 || map_addr == action_pos - 40 || map_addr == action_pos + 40) && texture_num < 3)   // 4-direction
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
                            if((map_addr / 40 == action_pos / 40 || map_addr % 40 == action_pos % 40) && texture_num < 3)   // 大十字
                                if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                                    final_pixel = 12'h4Af;
                                else
                                    final_pixel = first_layer_pixel;
                            else
                                final_pixel = first_layer_pixel;
                        attack:  // attack
                            if((map_addr / 40 == action_pos / 40 || map_addr % 40 == action_pos % 40) && texture_num < 3)   
                                if(h_cnt[4:0] < 2 || h_cnt[4:0] > 29 || v_cnt[4:0] < 2 || v_cnt[4:0] > 29)
                                    final_pixel = 12'hF22;
                                else
                                    final_pixel = first_layer_pixel;
                            else
                                final_pixel = first_layer_pixel;
                        default:
                            final_pixel = first_layer_pixel;
                    endcase
            end
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
        1:
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
