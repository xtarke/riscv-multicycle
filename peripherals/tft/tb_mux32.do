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
vcom mux32.vhd tb_mux32.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix hex  	/a
add wave -radix hex  	/b
add wave -radix binary  /sel
add wave -radix hex  	/S

#Como mostrar sinais internos do processo
#add wave -radix dec /dut/b

#Simula até um 60ns
run 60ns

wave zoomfull
write wave wave.ps
