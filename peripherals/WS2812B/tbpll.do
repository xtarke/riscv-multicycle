# ============================================================================
# Name        : tb_divisor.do
# Author      : Luciano Caminha Junior
# Version     : 0.1
# Copyright   : Departamento de Eletrônica, Florian�polis, IFSC
# Description : Exemplo de script de compilacao ModelSim
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom driver_WS2812Bpll.vhd testebenchpll.vhd

#Simula (work eh o diretorio, testbench eh o nome da entity)
vsim -t ns work.testbenchpll

#Mosta forma de onda
view wave

#Adiciona ondas especificas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix binary  /clk
add wave -radix binary  /clk0
add wave -radix binary  /clk1
add wave -radix binary  /rst
add wave -radix unsigned  /dut/state_transition/rst_counter
add wave -radix binary  /data_in
add wave -radix binary  /data_out
add wave -radix binary  /dut/state_transition/i
#add wave -radix ASCII  /dut/current_state
add wave -radix binary  /dut/current_bit
#add wave -radix unsigned  /dut/read_bit_proc/i
#add wave -radix unsigned  /dut/counter
#add wave -radix binary  /dut/rst_counter
#add wave -radix binary  /dut/high_concluded
#add wave -radix binary  /dut/low_concluded


#Como mostrar sinais internos do processo
#add wave -radix dec /dut/p0/count


#Simula até um 500ns
run 500us

wave zoomfull
write wave wave.ps
