# for block memory (ROM)

## for spites
This one is for map sprites
blk_mem_gen_0
width : 12 bits (RGB)
depth : 15360 (32 * 480)
coe file is included in assets

This one is for knight sprites
blk_mem_gen_2
width : 12 bits (RGB)
depth : 6144 (32 * 192)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for wizard sprites
blk_mem_gen_3
width : 12 bits (RGB)
depth : 6144 (32 * 224)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for skeleton sprites
blk_mem_gen_4
width : 12 bits (RGB)
depth : 6144 (32 * 192)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for eye sprites
blk_mem_gen_5
width : 12 bits (RGB)
depth : 6144 (32 * 192)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for goblin sprites
blk_mem_gen_6
width : 12 bits (RGB)
depth : 6144 (32 * 192)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for mushroom sprites
blk_mem_gen_7
width : 12 bits (RGB)
depth : 6144 (32 * 192)
ports : addra[12:0]
        clka
        douta[11:0]

This one is for map index
blk_mem_gen_8
width : 4 bits
depth : 1200 (40 * 30)
module name : blk_men_gen_1
ports : addra[10:0]
        clka
        douta[3:0]

## for music
This one is for bgm left
blk_mem_gen_msuic0
width : 5 bits (freq_num)
depth : 1200 (1 dimension)
ports : addra[10:0]
        clka
        douta[4:0]

This one is for bgm right
blk_mem_gen_msuic1
width : 5 bits (freq_num)
depth : 1200 (1 dimension)
ports : addra[10:0]
        clka
        douta[4:0]

## for scene
This one is for title scene
blk_mem_gen_scene_0
width : 12 bits (RGB)
depth : 19200 (160 * 120)
ports : addra[14:0]
        clka
        douta[11:0]

This one is for lost scene
blk_mem_gen_scene_1
width : 12 bits (RGB)
depth : 19200 (160 * 120)
ports : addra[14:0]
        clka
        douta[11:0]

This one is for win scene
blk_mem_gen_scene_2
width : 12 bits (RGB)
depth : 19200 (160 * 120)
ports : addra[14:0]
        clka
        douta[11:0]
        
# for block memory (RAM)
This one is for map index
blk_mem_gen_1
width : 4 bits
depth : 1200 (40 * 30)
module name : blk_men_gen_1
ports : addra[10:0]
        clka
        dina[3:0]
        douta[3:0]
        wea[0:0]
