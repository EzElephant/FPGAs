module music(
    input clk,
    input clk_25MHz,
    input clk_div,
    input rst,
    input [2:0] effect_control,
    input _volUP,
    input _volDOWN,
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin  // serial audio data input
);

parameter BGM = 0;
parameter EFFECT = 1;

wire mute;
wire [4:0] bgm_freq_numL, bgm_freq_numR, effect_freq_num;
wire [15:0] audio_in_left, audio_in_right;

reg [31:0] freqL, freqR;
reg [21:0] freq_outL, freq_outR;
reg [12:0] bgm_counter, next_bgm_counter, effect_counter, next_effect_counter;
reg [4:0] freq_numL, freq_numR;
reg [2:0] vol, next_vol, music_state, next_music_state;

blk_mem_gen_msuic0 bgm_l(.clka(clk_25MHz), .addra(bgm_counter), .douta(bgm_freq_numL));
blk_mem_gen_msuic1 bgm_r(.clka(clk_25MHz), .addra(bgm_counter), .douta(bgm_freq_numR));
// blk_mem_gen_msuic2 effect(.clka(clk_25MHz), .addra(effect_counter), .douta(effect_freq_num));

always @(posedge clk) begin
    if (rst) begin
        music_state <= BGM;
    end
    else begin
        music_state <= next_music_state;
    end
end

always @(posedge clk_div or posedge rst) begin
    if (rst) begin
        bgm_counter <= 0;
        effect_counter <= 0;
    end
    else begin
        bgm_counter <= next_bgm_counter;
        effect_counter <= next_effect_counter;
    end
end

always @(*) begin
    next_music_state = music_state;
    case (music_state)
        BGM: begin
            if (effect_control == 1)
                next_music_state = EFFECT;
            freq_numL = bgm_freq_numL;
            freq_numR = bgm_freq_numR;
        end
        EFFECT: begin
            if (effect_counter == 9487)
                next_music_state = BGM;
            freq_numL = effect_freq_num;
            freq_numR = effect_freq_num;
        end
    endcase
end

always @(*) begin
    case (music_state)
        BGM: begin
            case (freq_numL)
                0:  freqL = 50000000;
                1:  freqL = 831;
                2:  freqL = 1661;
                3:  freqL = 831;
                4:  freqL = 415;
                5:  freqL = 196;
                6:  freqL = 220;
                7:  freqL = 247;
                8:  freqL = 262;
                9:  freqL = 294;
                10: freqL = 330;
                11: freqL = 349;
                12: freqL = 392;
                13: freqL = 440;
                14: freqL = 494;
                15: freqL = 523;
                16: freqL = 587;
                17: freqL = 659;
                18: freqL = 698;
                19: freqL = 784;
                20: freqL = 880;
                21: freqL = 988;
                22: freqL = 1046;
                23: freqL = 1148;
                24: freqL = 1319;
                25: freqL = 1397;
                26: freqL = 1568;
                27: freqL = 1760;
                28: freqL = 1976;
                default: freqL = 50000000;
            endcase
            case (freq_numR)
                0:  freqR = 50000000;
                1:  freqR = 831;
                2:  freqR = 1661;
                3:  freqR = 831;
                4:  freqR = 415;
                5:  freqR = 196;
                6:  freqR = 220;
                7:  freqR = 247;
                8:  freqR = 262;
                9:  freqR = 294;
                10: freqR = 330;
                11: freqR = 349;
                12: freqR = 392;
                13: freqR = 440;
                14: freqR = 494;
                15: freqR = 523;
                16: freqR = 587;
                17: freqR = 659;
                18: freqR = 698;
                19: freqR = 784;
                20: freqR = 880;
                21: freqR = 988;
                22: freqR = 1046;
                23: freqR = 1148;
                24: freqR = 1319;
                25: freqR = 1397;
                26: freqR = 1568;
                27: freqR = 1760;
                28: freqR = 1976;
                default: freqR = 50000000;
            endcase
        end
        EFFECT: begin
            freqL = 50000000;
            freqR = 50000000;
        end
    endcase
end

always @(*) begin
    if (bgm_counter == 1199)
        next_bgm_counter = 0;
    else
        next_bgm_counter = bgm_counter + 1;

    if (music_state == BGM)
        next_effect_counter = 0;
    else
        next_effect_counter = effect_counter + 1;
end

always @(posedge clk) begin
    if (rst) begin
        vol <= 2;
    end
    else begin
        vol <= next_vol;
    end
end

always @(*) begin
    next_vol = vol;
    if (_volUP && vol != 5)
        next_vol = vol + 1;
    if (_volDOWN && vol != 0)
        next_vol = vol - 1;
end

assign mute = (vol == 0);

always @(*) begin
    freq_outL = 50000000 / freqL;
    freq_outR = 50000000 / freqR;
end

note_gen noteGen_00(
    .clk(clk), 
    .rst(rst), 
    .volume(vol),
    .mute(mute),
    .note_div_left(freq_outL), 
    .note_div_right(freq_outR), 
    .audio_left(audio_in_left),
    .audio_right(audio_in_right)
);

// Speaker controller
speaker_control sc(
    .clk(clk), 
    .rst(rst), 
    .audio_in_left(audio_in_left),
    .audio_in_right(audio_in_right),
    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_sck(audio_sck),
    .audio_sdin(audio_sdin)
);

endmodule


