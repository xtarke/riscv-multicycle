vlib work
vcom seven_segs.vhd
vcom fsm_animation_segs.vhd
vcom clock_divider.vhd
vcom animation_segs.vhd
vcom tb_animation_segs.vhd

vsim -voptargs="+acc" work.tb_animation_segs
view wave

add wave -divider "Clock"
add wave -label clk /clk

add wave -divider "Entradas"
add wave -label reset /rst
add wave -label direção /direction
add wave -label velocidade /speed

add wave -divider "Dados"
add wave -label segs -radix hex /segs

add wave -divider "Sinais Internos"
add wave -label state /uut/fsm_inst/state


run 35 ms
wave zoomfull
