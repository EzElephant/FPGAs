This is the coding note for FPGAs final Project.

git push repository: https://github.com/EzElephant/FPGAs.git

# for block memory (ROM)
This one is for map sprites
blk_mem_gen_0
width : 12 bits (RGB)
depth :11264 (32 * 352)
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

# for block memory (RAM)
This one is for map index
blk_mem_gen_1
width : 4 bits
depth : 300 (20 * 15)
module name : blk_men_gen_1
ports : addra[8:0]
        clka
        dina[3:0]
        douta[3:0]
        wea[0:0]
