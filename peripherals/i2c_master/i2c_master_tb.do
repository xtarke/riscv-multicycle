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
vsim -t ns work.i2c_master_testbench

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
add wave -radix binary /ack_err
add wave -radix binary /addr

add wave -radix hex /dut/cnt_ack
add wave -radix hex /dut/cnt_stop

add wave -radix hex /dut/state
add wave -radix hex /dut/scl_state_machine
add wave -radix hex /dut/scl_ena
add wave -radix hex /dut/data_tx


#Simula até 60ns
run 1200ns

wave zoomfull
write wave wave.ps