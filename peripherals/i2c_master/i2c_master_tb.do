# ============================================================================
# Name        : i2c_master_tb.do
# Author      : Jhonatan de Freitas Lang
# Version     : 0.1
# Copyright   : Jhonatan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom i2c_master.vhd i2c_master_testbench.vhd

#Simula
vsim -t ns work.i2c_master_tb

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -radix binary /clk
add wave -radix binary /clk_scl
add wave -radix binary /sda
add wave -radix binary /scl
add wave -radix binary /rst
add wave -radix binary /ena
add wave -radix binary /rw
add wave -radix hex /addr
add wave -radix hex /data_w


#Simula até 60ns
run 500ns

wave zoomfull
write wave wave.ps