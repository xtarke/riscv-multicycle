vlib work

vcom ../data_mem.vhd tb_data_mem.vhd

vsim -t ns work.testbench_data_mem

view wave

add wave -height 15 -divider "DATA_MEM"
add wave -radix binary  -label clk /clk
add wave -radix binary  -label rst /rst
add wave -radix binary  -label wr_en /wr_en
add wave -radix binary  -label rd_en /rd_en
add wave -radix binary  -label empty /empty
add wave -radix binary  -label full /full
add wave -radix hex  	-label wr_data /wr_data
add wave -radix hex  	-label rd_data /rd_data


add wave -height 15 -divider "INTERNAL"
add wave -radix dec -label tail 		/data_mem_inst/tail
add wave -radix dec -label head 		/data_mem_inst/head
add wave -radix hex -label ram_block 	/data_mem_inst/ram_block

run 60ns

wave zoomfull
write wave wave.ps