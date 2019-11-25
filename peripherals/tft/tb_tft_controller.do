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
vcom mux32.vhd fifo.vhd fsm_ctrl.vhd fsm_cmd_data.vhd tft_controller.vhd 
#tb_tft_controller.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_tft_controller

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -height 15 -divider "FIFO"
add wave -radix binary  /clk
add wave -radix binary  /rst
add wave -radix binary  /wr_en
add wave -radix binary  /rd_en
add wave -radix binary  /rd_valid
add wave -radix binary  /empty
add wave -radix binary  /full
add wave -radix hex  	/wr_data
add wave -radix hex  	/rd_data
add wave -radix dec /ring_buffer_inst/tail
add wave -radix dec /ring_buffer_inst/head

add wave -height 15 -divider "OUT"
add wave -radix hex  	/output
add wave -radix hex  	/ready



#Como mostrar sinais internos do processo


#Simula até um 60ns
run 1us

wave zoomfull
write wave wave.ps
