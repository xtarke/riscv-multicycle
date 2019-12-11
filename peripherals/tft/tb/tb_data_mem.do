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
vcom data_mem.vhd tb/tb_data_mem.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_data_mem

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
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

#Simula até um 60ns
run 60ns

wave zoomfull
write wave wave.ps
