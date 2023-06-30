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
vsim -t ns work.tb_uart

#Mosta forma de onda
view wave

#Adiciona ondas espec ficas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -height 15 -divider "Clocks and Chip Sel."
#add wave -radix binary -label clk_in_1M /clk_in_1M
add wave -radix binary -label clk_baud /clk_baud
add wave -radix binary -label csel /csel

add wave -height 15 -divider "TX"
add wave -radix hex -label data_in /data_in
add wave -radix binary -label to_tx /dut/to_tx
add wave -radix binary -label tx /tx
add wave -radix dec -label cnt_tx /dut/cnt_tx
add wave -radix binary -label tx_cmp /tx_cmp
add wave -radix binary -label state_tx /dut/state_tx

add wave -height 15 -divider "RX"
#add wave -radix binary -label clk_in_1M /clk_in_1M
add wave -radix binary -label clk_baud /clk_baud
add wave -radix binary -label state_rx /dut/state_rx
add wave -radix binary -label to_rx /to_rx
add wave -radix binary -label rx /rx
add wave -radix binary -label from_rx /dut/from_rx
add wave -radix dec -label cnt_rx /dut/cnt_rx
add wave -radix binary -label rx_cmp /rx_cmp
add wave -radix hex -label data_out /data_out

#Simula at  60ns
run 10000 us

wave zoomfull
write wave wave.ps
