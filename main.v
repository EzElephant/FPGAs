module FPGAs(
    input clk, // 100MHz clock
    input rst, // BTNC
    input cheat_mode,
    input [7:0] player_boost,
    input [6:0] monster_boost,
    input btn_up, // for music volume control
    input btn_down, // for music volume control
    input btn_left, // debug for lost
    input btn_right, // debug for win
    input l_move_left, // left rocker input
    input l_move_right, // left rocker input
    input l_move_up, // left rocker input
    input l_move_down, // left rocker input
    input down_click, // left rocker input
    input click, // right rocker input
    input r_move_left, // right rocker input
    input r_move_right, // right rocker input
    input r_move_up, // right rocker input
    input r_move_down, // right rocker input
    output [3:0] vgaRed, // for vga
    output [3:0] vgaGreen, // for vga
    output [3:0] vgaBlue, // for vga
    output hsync, // for vga
    output vsync, // for vga
    output [15:0] LED, // for LED display
    output [6:0] DISPLAY, // for vga
    output [3:0] DIGIT, // for vga
    output audio_mclk, // for music
    output audio_lrck, // for music
    output audio_sck, // for music
    output audio_sdin // for music
);

parameter TITLE = 0;
parameter GAME = 1;
parameter LOST = 2;
parameter WIN = 3;
parameter SHOW_MAP = 4;
parameter WAIT = 5;

parameter move = 2'b00;
parameter attack = 2'b01;
parameter hit = 2'b10;
parameter idle = 2'b11;

wire click_d, down_click_d, btn_up_d, btn_down_d, btn_left_d, btn_right_d;
wire click_pulse, down_click_pulse, btn_up_pulse, btn_down_pulse, btn_left_pulse, btn_right_pulse;
wire move_left, move_right, move_up, move_down;
wire scroll_left, scroll_right, scroll_up, scroll_down;
wire [26:0] clk_div;
wire [7:0] rand_test;
reg game_rst; // for another round
reg [2:0] i, j, k;
reg [3:0] game_state, next_game_state;
reg [5:0] choose_x, choose_y, next_choose_x, next_choose_y;
reg [8:0] write_count, next_write_count;
reg [10:0] scroll_x, scroll_y, next_scroll_x, next_scroll_y;
wire [10:0] player_strength, monster_strength;
wire [3:0] floor_num;

// animation counter
reg [19:0] offset_count;
reg [17:0] show_count;
reg [3:0] animation_count;

// record which block has character
// in 40 * 30 map, 0 for h_cnt, 1 for v_cnt
reg [10:0] action_pos, next_action_pos;
wire [10:0] selected_pos;
reg [10:0] knight_pos = 1005, next_knight_pos; 
reg [10:0] wizard_pos = 1043, next_wizard_pos;
reg [9:0] skeleton_pos [0:3];
reg [9:0] eye_pos [0:3];
reg [9:0] goblin_pos [0:3];
reg [9:0] mushroom_pos [0:3];

reg [1:0] player_state, next_player_state;
reg [1:0] knight_state, next_knight_state;
reg [1:0] knight_energy, next_knight_energy;
reg [1:0] wizard_state, next_wizard_state;
reg monster_state, next_monster_state;

// character blood
reg [7:0] sum_monster_damage;
reg [6:0] knight_blood = 127, next_knight_blood;
reg [6:0] wizard_blood = 80, next_wizard_blood;
reg [6:0] skeleton_blood [0:3], next_skeleton_blood [0:3];
reg [6:0] eye_blood [0:3], next_eye_blood [0:3];
reg [6:0] goblin_blood [0:3], next_goblin_blood [0:3];
reg [6:0] mushroom_blood [0:3], next_mushroom_blood [0:3];
reg [6:0] show_blood;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]),
        .game_state(game_state),
        .animation_count(animation_count),
        .player_state(player_state),
        .knight_state(knight_state),
        .wizard_state(wizard_state),
        .monster_state(monster_state),
        .scroll_x(scroll_x),
        .scroll_y(scroll_y),
        .action_pos(action_pos),
        .selected_pos(selected_pos),
        .knight_pos(knight_pos),
        .wizard_pos(wizard_pos),
        .knight_blood(knight_blood),
        .wizard_blood(wizard_blood),
        .skeleton_blood_1(skeleton_blood[0]),
        .skeleton_blood_2(skeleton_blood[1]),
        .skeleton_blood_3(skeleton_blood[2]),
        .skeleton_blood_4(skeleton_blood[3]),
        .eye_blood_1(eye_blood[0]),
        .eye_blood_2(eye_blood[1]),
        .eye_blood_3(eye_blood[2]),
        .eye_blood_4(eye_blood[3]),
        .goblin_blood_1(goblin_blood[0]),
        .goblin_blood_2(goblin_blood[1]),
        .goblin_blood_3(goblin_blood[2]),
        .goblin_blood_4(goblin_blood[3]),
        .mushroom_blood_1(mushroom_blood[0]),
        .mushroom_blood_2(mushroom_blood[1]),
        .mushroom_blood_3(mushroom_blood[2]),
        .mushroom_blood_4(mushroom_blood[3]),
        .final_pixel({vgaRed, vgaGreen, vgaBlue}), 
        .hsync(hsync), 
        .vsync(vsync)
);


LSFR random_gen(.clk(clk_div[21]), .rand_num(rand_test), .rst(rst));

