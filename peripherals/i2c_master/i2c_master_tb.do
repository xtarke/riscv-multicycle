# ============================================================================
# Name        : i2c_master_tb.do
# Author      : Jhonatan de Freitas Lang
# Version     : 0.1
# Copyright   : Jhonatan, Departamento de Eletr�nica, Florian�polis, IFSC
# Description : Exemplo de script de compila��o ModelSim
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem � importante
vcom i2c_master.vhd i2c_master_testbench.vhd

#Simula
vsim -t ns -voptargs="+acc" work.i2c_master_testbench

#Mosta forma de onda
view wave

#Adiciona ondas espec�ficas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label "clock" -radix binary /clk
add wave -label "serial clock" -radix binary /clk_scl
add wave -label "serial data" -radix binary /sda
# add wave -label "serial clock" -radix binary /scl # => Optimized out of the circuit
# add wave -label "Reset" -radix binary /rst # => Optimized out of the circuit
# add wave -label "Enable" -radix binary /ena # => Optimized out of the circuit
add wave -label "Read / Write" -radix binary /rw
# add wave -label "ACK" -radix binary /ack_err # => Optimized out of the circuit
add wave -label "Address" -radix binary /addr

add wave -label "Count ACK" -radix hex /dut/cnt_ack
add wave -label "Count Stop" -radix hex /dut/cnt_stop

add wave -label "State" -radix hex /dut/state
add wave -label "Serial Clock FSM" -radix hex /dut/scl_state_machine
# add wave -label "Serial CLock Enable" -radix hex /dut/scl_ena # => Optimized out of the circuit
# add wave -label "Data Tx" -radix hex /dut/data_tx
add wave -label "Data Rd" -radix hex /data_rd
add wave -label "Data Rx" -radix hex /dut/data_rx

#Simula at� 60ns
run 1200ns

wave zoomfull
write wave wave.ps