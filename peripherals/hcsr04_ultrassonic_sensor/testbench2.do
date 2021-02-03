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
vsim -t ns work.testbench

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
add wave -label measure_ms -radix unsigned /HCSR04_inst/measure_ms
add wave -label echo_counter -radix unsigned /HCSR04_inst/echo_counter
add wave -label echo_wait -radix unsigned /HCSR04_inst/echo_wait

run 1000000 ns

wave zoomfull
write wave wave.ps
