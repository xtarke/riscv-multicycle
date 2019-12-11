# ============================================================================
# Name        : tb_divisor.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim para divisor de clock
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom decoder/dec_rect.vhd data_mem.vhd tb/tb_dec_rect.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_dec_rect

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
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

#Sinais internos do processo
add wave -height 15 -divider "INTERNAL DRAW_RECT"
add wave -radix dec 	-label state 	/dec_rect_inst/state
#add wave -radix dec 	-label state 	/dec_rect_inst/state_transation/count

add wave -height 15 -divider "DATA_MEM"
add wave -radix binary  -label rst 			/rst
add wave -radix binary  -label rd_en 		/rd_en
add wave -radix binary  -label empty 		/empty
add wave -radix hex 	-label rd_data 		/rd_data
add wave -radix hex 	-label ram_block 	/data_mem_inst/ram_block



#Simula até um 200ns
run 100ns

wave zoomfull
write wave wave.ps
