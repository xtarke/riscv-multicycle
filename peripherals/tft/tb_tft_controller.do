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
vcom mux32.vhd fifo.vhd fsm_ctrl.vhd fsm_cmd_data.vhd tft_controller.vhd tb_tft_controller.vhd 

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_tft_controller

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -height 15 -divider "FIFO"
add wave -radix binary  -label clk /clk
add wave -radix binary  -label reset /reset
#add wave -radix binary  -label wr_en_1 /tft_controller_inst/wr_en_1
add wave -radix binary  -label rd_en_1 /tft_controller_inst/rd_en_1
#add wave -radix binary  -label rd_valid_1 /tft_controller_inst/rd_valid_1
add wave -radix binary  -label empty_1 /tft_controller_inst/empty_1
add wave -radix binary  -label full_1 /tft_controller_inst/full_1
#add wave -radix hex  	 -label wr_data_1 /tft_controller_inst/wr_data_1
add wave -radix dec 	-label tail_1 /tft_controller_inst/ring_buffer_init/tail
add wave -radix dec 	-label head_1 /tft_controller_inst/ring_buffer_init/head

add wave -height 15 -divider "WRITE_OUT"
add wave -radix bin  	-label ready /tft_controller_inst/write_cdmdata_inst/ready
add wave -radix hex  	-label start /tft_controller_inst/start
add wave -radix hex  	-label state_write /tft_controller_inst/write_cdmdata_inst/state
add wave -radix hex  	-label output /output
add wave -radix bin  	-label cs /cs
add wave -radix bin  	-label rs /rs
add wave -radix bin  	-label wr /wr

add wave -height 15 -divider "FSM_CTR"
add wave -radix hex  	-label state_fsm /tft_controller_inst/fsm_inst/state

add wave -height 15 -divider "MUX"
add wave -radix hex  	-label rd_data_1 /tft_controller_inst/rd_data_1
add wave -radix hex  	-label mux_out /tft_controller_inst/mux_out



#Como mostrar sinais internos do processo


#Simula até um 60ns
run 10us

wave zoomfull
write wave wave.ps