// Use LED to display whether the monster die or not.
assign LED[15:0] = {skeleton_blood[0] != 0, skeleton_blood[1] != 0, skeleton_blood[2] != 0, skeleton_blood[3] != 0,
                    goblin_blood[0] != 0, goblin_blood[1] != 0, goblin_blood[2] != 0, goblin_blood[3] != 0,
                    mushroom_blood[0] != 0, mushroom_blood[1] != 0, mushroom_blood[2] != 0, mushroom_blood[3] != 0,
                    eye_blood[0] != 0, eye_blood[1] != 0, eye_blood[2] != 0, eye_blood[3] != 0};

debounce cen_push(.clk(clk_div[1]), .pb(click), .pb_debounced(click_d));
one_pulse cen_push_pulse(.clk(clk_div[1]), .pb_in(click_d), .pb_out(click_pulse));

debounce down_push(.clk(clk_div[1]), .pb(down_click), .pb_debounced(down_click_d));
one_pulse down_push_pulse(.clk(clk_div[1]), .pb_in(down_click_d), .pb_out(down_click_pulse));

debounce btn_up_debounce(.clk(clk), .pb(btn_up), .pb_debounced(btn_up_d));
one_pulse btn_up_1pulse(.clk(clk), .pb_in(btn_up_d), .pb_out(btn_up_pulse));

debounce btn_down_debounce(.clk(clk), .pb(btn_down), .pb_debounced(btn_down_d));
one_pulse btn_down_1pulse(.clk(clk), .pb_in(btn_down_d), .pb_out(btn_down_pulse));

debounce btn_left_debounce(.clk(clk), .pb(btn_left), .pb_debounced(btn_left_d));
one_pulse btn_left_1pulse(.clk(clk), .pb_in(btn_left_d), .pb_out(btn_left_pulse));

debounce btn_right_debounce(.clk(clk), .pb(btn_right), .pb_debounced(btn_right_d));
one_pulse btn_right_1pulse(.clk(clk), .pb_in(btn_right_d), .pb_out(btn_right_pulse));

special_one_pulse ll(.clk(clk), .pb_in(l_move_left), .pb_out(move_left));
special_one_pulse lr(.clk(clk), .pb_in(l_move_right), .pb_out(move_right));
special_one_pulse lu(.clk(clk), .pb_in(l_move_up), .pb_out(move_up));
special_one_pulse ld(.clk(clk), .pb_in(l_move_down), .pb_out(move_down));
special_one_pulse rl(.clk(clk), .pb_in(r_move_left), .pb_out(scroll_left));
special_one_pulse rr(.clk(clk), .pb_in(r_move_right), .pb_out(scroll_right));
special_one_pulse ru(.clk(clk), .pb_in(r_move_up), .pb_out(scroll_up));
special_one_pulse rd(.clk(clk), .pb_in(r_move_down), .pb_out(scroll_down));

// rocker1 rocker1(.clk(clk), .rst(rst), .MISO(MISO_1), .SS(SS_1), .MOSI(MOSI_1), .SCLK(SCLK_1),
// .left(move_left), .right(move_right), .up(move_up), .down(move_down), .click(), .down_click(down_click));

// rocker2 rocker2(.clk(clk), .rst(rst), .MISO(MISO_2), .SS(SS_2), .MOSI(MOSI_2), .SCLK(SCLK_2),
// .left(scroll_right), .right(scroll_left), .up(scroll_down), .down(scroll_up), .click(), .down_click(click));

seven_segment Seven_segment(.clk_div(clk_div[15]), .data(show_blood), .DISPLAY(DISPLAY), .DIGIT(DIGIT));

music music(.clk(clk), .clk_25MHz(clk_div[1]), .clk_div(clk_div[21]), .rst(rst), 
.effect_control(), ._volUP(btn_up_pulse), ._volDOWN(btn_down_pulse),
.audio_mclk(audio_mclk), .audio_lrck(audio_lrck), .audio_sck(audio_sck), .audio_sdin(audio_sdin));

// map file for selection, if changes this, remember to change blk_mem_gen_1 too.
blk_mem_gen_8 map_info(.clka(clk_div[1]), .addra(selected_pos), .douta(floor_num));

