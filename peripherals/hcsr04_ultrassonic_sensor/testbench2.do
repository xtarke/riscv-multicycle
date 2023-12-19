# ============================================================================
# Name        : testbench.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim
# ============================================================================

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom HCSR04.vhd testbench2.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.hcsr04_testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label clk /clk
add wave -label rst /rst
add wave -label echo /echo
add wave -label Trig /Trig
add wave -label state -radix unsigned /HCSR04_inst/state
add wave -label counter -radix unsigned /HCSR04_inst/counter
add wave -label measure_ms -radix unsigned /HCSR04_inst/measure_ms
add wave -label echo_counter -radix unsigned /HCSR04_inst/echo_counter


run 10 ms

wave zoomfull
write wave wave.ps
