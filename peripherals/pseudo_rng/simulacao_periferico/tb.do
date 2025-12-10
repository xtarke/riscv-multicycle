# ============================================================================
# Name        : tb.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim para divisor de clock
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom rng.vhd tb_rng.vhd


#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

# Sem labels
add wave -radix binary  /clk_tb
add wave -radix binary  /rst_tb
# add wave -radix hex     /write_data_tb
# add wave -radix binary  /write_enable_tb
add wave -radix binary  /chip_select_tb
add wave -radix binary  /addr_tb
add wave -radix hex     /read_data_tb


#Como mostrar sinais internos do processo
add wave -radix hex    /dut_rng/lfsr
# add wave -radix binary /dut_rng/enable
add wave -radix binary /dut_rng/feedback


#Simula até um 500ns
run 1000ns

wave zoomfull
write wave wave.ps

