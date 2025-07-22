vlib work
vcom seven_segs.vhd
vcom fsm_animation_segs.vhd
vcom animation_segs.vhd
vcom tb_animation_segs.vhd

vsim -voptargs="+acc" work.tb_animation_segs
view wave

add wave -divider "Controle"
add wave -label clk /clk
add wave -label rst /rst
add wave -label direction /direction

add wave -divider "Dados"
add wave -label segs -radix hex /segs

add wave -divider "Sinais Internos"
add wave -label state /uut/fsm_inst/state


run 35 ms
wave zoomfull