// choose_x, choose_y to 1D
assign selected_pos = ({3'b000, choose_y} * 40) + {3'b000, choose_x};

// write initial mob position... with a terrible way
initial begin
    skeleton_pos[3] = 363;
    skeleton_pos[2] = 254;
    skeleton_pos[1] = 304;
    skeleton_pos[0] = 889;
    skeleton_blood[0] = 40;
    skeleton_blood[1] = 40;
    skeleton_blood[2] = 40;
    skeleton_blood[3] = 40;

    eye_pos[3] = 354;
    eye_pos[2] = 514;
    eye_pos[1] = 829;
    eye_pos[0] = 233;
    eye_blood[0] = 25;
    eye_blood[1] = 25;
    eye_blood[2] = 25;
    eye_blood[3] = 25;

    goblin_pos[3] = 859;
    goblin_pos[2] = 934;
    goblin_pos[1] = 910;
    goblin_pos[0] = 248;
    goblin_blood[0] = 16;
    goblin_blood[1] = 16;
    goblin_blood[2] = 16;
    goblin_blood[3] = 16;

    mushroom_pos[3] = 820;
    mushroom_pos[2] = 595;
    mushroom_pos[1] = 232;
    mushroom_pos[0] = 273;
    mushroom_blood[0] = 60;
    mushroom_blood[1] = 60;
    mushroom_blood[2] = 60;
    mushroom_blood[3] = 60;
end

always @(posedge clk) begin
    if (rst || game_rst) begin
        choose_x <= 7;
        choose_y <= 24;
        scroll_x <= 640;
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
    if (game_state == GAME) begin
        if (move_up && choose_y != 0)
            next_choose_y = choose_y - 1;
        if (move_down && choose_y != 29)
            next_choose_y = choose_y + 1;
        if (move_left && choose_x != 0)
            next_choose_x = choose_x - 1;
        if (move_right && choose_x != 39)
            next_choose_x = choose_x + 1;
    end
end

always @(*) begin
    next_scroll_x = scroll_x;
    next_scroll_y = scroll_y;
    if (game_state == GAME) begin
        if (scroll_up && scroll_y != 0)
            next_scroll_y = scroll_y - 1;
        if (scroll_down && scroll_y != 480)
            next_scroll_y = scroll_y + 1;
        if (scroll_left && scroll_x != 0)
            next_scroll_x = scroll_x - 1;
        if (scroll_right && scroll_x != 640)
            next_scroll_x = scroll_x + 1;  
    end
    else if (game_state == SHOW_MAP && show_count == 9487) begin
        if (scroll_y < 480)
            next_scroll_y = scroll_y + 1;
        else if (scroll_x > 0)
            next_scroll_x = scroll_x - 1;
    end
end

// game state FSM
always @(posedge clk_div[1]) begin
    if (rst)
        game_state <= TITLE;
    else
        game_state <= next_game_state;
end

always @(*) begin
    next_game_state = game_state;
    case (game_state)
        TITLE: begin
            if (down_click_pulse)
                next_game_state = WAIT;
        end
        GAME: begin
            if (btn_left_pulse || ((knight_blood == 0) && (wizard_blood == 0))) begin
                next_game_state = LOST;
            end
            else if (btn_right_pulse || knight_pos == 233 || wizard_pos == 233) begin
                next_game_state = WIN;
            end
        end
        LOST: begin
            if (click_pulse)
                next_game_state = TITLE;
        end
        WIN: begin
            if (click_pulse)
                next_game_state = TITLE;
        end
        SHOW_MAP: begin
            if (scroll_x == 0)
                next_game_state = GAME;
        end
        WAIT: begin
            if (click_pulse)
                next_game_state = SHOW_MAP;
        end
    endcase
end

always @(*) begin
    game_rst = 1;
    if (game_state == GAME || game_state == SHOW_MAP || game_state == WAIT)
        game_rst = 0;
end

always @(posedge clk) begin
    if (show_count == 500000)
        show_count <= 0;
    else
        show_count <= show_count + 1;
end

// offset counter for animation counter
always @(posedge clk_div[1]) begin
    if(rst || down_click_pulse || game_rst)
        offset_count <= 0;
    else
        offset_count <= offset_count + 1;
end

// animation counter
always @(posedge clk_div[1]) begin
    if(down_click_pulse && player_state == attack)
        animation_count <= 1;
    else if(action_pos == wizard_pos && down_click_pulse && player_state == move)
        animation_count <= 1;
    else if(wizard_blood == 0 && action_pos == knight_pos && down_click_pulse && knight_energy == 3)
        animation_count <= 1;
    else if(offset_count == 20'b1111_1111_1111_1111_1111)
        animation_count <= animation_count + 1;
    else
        animation_count <= animation_count;
end


// player FSM
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        player_state <= move;
    else
        player_state <= next_player_state;
end

always @(*) begin
    case(player_state)
        move:
            if(click_pulse)
                next_player_state = attack;
            else if(down_click_pulse)   // for round finish
                next_player_state = idle;
            else
                next_player_state = move;
        attack:
            if(click_pulse)
                next_player_state = move;
            else if(down_click_pulse)
                next_player_state = idle;
            else
                next_player_state = attack;
        default:
            if(action_pos == knight_pos)
                if(knight_state == idle)   // idle
                    next_player_state = move;
                else    // attack
                    next_player_state = idle;
            else if(action_pos == wizard_pos)
                if(wizard_state == idle)   // idle
                    next_player_state = move;
                else    // attack
                    next_player_state = idle;
            else
                if(action_pos == knight_pos)  // idle
                    next_player_state = move;
                else
                    next_player_state = idle;
    endcase 
end

// knight_state
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        knight_state <= idle;
    else 
        knight_state <= next_knight_state;
end

always @(*) begin
    if(wizard_state == hit || (wizard_blood == 0 && action_pos == 0 && knight_energy == 3))
        next_knight_state = hit;
    else if(knight_state == idle)
        // on the 4 direction of knight and in attack state
        if((selected_pos == action_pos - 1 || selected_pos == action_pos + 1 || selected_pos == action_pos - 40 || selected_pos == action_pos + 40) 
            && action_pos == knight_pos && down_click_pulse && player_state == attack)
            // make sure player select on mobs
            if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0])
                next_knight_state = attack;
            else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                next_knight_state = attack;
            else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                next_knight_state = attack;
            else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                next_knight_state = attack;
            else
                next_knight_state = idle;
        else
            next_knight_state = idle;
    else if(knight_state == attack)
        if(animation_count == 0)
            next_knight_state = idle;
        else
            next_knight_state = attack;
    else    // knight_state = hit
        if(monster_state == 0)
            next_knight_state = idle;
        else
            next_knight_state = hit;
end

// wizard_state
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        wizard_state <= idle;
    else 
        wizard_state <= next_wizard_state;
end

