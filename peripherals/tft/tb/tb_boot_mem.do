vlib work

vcom ../boot_mem.vhd tb_boot_mem.vhd

vsim -t ns work.testbench_boot_mem

view wave

add wave -height 15 -divider "BOOT_MEM"
add wave -radix binary  -label clk 		/clk
add wave -radix binary  -label rst 		/rst
add wave -radix binary  -label enable 	/rd_en
add wave -radix binary  -label empty 	/empty
add wave -radix hex  	-label data 	/rd_data

add wave -height 15 -divider "INTERNAL"
add wave -radix dec 	-label tail 		/boot_mem_inst/tail
add wave -radix hex 	-label ram_block 	/boot_mem_inst/ram_block

run 200ns

wave zoomfull
write wave wave.ps