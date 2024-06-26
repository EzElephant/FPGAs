## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
##   (if you are using the editor in Vivado, you can select lines and hit "Ctrl + /" to comment/uncomment.)
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Switches
set_property PACKAGE_PIN V17 [get_ports {monster_boost[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[0]}]
set_property PACKAGE_PIN V16 [get_ports {monster_boost[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[3]}]
set_property PACKAGE_PIN W16 [get_ports {monster_boost[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[4]}]
set_property PACKAGE_PIN W17 [get_ports {monster_boost[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[6]}]
set_property PACKAGE_PIN W15 [get_ports {monster_boost[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[5]}]
set_property PACKAGE_PIN V15 [get_ports {monster_boost[2]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[2]}]
set_property PACKAGE_PIN W14 [get_ports {monster_boost[1]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {monster_boost[1]}]
set_property PACKAGE_PIN W13 [get_ports {player_boost[6]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[6]}]
set_property PACKAGE_PIN V2 [get_ports {player_boost[7]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[7]}]
set_property PACKAGE_PIN T3 [get_ports {player_boost[5]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[5]}]
set_property PACKAGE_PIN T2 [get_ports {player_boost[4]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[4]}]
set_property PACKAGE_PIN R3 [get_ports {player_boost[0]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[0]}]
set_property PACKAGE_PIN W2 [get_ports {player_boost[1]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[1]}]
set_property PACKAGE_PIN U1 [get_ports {player_boost[3]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[3]}]
set_property PACKAGE_PIN T1 [get_ports {player_boost[2]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {player_boost[2]}]
set_property PACKAGE_PIN R2 [get_ports {cheat_mode}]
   set_property IOSTANDARD LVCMOS33 [get_ports {cheat_mode}]


# # LEDs
 set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]

# 7 segment display
 set_property PACKAGE_PIN W7 [get_ports {DISPLAY[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[0]}]
 set_property PACKAGE_PIN W6 [get_ports {DISPLAY[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[1]}]
 set_property PACKAGE_PIN U8 [get_ports {DISPLAY[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[2]}]
 set_property PACKAGE_PIN V8 [get_ports {DISPLAY[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[3]}]
 set_property PACKAGE_PIN U5 [get_ports {DISPLAY[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[4]}]
 set_property PACKAGE_PIN V5 [get_ports {DISPLAY[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[5]}]
 set_property PACKAGE_PIN U7 [get_ports {DISPLAY[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[6]}]

# set_property PACKAGE_PIN V7 [get_ports dp]
#    set_property IOSTANDARD LVCMOS33 [get_ports dp]

 set_property PACKAGE_PIN U2 [get_ports {DIGIT[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[0]}]
 set_property PACKAGE_PIN U4 [get_ports {DIGIT[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[1]}]
 set_property PACKAGE_PIN V4 [get_ports {DIGIT[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[2]}]
 set_property PACKAGE_PIN W4 [get_ports {DIGIT[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[3]}]
#===========================================
# 7 segment display
#  set_property PACKAGE_PIN W7 [get_ports {DISPLAY[0]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[0]}]
#  set_property PACKAGE_PIN W6 [get_ports {DISPLAY[1]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[1]}]
#  set_property PACKAGE_PIN U8 [get_ports {DISPLAY[2]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[2]}]
#  set_property PACKAGE_PIN V8 [get_ports {DISPLAY[3]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[3]}]
#  set_property PACKAGE_PIN U5 [get_ports {DISPLAY[4]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[4]}]
#  set_property PACKAGE_PIN V5 [get_ports {DISPLAY[5]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[5]}]
#  set_property PACKAGE_PIN U7 [get_ports {DISPLAY[6]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DISPLAY[6]}]

# set_property PACKAGE_PIN V7 [get_ports dp]
#    set_property IOSTANDARD LVCMOS33 [get_ports dp]
#
#  set_property PACKAGE_PIN U2 [get_ports {DIGIT[0]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[0]}]
#  set_property PACKAGE_PIN U4 [get_ports {DIGIT[1]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[1]}]
#  set_property PACKAGE_PIN V4 [get_ports {DIGIT[2]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[2]}]
#  set_property PACKAGE_PIN W4 [get_ports {DIGIT[3]}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT[3]}]
#=============================================


# Buttons
 set_property PACKAGE_PIN U18 [get_ports rst]
    set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN T18 [get_ports btn_up]
   set_property IOSTANDARD LVCMOS33 [get_ports btn_up]
set_property PACKAGE_PIN W19 [get_ports btn_left]
   set_property IOSTANDARD LVCMOS33 [get_ports btn_left]
set_property PACKAGE_PIN T17 [get_ports btn_right]
   set_property IOSTANDARD LVCMOS33 [get_ports btn_right]
set_property PACKAGE_PIN U17 [get_ports btn_down]
   set_property IOSTANDARD LVCMOS33 [get_ports btn_down]



## Pmod Header JA
# set_property PACKAGE_PIN J1 [get_ports {SS_1}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {SS_1}]
# #Sch name = JA2
# set_property PACKAGE_PIN L2 [get_ports {MOSI_1}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {MOSI_1}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {down_click}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {down_click}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {click}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {click}]
# ## Sch name = JA7
#  set_property PACKAGE_PIN H1 [get_ports {left_pwm}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {left_pwm}]
# ## Sch name = JA8
#  set_property PACKAGE_PIN K2 [get_ports {right_pwm}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {right_pwm}]
## Sch name = JA9
# set_property PACKAGE_PIN H2 [get_ports {PWM_1}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {PWM_1}]
## Sch name = JA10
# set_property PACKAGE_PIN G3 [get_ports {sw0}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw0}]



## Pmod Header JB
## Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports audio_mclk]
    set_property IOSTANDARD LVCMOS33 [get_ports audio_mclk]
## Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports audio_lrck]
    set_property IOSTANDARD LVCMOS33 [get_ports audio_lrck]
## Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports audio_sck]
    set_property IOSTANDARD LVCMOS33 [get_ports audio_sck]
## Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports audio_sdin]
    set_property IOSTANDARD LVCMOS33 [get_ports audio_sdin]
## Sch name = JB7
# set_property PACKAGE_PIN A15 [get_ports {motor_cw[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {motor_cw[0]}]
## Sch name = JB8
#  set_property PACKAGE_PIN A17 [get_ports {right_track}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {right_track}]
## Sch name = JB9
#  set_property PACKAGE_PIN C15 [get_ports {mid_track}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {mid_track}]
## Sch name = JB10
#  set_property PACKAGE_PIN C16 [get_ports {left_track}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {left_track}]



# Pmod Header JC
# # Sch name = JC1
# set_property PACKAGE_PIN K17 [get_ports {l_move_left}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {l_move_left}]
# # Sch name = JC2
# set_property PACKAGE_PIN M18 [get_ports {l_move_right}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {l_move_right}]
# # Sch name = JC3
# set_property PACKAGE_PIN N17 [get_ports {l_move_up}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {l_move_up}]
# # Sch name = JC4
# set_property PACKAGE_PIN P18 [get_ports {l_move_down}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {l_move_down}]
# # Sch name = JC7
# set_property PACKAGE_PIN L17 [get_ports {r_move_left}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_move_left}]
# # Sch name = JC8
# set_property PACKAGE_PIN M19 [get_ports {r_move_right}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_move_right}]
# # Sch name = JC9
# set_property PACKAGE_PIN P17 [get_ports {r_move_up}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_move_up}]
# # Sch name = JC10
# set_property PACKAGE_PIN R18 [get_ports {r_move_down}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {r_move_down}]


## Pmod Header JXADC
# Sch name = XA1_P
set_property PACKAGE_PIN J3 [get_ports {l_move_down}]
   set_property IOSTANDARD LVCMOS33 [get_ports {l_move_down}]
# Sch name = XA2_P
set_property PACKAGE_PIN L3 [get_ports {l_move_up}]
   set_property IOSTANDARD LVCMOS33 [get_ports {l_move_up}]
# Sch name = XA3_P
set_property PACKAGE_PIN M2 [get_ports {l_move_right}]
   set_property IOSTANDARD LVCMOS33 [get_ports {l_move_right}]
# Sch name = XA4_P
set_property PACKAGE_PIN N2 [get_ports {l_move_left}]
  set_property IOSTANDARD LVCMOS33 [get_ports {l_move_left}]
# Sch name = XA1_N
set_property PACKAGE_PIN K3 [get_ports {r_move_down}]
   set_property IOSTANDARD LVCMOS33 [get_ports {r_move_down}]
# Sch name = XA2_N
set_property PACKAGE_PIN M3 [get_ports {r_move_up}]
   set_property IOSTANDARD LVCMOS33 [get_ports {r_move_up}]
# Sch name = XA3_N
set_property PACKAGE_PIN M1 [get_ports {r_move_right}]
   set_property IOSTANDARD LVCMOS33 [get_ports {r_move_right}]
# Sch name = XA4_N
set_property PACKAGE_PIN N1 [get_ports {r_move_left}]
   set_property IOSTANDARD LVCMOS33 [get_ports {r_move_left}]



## VGA Connector
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
   set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]


## USB-RS232 Interface
# set_property PACKAGE_PIN B18 [get_ports RsRx]
#    set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
# set_property PACKAGE_PIN A18 [get_ports RsTx]
#    set_property IOSTANDARD LVCMOS33 [get_ports RsTx]


## USB HID (PS/2)
# set_property PACKAGE_PIN C17 [get_ports PS2_CLK]
#    set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
#    set_property PULLUP true [get_ports PS2_CLK]
# set_property PACKAGE_PIN B17 [get_ports PS2_DATA]
#    set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]
#    set_property PULLUP true [get_ports PS2_DATA]


## Quad SPI Flash
## Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
## STARTUPE2 primitive.
# set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
# set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
# set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
# set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
# set_property PACKAGE_PIN K19 [get_ports QspiCSn]
#    set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]

## Don't Touch
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

## where 3.3 is the voltage provided to configuration bank 0
set_property CONFIG_VOLTAGE 3.3 [current_design]
## where value1 is either VCCO(for Vdd=3.3) or GND(for Vdd=1.8)
set_property CFGBVS VCCO [current_design]

#set_property PACKAGE_PIN V16 [get_ports speed]
#set_property IOSTANDARD LVCMOS33 [get_ports speed]
#set_property PACKAGE_PIN V16 [get_ports dir]
#set_property IOSTANDARD LVCMOS33 [get_ports dir]
#set_property PACKAGE_PIN V17 [get_ports en]
#set_property IOSTANDARD LVCMOS33 [get_ports en]
#set_property PACKAGE_PIN W16 [get_ports rst]
#set_property IOSTANDARD LVCMOS33 [get_ports rst]