always @(*) begin
    case(wizard_state)
        idle:
            // on the crossline of wizard
            if(((selected_pos / 40 - action_pos / 40 <= 3 || action_pos / 40 - selected_pos / 40 <= 3) && ((selected_pos % 40) - (action_pos % 40) <= 3 || (action_pos % 40) - (selected_pos % 40) <= 3)) && action_pos == wizard_pos && down_click_pulse && player_state == attack)
                // make sure player select on mobs
                if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0])
                    next_wizard_state = attack;
                else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                    next_wizard_state = attack;
                else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                    next_wizard_state = attack;
                else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                    next_wizard_state = attack;
                else
                    next_wizard_state = idle;
            // wizard finish the step to move -> monster turn to attack
            else if(((selected_pos / 40 - action_pos / 40 <= 3 || action_pos / 40 - selected_pos / 40 <= 3) && ((selected_pos % 40) - (action_pos % 40) <= 3 || (action_pos % 40) - (selected_pos % 40) <= 3)) && floor_num < 4 && action_pos == wizard_pos && down_click_pulse && player_state == move)
                // make sure player didn't select on mobs or characters
                if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == knight_pos || selected_pos == wizard_pos)
                    next_wizard_state = idle;
                else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                    next_wizard_state = idle;
                else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                    next_wizard_state = idle;
                else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                    next_wizard_state = idle;
                else
                    next_wizard_state = hit;
            else
                next_wizard_state = idle;
        attack:
            if(animation_count == 0)
                next_wizard_state = hit;
            else
                next_wizard_state = attack;
        default:
            if(monster_state == 0)
                next_wizard_state = idle;
            else
                next_wizard_state = hit;
    endcase
end

// monster_state
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        monster_state <= 0;
    else 
        monster_state <= next_monster_state;
end

always @(*) begin
    case(monster_state)
        0:  // idle
            if(wizard_state == hit || knight_state == hit)
                next_monster_state = 1;
            else
                next_monster_state = 0;
        1:  // attack
            if(animation_count == 15)
                next_monster_state = 0;
            else    
                next_monster_state = 1;
    endcase
end

// knight energy => knight has 4 steps
always @(posedge clk_div[1]) begin
    if(rst || game_rst || cheat_mode)
        knight_energy <= 0;
    else
        knight_energy = next_knight_energy;
end

always @(*) begin
    if(knight_blood == 0)
        next_knight_energy = 0;
    else if((selected_pos == action_pos - 1 || selected_pos == action_pos + 1 || selected_pos == action_pos - 40 || selected_pos == action_pos + 40) && floor_num < 4 && down_click_pulse && player_state == move)
        // make sure player didn't select on mobs or characters 
        if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == wizard_pos || selected_pos == knight_pos)
            next_knight_energy = knight_energy;
        else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
            next_knight_energy = knight_energy;
        else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
            next_knight_energy = knight_energy;
        else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
            next_knight_energy = knight_energy;
        else
            next_knight_energy = knight_energy + 1;
    else if(knight_state == attack && animation_count == 0)
            next_knight_energy = knight_energy + 1;
    else    
        next_knight_energy = knight_energy;
end




// action character position
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        action_pos <= knight_pos;
    else
        action_pos <= next_action_pos;
end

always @(*) begin
    // knight
    if(action_pos == knight_pos)
        if(knight_blood == 0)   // knight dead
            next_action_pos = wizard_pos;
        // in the 4-direction of knight
        else if((selected_pos == action_pos - 1 || selected_pos == action_pos + 1 || selected_pos == action_pos - 40 || selected_pos == action_pos + 40) && floor_num < 4 && down_click_pulse && player_state == move)
            // make sure player didn't select on mobs or characters 
            if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == wizard_pos || selected_pos == knight_pos)
                next_action_pos = knight_pos;
            else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                next_action_pos = knight_pos;
            else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                next_action_pos = knight_pos;
            else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                next_action_pos = knight_pos;
            else if(knight_energy < 3)
                next_action_pos = knight_pos;
            else
                next_action_pos = wizard_pos;
        else if(knight_state == attack && animation_count == 0)
            if(knight_energy < 3)
                next_action_pos = knight_pos;
            else
                next_action_pos = wizard_pos;
        else
            next_action_pos = knight_pos;
    // wizard
    else if(action_pos == wizard_pos)
        if(wizard_blood == 0)   // wizard dead
            next_action_pos = 0;
        // on the crossline of wizard
        else if(((selected_pos / 40 - action_pos / 40 <= 3 || action_pos / 40 - selected_pos / 40 <= 3) && ((selected_pos % 40) - (action_pos % 40) <= 3 || (action_pos % 40) - (selected_pos % 40) <= 3)) && floor_num < 4 && down_click_pulse && player_state == move)
            // make sure player didn't select on mobs or characters
            if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == wizard_pos || selected_pos == knight_pos)
                next_action_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                next_action_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                next_action_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                next_action_pos = wizard_pos;
            else
                next_action_pos = 0;
        else if(wizard_state == attack && animation_count == 0)
            next_action_pos = 0;
        else
            next_action_pos = wizard_pos;
    else    // 0 for monster 
        if(animation_count == 15)
            next_action_pos = knight_pos;
        else
            next_action_pos = 0;
end

// TODO...
// character moving system 
// knight_pos 
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        knight_pos <= 1005;
    else
        knight_pos <= next_knight_pos;
end

always @(*) begin
    if(knight_blood == 0)
        next_knight_pos = 40;
    else if(action_pos == knight_pos)
        // on the 4-direction of knight
        if((selected_pos == action_pos - 1 || selected_pos == action_pos + 1 || selected_pos == action_pos - 40 || selected_pos == action_pos + 40) && floor_num < 4 && down_click_pulse && player_state == move)
            // make sure player didn't select on mobs or characters
            if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == wizard_pos)
                next_knight_pos = knight_pos;
            else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                next_knight_pos = knight_pos;
            else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                next_knight_pos = knight_pos;
            else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                next_knight_pos = knight_pos;
            else
                next_knight_pos = selected_pos;
        else
            next_knight_pos = knight_pos;
    else
        next_knight_pos = knight_pos;
end


// wizard_pos
always @(posedge clk_div[1]) begin
    if(rst || game_rst)
        wizard_pos <= 1043;
    else
        wizard_pos <= next_wizard_pos;
