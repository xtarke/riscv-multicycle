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
vcom sram.vhd tb_sram.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.tb_sram

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix dec  /clk
add wave -radix binary  /write
add wave -radix binary  /address
add wave -radix binary  /SRAM_OE_N
add wave -radix binary  /SRAM_WE_N
add wave -radix binary  /SRAM_CE_N
add wave -radix binary  /SRAM_ADDR
add wave -radix binary  /SRAM_DQ
add wave -radix binary  /SRAM_UB_N
add wave -radix binary  /SRAM_LB_N
add wave -radix binary  /data_in
add wave -radix binary  /data_out
#Como mostrar sinais internos do processo


#Simula até um 500ns
run 500ns

wave zoomfull
write wave wave.ps