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
vcom boot_mem.vhd tb/tb_boot_mem.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_boot_mem

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -height 15 -divider "BOOT_MEM"
add wave -radix binary  -label clk 		/clk
add wave -radix binary  -label rst 		/rst
add wave -radix binary  -label enable 	/rd_en
add wave -radix binary  -label empty 	/empty
add wave -radix hex  	-label data 	/rd_data

add wave -height 15 -divider "INTERNAL"
add wave -radix dec 	-label tail 		/boot_mem_inst/tail
add wave -radix hex 	-label ram_block 	/boot_mem_inst/ram_block

#Simula até um 200ns
run 200ns

wave zoomfull
write wave wave.ps
