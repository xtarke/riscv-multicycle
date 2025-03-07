# ============================================================================
# Name        : tb_uart.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletr nica, Florian polis, IFSC
# Description : Exemplo de script de compila  o ModelSim
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem   importante
vcom uart.vhd coretestbench.vhd

#Simula
vsim -t ns work.uart

#Mosta forma de onda
view wave

#Adiciona ondas espec ficas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -height 15 -divider "Clocks and Chip Sel."
#add wave -radix binary -label clk_in_1M /clk_in_1M
add wave -radix binary -label clk_baud /clk_baud
add wave -radix binary -label dcsel /dcsel

add wave -height 15 -divider "TX"
add wave -radix hex     /tx_out
add wave -radix binary  /state_tx
add wave -radix dec     /cnt_tx
add wave -radix binary  /to_tx


add wave -height 15 -divider "RX"
#add wave -radix binary /clk_in_1M
add wave -radix binary  /clk_baud
add wave -radix binary  /state_rx
#add wave -radix binary -label to_rx /to_rx
#add wave -radix binary -label rx /rx
#add wave -radix binary -label from_rx /dut/from_rx
add wave -radix dec     /cnt_rx
#add wave -radix binary -label rx_cmp /rx_cmp
add wave -radix hex     /rx_out
add wave -radix hex     /byte_received



#Simula at  60ns
run 20000 us

wave zoomfull
write wave wave.ps