end

always @(*) begin
    if(wizard_blood == 0)
        next_wizard_pos = 40;
    else if(action_pos == wizard_pos)
        // on the crossline of wizard
        if(((selected_pos / 40 - action_pos / 40 <= 3 || action_pos / 40 - selected_pos / 40 <= 3) && ((selected_pos % 40) - (action_pos % 40) <= 3 || (action_pos % 40) - (selected_pos % 40) <= 3)) && floor_num < 4 && down_click_pulse && player_state == move)
            // make sure player didn't select on mobs or characters
            if(selected_pos == skeleton_pos[0] || selected_pos == eye_pos[0] || selected_pos == goblin_pos[0] || selected_pos == mushroom_pos[0] || selected_pos == knight_pos)
                next_wizard_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[1] || selected_pos == eye_pos[1] || selected_pos == goblin_pos[1] || selected_pos == mushroom_pos[1])
                next_wizard_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[2] || selected_pos == eye_pos[2] || selected_pos == goblin_pos[2] || selected_pos == mushroom_pos[2])
                next_wizard_pos = wizard_pos;
            else if(selected_pos == skeleton_pos[3] || selected_pos == eye_pos[3] || selected_pos == goblin_pos[3] || selected_pos == mushroom_pos[3])
                next_wizard_pos = wizard_pos;
            else
                next_wizard_pos = selected_pos;
        else
            next_wizard_pos = wizard_pos;
    else
        next_wizard_pos = wizard_pos;
end

// skeleton_pos => for releasing space after dead
always @(posedge clk_div[1]) begin
    if(rst || game_rst) begin
        skeleton_pos[3] <= 363;
        skeleton_pos[2] <= 254;
        skeleton_pos[1] <= 304;
        skeleton_pos[0] <= 889;
    end
    else
        for(i = 0;i < 4;i = i + 1) begin
            if(skeleton_blood[i] == 0)
                skeleton_pos[i] <= 0;
            else
                skeleton_pos[i] <= skeleton_pos[i];
        end
end

// eye_pos => for releasing space after dead
always @(posedge clk_div[1]) begin
    if(rst || game_rst) begin
        eye_pos[3] <= 354;
        eye_pos[2] <= 514;
        eye_pos[1] <= 829;
        eye_pos[0] <= 233;
    end
    else
        for(i = 0;i < 4;i = i + 1) begin
            if(eye_blood[i] == 0)
                eye_pos[i] <= 0;
            else
                eye_pos[i] <= eye_pos[i];
        end
end

// skeleton_pos => for releasing space after dead
always @(posedge clk_div[1]) begin
    if(rst || game_rst) begin
        goblin_pos[3] <= 859;
        goblin_pos[2] <= 934;
        goblin_pos[1] <= 910;
        goblin_pos[0] <= 248;
    end
    else
        for(i = 0;i < 4;i = i + 1) begin
            if(goblin_blood[i] == 0)
                goblin_pos[i] <= 0;
            else
                goblin_pos[i] <= goblin_pos[i];
        end
end

// skeleton_pos => for releasing space after dead
always @(posedge clk_div[1]) begin
    if(rst || game_rst) begin
        mushroom_pos[3] <= 820;
        mushroom_pos[2] <= 595;
        mushroom_pos[1] <= 232;
        mushroom_pos[0] <= 273;
    end
    else
        for(i = 0;i < 4;i = i + 1) begin
            if(mushroom_blood[i] == 0)
                mushroom_pos[i] <= 0;
            else
                mushroom_pos[i] <= mushroom_pos[i];
        end
end
        


// attack and blood system

assign player_strength = player_boost[0] + player_boost[1] + player_boost[2] + player_boost[3] + player_boost[4] + player_boost[5] + player_boost[6] + player_boost[7];
assign monster_strength = monster_boost[0] + monster_boost[1] + monster_boost[2] + monster_boost[3] + monster_boost[4] + monster_boost[5] + monster_boost[6];

// knight blood
always @(posedge clk_div[21]) begin
    if(rst || game_rst)
        knight_blood <= 127;
    else
        knight_blood <= next_knight_blood;
end

