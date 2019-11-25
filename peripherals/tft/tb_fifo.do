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
vcom fifo.vhd tb_fifo.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_fifo

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix binary  /clk
add wave -radix binary  /rst
add wave -radix binary  /wr_en
add wave -radix binary  /rd_en
add wave -radix binary  /rd_valid
add wave -radix binary  /empty
#add wave -radix binary  /empty_next
add wave -radix binary  /full
#add wave -radix binary  /full_next
add wave -radix dec  	/fill_count
add wave -radix hex  	/wr_data
add wave -radix hex  	/rd_data




#Como mostrar sinais internos do processo
add wave -radix dec /dut/tail
add wave -radix dec /dut/head

#Simula até um 60ns
run 60ns

wave zoomfull
write wave wave.ps
