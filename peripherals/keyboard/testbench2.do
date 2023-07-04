# ============================================================================
# Name        : testbench.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim
# ==============================================a==============================

#Cria biblioteca do projeto
vlib work


#compila projeto: todos os aquivo. Ordem é importante
vcom decod7.vhd key.vhd testbench.vhd


#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label clk -radix binary /clk
add wave -label rst -radix binary /rst
add wave -label linhas -radix binary /linhas
add wave -label colunas -radix binary /colunas
add wave -label ddata_r -radix dec  /ddata_r
add wave -label d_rd    /d_rd
add wave -label estado -radix binary /keyboard/state


run 1000000 ns

wave zoomfull
write wave wave.ps
