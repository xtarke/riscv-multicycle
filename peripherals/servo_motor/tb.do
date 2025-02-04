# ============================================================================
# Name        : reg_tb.do
# Author      : Thaine Martini
# Version     : 0.1
# Description : Parametros para a simulação para um código de um contador
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom contador.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -radix binary  /clk_tb
add wave -radix binary  /rst_tb
add wave -radix dec /cont_tb
#add wave -radix dec /angulo_tb



#Simula até um 500ns
run 40000000 ns

wave zoomfull
write wave wave.ps
