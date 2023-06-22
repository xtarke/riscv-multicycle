# ============================================================================
# Name        : tb.do
# Author      : Ariel
# Version     : 0.1
# Copyright   : Ariel
# Description : Script de compila��o ModelSim para fsm.vhd + testbench.vhd
# ============================================================================

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem � importante
vcom crc.vhd tb_crc.vhd

#Simula (work � o diretorio, testbench � o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas espec�ficas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label daddress -radix hex /daddress 
add wave -label ddata_w  -radix unsigned /ddata_w  
add wave -label d_we     -radix binary /d_we     
add wave -label d_rd     -radix binary /d_rd     
add wave -label dcsel    -radix hex /dcsel    
add wave -label dmask    -radix binary /dmask    
add wave -label clk      -radix binary /clk      
add wave -label rst      -radix binary /rst      
add wave -label ddata_r  -radix hex /ddata_r  

add wave -height 15 -divider "CRC Internals"
add wave -label data_reg -radix hex /crc/data_reg

#Como mostrar sinais internos do processo
#add wave -radix dec /dut_5/p0/count
#add wave -radix dec /dut_10/p0/count


#Simula at� um 50ns
#run 786431ns
run 80 ns

wave zoomfull
write wave wave.ps
