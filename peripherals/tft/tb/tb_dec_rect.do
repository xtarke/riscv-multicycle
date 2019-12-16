vlib work

vcom ../decoder/dec_rect.vhd ../data_mem.vhd tb_dec_rect.vhd

vsim -t ns work.testbench_dec_rect

view wave

add wave -height 15 -divider "DRAW_RECT"

add wave -radix hex  	-label pos_x 	/pos_x
add wave -radix hex  	-label pos_y 	/pos_y
add wave -radix hex  	-label len_x 	/len_x
add wave -radix hex  	-label len_y 	/len_y
add wave -radix hex  	-label color 	/color

add wave -radix binary  -label clk 		/clk
add wave -radix hex  	-label sel 		/sel
add wave -radix binary  -label full 	/full
add wave -radix binary  -label wr_en 	/wr_en
add wave -radix hex  	-label wr_data 	/wr_data
add wave -radix binary  -label compltd	/completed

add wave -height 15 -divider "INTERNAL DRAW_RECT"
add wave -radix dec 	-label state 	/dec_rect_inst/state

add wave -height 15 -divider "DATA_MEM"
add wave -radix binary  -label rst 			/rst
add wave -radix binary  -label rd_en 		/rd_en
add wave -radix binary  -label empty 		/empty
add wave -radix hex 	-label rd_data 		/rd_data
add wave -radix hex 	-label ram_block 	/data_mem_inst/ram_block

run 100ns

wave zoomfull
write wave wave.ps