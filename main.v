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

parameter move = 2'b00;
parameter attack = 2'b01;
parameter hit = 2'b10;
parameter idle = 2'b11;

wire click, down_click;
wire click_d, down_click_d;
wire click_pulse, down_click_pulse;
wire move_left, move_right, move_up, move_down;
wire scroll_left, scroll_right, scroll_up, scroll_down;
wire [26:0] clk_div;
wire [7:0] rand_test;
wire [4:0] i, j;
reg [4:0] choose_x, choose_y, next_choose_x, next_choose_y;
reg [8:0] write_count, next_write_count;
reg [8:0] scroll_x, scroll_y, next_scroll_x, next_scroll_y;

// animation counter
reg [19:0] offset_count;
reg [3:0] animation_count;

// record which block has character
// in 20 * 15 map, 0 for h_cnt, 1 for v_cnt
reg [8:0] action_pos, next_action_pos;
wire [8:0] selected_pos;
reg [8:0] knight_pos = 125; 
reg [8:0] wizard_pos = 167;

reg [1:0] player_state, next_player_state;
reg [1:0] knight_state, next_knight_state;
reg [1:0] wizard_state, next_wizard_state;
reg monster_state, next_monster_state;

clock_divider clock_divider_25(.clk(clk), .clk_div(clk_div));
                    
vga VGA(.clk_25MHz(clk_div[1]),
        .animation_count(animation_count),
        .player_state(player_state),
        .knight_state(knight_state),
        .wizard_state(wizard_state),
        .monster_state(monster_state),
        .action_pos(action_pos),
        .selected_pos(selected_pos),
        .knight_pos(knight_pos),
        .wizard_pos(wizard_pos),
        .final_pixel({vgaRed, vgaGreen, vgaBlue}), 
        .hsync(hsync), 
        .vsync(vsync)
);


LSFR random_gen(.clk(clk_div[23]), .rand_num(rand_test), .rst(rst));

assign LED = rand_test;

debounce cen_push(.clk(clk_div[1]), .pb(click), .pb_debounced(click_d));
one_pulse cen_push_pulse(.clk(clk_div[1]), .pb_in(click_d), .pb_out(click_pulse));

debounce down_push(.clk(clk_div[1]), .pb(down_click), .pb_debounced(down_click_d));
one_pulse down_push_pulse(.clk(clk_div[1]), .pb_in(down_click_d), .pb_out(down_click_pulse));

rocker1 rocker1(.clk(clk), .rst(rst), .MISO(MISO_1), .SS(SS_1), .MOSI(MOSI_1), .SCLK(SCLK_1),
.left(move_left), .right(move_right), .up(move_up), .down(move_down), .click(click), .down_click(down_click));

rocker2 rocker2(.clk(clk), .rst(rst), .MISO(MISO_2), .SS(SS_2), .MOSI(MOSI_2), .SCLK(SCLK_2),
.left(scroll_right), .right(scroll_left), .up(scroll_up), .down(scroll_down), .click(), .down_click());

seven_segment Seven_segment(.clk_div(clk_div[15]), .data0(choose_x), .data1(choose_y), .DISPLAY(DISPLAY), .DIGIT(DIGIT));

assign selected_pos = ({4'b0000, choose_y} * 20) + {4'b0000, choose_x};

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
    next_scroll_x = scroll_x;
    next_scroll_y = scroll_y;
    if (scroll_up && choose_y != 0)
        next_scroll_y = choose_y - 1;
    if (scroll_down && choose_y != 480)
        next_scroll_y = choose_y + 1;
    if (scroll_left && choose_x != 0)
        next_scroll_x = choose_x - 1;
    if (scroll_right && choose_x != 640)
        next_scroll_x = choose_x + 1;  
end

// offset counter for animation counter
always @(posedge clk_div[1] or posedge down_click_pulse) begin
    if(rst || down_click_pulse)
        offset_count <= 0;
    else
        offset_count <= offset_count + 1;
end

// animation counter
always @(posedge clk_div[1] or posedge down_click_pulse) begin
    if(down_click_pulse && player_state == attack)
        animation_count <= 1;
    else if(offset_count == 20'b1111_1111_1111_1111_1111)
        animation_count <= animation_count + 1;
    else
        animation_count <= animation_count;
end


// player FSM
always @(posedge clk_div[1]) begin
    if(rst)
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
    if(rst)
        knight_state <= idle;
    else 
        knight_state <= next_knight_state;
end

always @(*) begin
    if(wizard_state == hit)
        next_knight_state = hit;
    else if(knight_state == idle)
        if(action_pos == knight_pos && down_click_pulse && player_state == attack)
            next_knight_state = attack;
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
    if(rst)
        wizard_state <= idle;
    else 
        wizard_state <= next_wizard_state;
end

always @(*) begin
    case(wizard_state)
        idle:
            if(action_pos == wizard_pos && down_click_pulse && player_state == attack)
                next_wizard_state = attack;
            else if(action_pos == wizard_pos && down_click_pulse)
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
    if(rst)
        monster_state <= 0;
    else 
        monster_state <= next_monster_state;
end

always @(*) begin
    case(monster_state)
        0:  // idle
            if(wizard_state == hit)
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

// TODO...
// action character position
always @(posedge clk_div[1]) begin
    if(rst)
        action_pos <= knight_pos;
    else
        action_pos <= next_action_pos;
end

always @(*) begin
    if(action_pos == knight_pos)
        if(down_click_pulse && player_state == move)
            next_action_pos = wizard_pos;
        else if(knight_state == attack && animation_count == 0)
            next_action_pos = wizard_pos;
        else
            next_action_pos = knight_pos;
    else if(action_pos == wizard_pos)
        if(down_click_pulse && player_state == move)
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
// knight_pos blablabla...

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