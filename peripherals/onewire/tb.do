#-------------------------------------------------------------------
#-- File: tb.do
#-- Author      : Eric M. dos Reis
#-- Date        : 12 de nov. de 2021
#-------------------------------------------------------------------

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os arquivos. Ordem é importante
vcom -93 onewire.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -label "clk" -radix binary /clk
add wave -label "Clock" -radix binary /dut/counter_clk
add wave -label "Reset" -radix binary  /rst
add wave -label "Data" -radix binary  /data_bus
add wave -label "State" -radix symbolic /dut/state
add wave -label "recovery_flag" -radix binary /dut/state_transition/device_response_flag
add wave -label "data_buffer" -radix binary /dut/state_machine_control/data_buffer
add wave -label "iterator" -radix binary /dut/iterator

#Simula até 6000us
run 6000us

wave zoomfull
write wave wave.ps