# No código de inicialização do display há delays de inicialização em milisegundos, 
# para conseguir aferir o funcionamento na simulação, é recomendado que altere o
# valor da constante ADJ presente no arquivo "writer.vhd" para o valor 1.

vlib work

vcom ../mux32.vhd ../boot_mem.vhd ../data_mem.vhd ../decoder/dec_clean.vhd ../decoder/dec_fsm.vhd ../decoder/dec_rect.vhd ../decoder/dec_reset.vhd ../decoder.vhd ../writer.vhd ../controller.vhd ../tft.vhd tb_tft.vhd

vsim -t ns work.testbench_tft_controller

view wave

#testbench tft
add wave -height 18 -divider "TFT"
add wave -height 15 -divider "INPUT"
add wave -radix hex  -label input_a /input_a
add wave -radix hex  -label input_b /input_b
add wave -radix hex  -label input_c /input_c

add wave -height 15 -divider "GENERATOR"
add wave -radix hex  	-label state /tft_inst/decoder_inst/controller_inst/state
add wave -radix bin  	-label start /tft_inst/decoder_inst/controller_inst/start

add wave -height 15 -divider "BOOT_MEM"
add wave -radix binary  -label clk /clk
add wave -radix binary  -label reset /tft_inst/reset
add wave -radix binary  -label rd_en_1 /tft_inst/rd_en_boot_mem
add wave -radix binary  -label empty_1 /tft_inst/empty_boot_mem
add wave -radix dec 	-label tail_1 /tft_inst/boot_mem_inst/tail

add wave -height 15 -divider "DATA_MEM"
add wave -radix binary  -label wr_en /tft_inst/wr_en_data_mem
add wave -radix hex		-label input /tft_inst/wr_data_data_mem
add wave -radix binary  -label full /tft_inst/full_data_mem

add wave -height 15 -divider "WRITE_OUT"
add wave -radix bin  	-label ready /tft_inst/write_cdmdata_inst/ready
add wave -radix hex  	-label start /tft_inst/start
add wave -radix hex  	-label state_write /tft_inst/write_cdmdata_inst/state
add wave -radix hex  	-label output /pin_output

add wave -height 15 -divider "FSM_CTR"
add wave -radix hex  	-label state_fsm /tft_inst/fsm_inst/state
add wave -radix hex  	-label read_en1 /tft_inst/fsm_inst/read_en1
add wave -radix hex  	-label read_en2 /tft_inst/fsm_inst/read_en2

add wave -height 15 -divider "MUX"
add wave -radix hex  	-label rd_data_1 /tft_inst/rd_data_boot_mem
add wave -radix hex  	-label mux_out /tft_inst/mux_out
add wave -radix bin  	-label mux_sel /tft_inst/mux_sel

add wave -height 15 -divider "DATA_MEM"
add wave -radix hex  -label data /tft_inst/data_mem_inst/ram_block

run 100us

wave zoomfull
write wave wave.ps