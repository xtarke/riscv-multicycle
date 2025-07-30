# ============================================================================
# Name    	: tb.do
# Author  	: Renan Augusto Starke e Greicili dos Santos Ferreira
# Description : Script de compilação ModelSim para bloco cronometro
# Date    	: 14/06/2025
# ============================================================================


#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom divisor_clock.vhd my_package.vhd encoder.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# binary, octal, decimal, signed, unsigned, hexadecimal, ascii or default
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -label clock_1MHz -radix binary   /clk_1MHz
add wave -label clock_10Hz -radix binary   /clk_tb
add wave -label Reset -radix binary     	/aclr_n_tb
add wave -label A -radix binary         	/A_tb
add wave -label B -radix binary         	/B_tb
add wave -label HEX0 -radix binary       /segs_a_tb 
add wave -label HEX1 -radix binary      /segs_b_tb 
add wave -label HEX2 -radix binary     /segs_c_tb
add wave -label HEX3 -radix binary    /segs_d_tb
add wave -label HEX4 -radix binary    /segs_e_tb 


#Como mostrar sinais internos do processo
#add wave -radix dec /dut/p0/count
#add wave -label counter_out -radix uns /encoder_inst/pulse_count
add wave -label Velocidade -radix hex /encoder_inst/velocidade



#Simula até
run 1000ms

wave zoomfull
write wave wave.ps