module note_gen(
    clk, // clock from crystal
    rst, // active high reset
    volume,
    mute,
    note_div_left, // div for note generation
    note_div_right,
    audio_left,
    audio_right
);

    // I/O declaration
    input clk; // clock from crystal
    input rst; // active low reset
    input mute;
    input [2:0] volume;
    input [21:0] note_div_left, note_div_right; // div for note generation
    output reg [15:0] audio_left, audio_right;

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
    
    // clk_cnt_next, b_clk_next
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    // clk_cnt_next_2, c_clk_next
    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end

    // Assign the amplitude of the note
    // Volume is controlled here
    // assign audio_left = (note_div_left == 22'd1) ? 16'h0000 : 
    //                             (b_clk == 1'b0) ? 16'hE000 : 16'h2000;
    // assign audio_right = (note_div_right == 22'd1) ? 16'h0000 : 
    //                             (c_clk == 1'b0) ? 16'hE000 : 16'h2000;
    always @(*)
    begin
        audio_left = 16'h0000;
        audio_right = 16'h0000;
        if (!mute)
        begin
            if (note_div_left == 1)
            begin
                audio_left = 16'h0000;
            end
            else if (b_clk == 0)
            begin
                case (volume)
                    1: audio_left = 16'hE000;
                    2: audio_left = 16'hD000;
                    3: audio_left = 16'hC000;
                    4: audio_left = 16'hB000;
                    5: audio_left = 16'hA000;
                endcase
            end
            else
            begin
                case (volume)
                    1: audio_left = 16'h2000;
                    2: audio_left = 16'h3000;
                    3: audio_left = 16'h4000;
                    4: audio_left = 16'h5000;
                    5: audio_left = 16'h6000;
                endcase
            end
            if (note_div_right == 1)
            begin
                audio_right = 16'h0000;
            end
            else if (c_clk == 0)
            begin
                case (volume)
                    0: audio_right = 0;
                    1: audio_right = 16'hE000;
                    2: audio_right = 16'hD000;
                    3: audio_right = 16'hC000;
                    4: audio_right = 16'hB000;
                    5: audio_right = 16'hA000;
                endcase
            end
            else
            begin
                case (volume)
                    0: audio_right = 0;
                    1: audio_right = 16'h2000;
                    2: audio_right = 16'h3000;
                    3: audio_right = 16'h4000;
                    4: audio_right = 16'h5000;
                    5: audio_right = 16'h6000;
                endcase
            end
        end
    end
endmodule

module speaker_control(
    clk,  // clock from the crystal
    rst,  // active high reset
    audio_in_left, // left channel audio data input
    audio_in_right, // right channel audio data input
    audio_mclk, // master clock
    audio_lrck, // left-right clock, Word Select clock, or sample rate clock
    audio_sck, // serial clock
    audio_sdin // serial audio data input
);

    // I/O declaration
    input clk;  // clock from the crystal
    input rst;  // active high reset
    input [15:0] audio_in_left; // left channel audio data input
    input [15:0] audio_in_right; // right channel audio data input
    output audio_mclk; // master clock
    output audio_lrck; // left-right clock
    output audio_sck; // serial clock
    output audio_sdin; // serial audio data input
    reg audio_sdin;

    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next;
    reg [8:0] clk_cnt;
    reg [15:0] audio_left, audio_right;

    // Counter for the clock divider
    assign clk_cnt_next = clk_cnt + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt <= 9'd0;
        else
            clk_cnt <= clk_cnt_next;

    // Assign divided clock output
    assign audio_mclk = clk_cnt[1];
    assign audio_lrck = clk_cnt[8];
    assign audio_sck = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left <= 16'd0;
                audio_right <= 16'd0;
            end
        else
            begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end

    always @*
        case (clk_cnt[8:4])
            5'b00000: audio_sdin = audio_right[0];
            5'b00001: audio_sdin = audio_left[15];
            5'b00010: audio_sdin = audio_left[14];
            5'b00011: audio_sdin = audio_left[13];
            5'b00100: audio_sdin = audio_left[12];
            5'b00101: audio_sdin = audio_left[11];
            5'b00110: audio_sdin = audio_left[10];
            5'b00111: audio_sdin = audio_left[9];
            5'b01000: audio_sdin = audio_left[8];
            5'b01001: audio_sdin = audio_left[7];
            5'b01010: audio_sdin = audio_left[6];
            5'b01011: audio_sdin = audio_left[5];
            5'b01100: audio_sdin = audio_left[4];
            5'b01101: audio_sdin = audio_left[3];
            5'b01110: audio_sdin = audio_left[2];
            5'b01111: audio_sdin = audio_left[1];
            5'b10000: audio_sdin = audio_left[0];
            5'b10001: audio_sdin = audio_right[15];
            5'b10010: audio_sdin = audio_right[14];
            5'b10011: audio_sdin = audio_right[13];
            5'b10100: audio_sdin = audio_right[12];
            5'b10101: audio_sdin = audio_right[11];
            5'b10110: audio_sdin = audio_right[10];
            5'b10111: audio_sdin = audio_right[9];
            5'b11000: audio_sdin = audio_right[8];
            5'b11001: audio_sdin = audio_right[7];
            5'b11010: audio_sdin = audio_right[6];
            5'b11011: audio_sdin = audio_right[5];
            5'b11100: audio_sdin = audio_right[4];
            5'b11101: audio_sdin = audio_right[3];
            5'b11110: audio_sdin = audio_right[2];
            5'b11111: audio_sdin = audio_right[1];
            default: audio_sdin = 1'b0;
        endcase

endmodule