always @(*) begin
    // skeleton's turn to attack
    if(monster_state == 1 && animation_count == 7)
        if((knight_pos == skeleton_pos[0] - 1 || knight_pos == skeleton_pos[0] + 1 || knight_pos == skeleton_pos[0] - 40 || knight_pos == skeleton_pos[0] + 40) && skeleton_blood[0] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == skeleton_pos[1] - 1 || knight_pos == skeleton_pos[1] + 1 || knight_pos == skeleton_pos[1] - 40 || knight_pos == skeleton_pos[1] + 40) && skeleton_blood[1] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == skeleton_pos[2] - 1 || knight_pos == skeleton_pos[2] + 1 || knight_pos == skeleton_pos[2] - 40 || knight_pos == skeleton_pos[2] + 40) && skeleton_blood[2] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == skeleton_pos[3] - 1 || knight_pos == skeleton_pos[3] + 1 || knight_pos == skeleton_pos[3] - 40 || knight_pos == skeleton_pos[3] + 40) && skeleton_blood[3] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_knight_blood = knight_blood;
    // eyes' turn to attack
    else if(monster_state == 1 && animation_count == 8)
        if((knight_pos / 40 == eye_pos[0] / 40 || (knight_pos % 40) == (eye_pos[0] % 40)) && eye_blood[0] > 0)
            next_knight_blood = knight_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos / 40 == eye_pos[1] / 40 || (knight_pos % 40) == (eye_pos[1] % 40)) && eye_blood[1] > 0)
            next_knight_blood = knight_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos / 40 == eye_pos[2] / 40 || (knight_pos % 40) == (eye_pos[2] % 40)) && eye_blood[2] > 0)
            next_knight_blood = knight_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos / 40 == eye_pos[3] / 40 || (knight_pos % 40) == (eye_pos[3] % 40)) && eye_blood[3] > 0)
            next_knight_blood = knight_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_knight_blood = knight_blood;
    // goblin's turn to attack
    else if(monster_state == 1 && animation_count == 9)
        if((knight_pos == goblin_pos[0] - 1 || knight_pos == goblin_pos[0] + 1 || knight_pos == goblin_pos[0] - 40 || knight_pos == goblin_pos[0] + 40) && goblin_blood[0] > 0)
            next_knight_blood = knight_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == goblin_pos[1] - 1 || knight_pos == goblin_pos[1] + 1 || knight_pos == goblin_pos[1] - 40 || knight_pos == goblin_pos[1] + 40) && goblin_blood[1] > 0)
            next_knight_blood = knight_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == goblin_pos[2] - 1 || knight_pos == goblin_pos[2] + 1 || knight_pos == goblin_pos[2] - 40 || knight_pos == goblin_pos[2] + 40) && goblin_blood[2] > 0)
            next_knight_blood = knight_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == goblin_pos[3] - 1 || knight_pos == goblin_pos[3] + 1 || knight_pos == goblin_pos[3] - 40 || knight_pos == goblin_pos[3] + 40) && goblin_blood[3] > 0)
            next_knight_blood = knight_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_knight_blood = knight_blood;
    // mushrooms' turn to attack
    else if(monster_state == 1 && animation_count == 10)
        if((knight_pos == mushroom_pos[0] - 1 || knight_pos == mushroom_pos[0] + 1 || knight_pos == mushroom_pos[0] - 40 || knight_pos == mushroom_pos[0] + 40) && mushroom_blood[0] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == mushroom_pos[1] - 1 || knight_pos == mushroom_pos[1] + 1 || knight_pos == mushroom_pos[1] - 40 || knight_pos == mushroom_pos[1] + 40) && mushroom_blood[1] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == mushroom_pos[2] - 1 || knight_pos == mushroom_pos[2] + 1 || knight_pos == mushroom_pos[2] - 40 || knight_pos == mushroom_pos[2] + 40) && mushroom_blood[2] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((knight_pos == mushroom_pos[3] - 1 || knight_pos == mushroom_pos[3] + 1 || knight_pos == mushroom_pos[3] - 40 || knight_pos == mushroom_pos[3] + 40) && mushroom_blood[3] > 0)
            next_knight_blood = knight_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (knight_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_knight_blood = knight_blood;
    else
        next_knight_blood = knight_blood;
end

// wizard blood
always @(posedge clk_div[21]) begin
    if(rst || game_rst)
        wizard_blood <= 80;
    else
        wizard_blood <= next_wizard_blood;
end

always @(*) begin
    // skeleton's turn to attack
    if(monster_state == 1 && animation_count == 7)
        if((wizard_pos == skeleton_pos[0] - 1 || wizard_pos == skeleton_pos[0] + 1 || wizard_pos == skeleton_pos[0] - 40 || wizard_pos == skeleton_pos[0] + 40) && skeleton_blood[0] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == skeleton_pos[1] - 1 || wizard_pos == skeleton_pos[1] + 1 || wizard_pos == skeleton_pos[1] - 40 || wizard_pos == skeleton_pos[1] + 40) && skeleton_blood[1] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == skeleton_pos[2] - 1 || wizard_pos == skeleton_pos[2] + 1 || wizard_pos == skeleton_pos[2] - 40 || wizard_pos == skeleton_pos[2] + 40) && skeleton_blood[2] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == skeleton_pos[3] - 1 || wizard_pos == skeleton_pos[3] + 1 || wizard_pos == skeleton_pos[3] - 40 || wizard_pos == skeleton_pos[3] + 40) && skeleton_blood[3] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_wizard_blood = wizard_blood;
    // eyes' turn to attack
    else if(monster_state == 1 && animation_count == 8)
        if((wizard_pos / 40 == eye_pos[0] / 40 || (wizard_pos % 40) == (eye_pos[0] % 40)) && eye_blood[0] > 0)
            next_wizard_blood = wizard_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos / 40 == eye_pos[1] / 40 || (wizard_pos % 40) == (eye_pos[1] % 40)) && eye_blood[1] > 0)
            next_wizard_blood = wizard_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos / 40 == eye_pos[2] / 40 || (wizard_pos % 40) == (eye_pos[2] % 40)) && eye_blood[2] > 0)
            next_wizard_blood = wizard_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos / 40 == eye_pos[3] / 40 || (wizard_pos % 40) == (eye_pos[3] % 40)) && eye_blood[3] > 0)
            next_wizard_blood = wizard_blood > ((16 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (16 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_wizard_blood = wizard_blood;
    // goblin's turn to attack
    else if(monster_state == 1 && animation_count == 9)
        if((wizard_pos == goblin_pos[0] - 1 || wizard_pos == goblin_pos[0] + 1 || wizard_pos == goblin_pos[0] - 40 || wizard_pos == goblin_pos[0] + 40) && goblin_blood[0] > 0)
            next_wizard_blood = wizard_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == goblin_pos[1] - 1 || wizard_pos == goblin_pos[1] + 1 || wizard_pos == goblin_pos[1] - 40 || wizard_pos == goblin_pos[1] + 40) && goblin_blood[1] > 0)
            next_wizard_blood = wizard_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == goblin_pos[2] - 1 || wizard_pos == goblin_pos[2] + 1 || wizard_pos == goblin_pos[2] - 40 || wizard_pos == goblin_pos[2] + 40) && goblin_blood[2] > 0)
            next_wizard_blood = wizard_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == goblin_pos[3] - 1 || wizard_pos == goblin_pos[3] + 1 || wizard_pos == goblin_pos[3] - 40 || wizard_pos == goblin_pos[3] + 40) && goblin_blood[3] > 0)
            next_wizard_blood = wizard_blood > ((30 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (30 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_wizard_blood = wizard_blood;
    // mushrooms' turn to attack
    else if(monster_state == 1 && animation_count == 10)
        if((wizard_pos == mushroom_pos[0] - 1 || wizard_pos == mushroom_pos[0] + 1 || wizard_pos == mushroom_pos[0] - 40 || wizard_pos == mushroom_pos[0] + 40) && mushroom_blood[0] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == mushroom_pos[1] - 1 || wizard_pos == mushroom_pos[1] + 1 || wizard_pos == mushroom_pos[1] - 40 || wizard_pos == mushroom_pos[1] + 40) && mushroom_blood[1] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == mushroom_pos[2] - 1 || wizard_pos == mushroom_pos[2] + 1 || wizard_pos == mushroom_pos[2] - 40 || wizard_pos == mushroom_pos[2] + 40) && mushroom_blood[2] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else if((wizard_pos == mushroom_pos[3] - 1 || wizard_pos == mushroom_pos[3] + 1 || wizard_pos == mushroom_pos[3] - 40 || wizard_pos == mushroom_pos[3] + 40) && mushroom_blood[3] > 0)
            next_wizard_blood = wizard_blood > ((24 * (1 + monster_strength)) * rand_test[7:6] / 4) ? (wizard_blood - (24 * (1 + monster_strength)) * rand_test[7:6] / 4) : 0;
        else
            next_wizard_blood = wizard_blood;
    else
        next_wizard_blood = wizard_blood;
end

// monster's blood
// skeleton
always @(posedge clk_div[21]) begin
    if(rst || game_rst) begin
        skeleton_blood[0] <= 40;
        skeleton_blood[1] <= 40;
        skeleton_blood[2] <= 40;
        skeleton_blood[3] <= 40;
    end
    else begin
        skeleton_blood[0] <= next_skeleton_blood[0];
        skeleton_blood[1] <= next_skeleton_blood[1];
        skeleton_blood[2] <= next_skeleton_blood[2];
        skeleton_blood[3] <= next_skeleton_blood[3];
    end
end

always @(*) begin
    next_skeleton_blood[0] = skeleton_blood[0];
    next_skeleton_blood[1] = skeleton_blood[1];
    next_skeleton_blood[2] = skeleton_blood[2];
    next_skeleton_blood[3] = skeleton_blood[3];

    if(knight_state == attack && animation_count == 1)
        case(selected_pos)
            skeleton_pos[0]:
                next_skeleton_blood[0] = skeleton_blood[0] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (skeleton_blood[0] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[1]:
                next_skeleton_blood[1] = skeleton_blood[1] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (skeleton_blood[1] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[2]:
                next_skeleton_blood[2] = skeleton_blood[2] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (skeleton_blood[2] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[3]:
                next_skeleton_blood[3] = skeleton_blood[3] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (skeleton_blood[3] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_skeleton_blood[0] = skeleton_blood[0];     // just for filling default
        endcase
    else if(wizard_state == attack && animation_count == 1)
        case(selected_pos)
            skeleton_pos[0]:
                next_skeleton_blood[0] = skeleton_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) > 0 ? (skeleton_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[1]:
                next_skeleton_blood[1] = skeleton_blood[1] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) > 0 ? (skeleton_blood[1] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[2]:
                next_skeleton_blood[2] = skeleton_blood[2] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) > 0 ? (skeleton_blood[2] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            skeleton_pos[3]:
                next_skeleton_blood[3] = skeleton_blood[3] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) > 0 ? (skeleton_blood[3] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_skeleton_blood[0] = skeleton_blood[0];     // just for filling default
        endcase
end

// eye
always @(posedge clk_div[21]) begin
    if(rst || game_rst) begin
        eye_blood[0] <= 87;
        eye_blood[1] <= 25;
        eye_blood[2] <= 25;
        eye_blood[3] <= 25;
    end
    else begin
        eye_blood[0] <= next_eye_blood[0];
        eye_blood[1] <= next_eye_blood[1];
        eye_blood[2] <= next_eye_blood[2];
        eye_blood[3] <= next_eye_blood[3];
    end
end

always @(*) begin
    next_eye_blood[0] = eye_blood[0];
    next_eye_blood[1] = eye_blood[1];
    next_eye_blood[2] = eye_blood[2];
    next_eye_blood[3] = eye_blood[3];

    if(knight_state == attack && animation_count == 1)
        case(selected_pos)
            eye_pos[0]:
                next_eye_blood[0] = eye_blood[0] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[0] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[1]:
                next_eye_blood[1] = eye_blood[1] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[1] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[2]:
                next_eye_blood[2] = eye_blood[2] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[2] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[3]:
                next_eye_blood[3] = eye_blood[3] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[3] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_eye_blood[0] = eye_blood[0];     // just for filling default
        endcase
    else if(wizard_state == attack && animation_count == 1)
        case(selected_pos)
            eye_pos[0]:
                next_eye_blood[0] = eye_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[1]:
                next_eye_blood[1] = eye_blood[1] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[1] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[2]:
                next_eye_blood[2] = eye_blood[2] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[2] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            eye_pos[3]:
                next_eye_blood[3] = eye_blood[3] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (eye_blood[3] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_eye_blood[0] = eye_blood[0];     // just for filling default
        endcase
end

// goblin
always @(posedge clk_div[21]) begin
    if(rst || game_rst) begin
        goblin_blood[0] <= 16;
        goblin_blood[1] <= 16;
        goblin_blood[2] <= 16;
        goblin_blood[3] <= 16;
    end
    else begin
        goblin_blood[0] <= next_goblin_blood[0];
        goblin_blood[1] <= next_goblin_blood[1];
        goblin_blood[2] <= next_goblin_blood[2];
        goblin_blood[3] <= next_goblin_blood[3];
    end
end

always @(*) begin
    next_goblin_blood[0] = goblin_blood[0];
    next_goblin_blood[1] = goblin_blood[1];
    next_goblin_blood[2] = goblin_blood[2];
    next_goblin_blood[3] = goblin_blood[3];

    if(knight_state == attack && animation_count == 1)
        case(selected_pos)
            goblin_pos[0]:
                next_goblin_blood[0] = goblin_blood[0] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[0] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[1]:
                next_goblin_blood[1] = goblin_blood[1] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[1] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[2]:
                next_goblin_blood[2] = goblin_blood[2] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[2] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[3]:
                next_goblin_blood[3] = goblin_blood[3] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[3] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_goblin_blood[0] = goblin_blood[0];     // just for filling default
        endcase
    else if(wizard_state == attack && animation_count == 1)
        case(selected_pos)
            goblin_pos[0]:
                next_goblin_blood[0] = goblin_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[1]:
                next_goblin_blood[1] = goblin_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[2]:
                next_goblin_blood[2] = goblin_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            goblin_pos[3]:
                next_goblin_blood[3] = goblin_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (goblin_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_goblin_blood[0] = goblin_blood[0];     // just for filling default
        endcase
end

// mushroom
always @(posedge clk_div[21]) begin
    if(rst || game_rst) begin
        mushroom_blood[0] <= 60;
        mushroom_blood[1] <= 60;
        mushroom_blood[2] <= 60;
        mushroom_blood[3] <= 60;
    end
    else begin
        mushroom_blood[0] <= next_mushroom_blood[0];
        mushroom_blood[1] <= next_mushroom_blood[1];
        mushroom_blood[2] <= next_mushroom_blood[2];
        mushroom_blood[3] <= next_mushroom_blood[3];
    end
end

always @(*) begin
    next_mushroom_blood[0] = mushroom_blood[0];
    next_mushroom_blood[1] = mushroom_blood[1];
    next_mushroom_blood[2] = mushroom_blood[2];
    next_mushroom_blood[3] = mushroom_blood[3];

    if(knight_state == attack && animation_count == 1)
        case(selected_pos)
            mushroom_pos[0]:
                next_mushroom_blood[0] = mushroom_blood[0] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[0] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[1]:
                next_mushroom_blood[1] = mushroom_blood[1] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[1] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[2]:
                next_mushroom_blood[2] = mushroom_blood[2] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[2] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[3]:
                next_mushroom_blood[3] = mushroom_blood[3] > ((20 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[3] - (20 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_mushroom_blood[0] = mushroom_blood[0];     // just for filling default
        endcase
    else if(wizard_state == attack && animation_count == 1)
        case(selected_pos)
            mushroom_pos[0]:
                next_mushroom_blood[0] = mushroom_blood[0] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[0] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[1]:
                next_mushroom_blood[1] = mushroom_blood[1] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[1] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[2]:
                next_mushroom_blood[2] = mushroom_blood[2] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[2] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            mushroom_pos[3]:
                next_mushroom_blood[3] = mushroom_blood[3] > ((35 * (1 + player_strength)) * rand_test[7:6] / 4) ? (mushroom_blood[3] - (35 * (1 + player_strength)) * rand_test[7:6] / 4) : 0;
            default:
                next_mushroom_blood[0] = mushroom_blood[0];     // just for filling default
        endcase
end

always @(*) begin
    if (selected_pos == knight_pos)
        show_blood = knight_blood;
    else if (selected_pos == wizard_pos)
        show_blood = wizard_blood;
    else if (selected_pos == skeleton_pos[0])
        show_blood = skeleton_blood[0];
    else if (selected_pos == skeleton_pos[1])
        show_blood = skeleton_blood[1];
    else if (selected_pos == skeleton_pos[2])
        show_blood = skeleton_blood[2];
    else if (selected_pos == skeleton_pos[3])
        show_blood = skeleton_blood[3];
    else if (selected_pos == eye_pos[0])
        show_blood = eye_blood[0];
    else if (selected_pos == eye_pos[1])
        show_blood = eye_blood[1];
    else if (selected_pos == eye_pos[2])
        show_blood = eye_blood[2];
    else if (selected_pos == eye_pos[3])
        show_blood = eye_blood[3];
    else if (selected_pos == goblin_pos[0])
        show_blood = goblin_blood[0];
    else if (selected_pos == goblin_pos[1])
        show_blood = goblin_blood[1];
    else if (selected_pos == goblin_pos[2])
        show_blood = goblin_blood[2];
    else if (selected_pos == goblin_pos[3])
        show_blood = goblin_blood[3];
    else if (selected_pos == mushroom_pos[0])
        show_blood = mushroom_blood[0];
    else if (selected_pos == mushroom_pos[1])
        show_blood = mushroom_blood[1];
    else if (selected_pos == mushroom_pos[2])
        show_blood = mushroom_blood[2];
    else if (selected_pos == mushroom_pos[3])
        show_blood = mushroom_blood[3];
    else
        show_blood = 0;
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
    next_rand = {(rand_num[4] ^ rand_num[3] ^ rand_num[2] ^ rand_num[0]), rand_num[7:1]};
end

endmodule
