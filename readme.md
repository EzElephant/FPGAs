This is the coding note for FPGAs final Project.

# for block memory (ROM)
width : 12 bits (RGB)
depth :11264 (32 * 352)
coe file is included in assets

# for block memory (RAM)
width : 4 bits
depth : 300 (20 * 15)
module name : blk_men_gen_1
ports : addra[8:0]
        clka
        dina[3:0]
        douta[3:0]
        wea[0:0]