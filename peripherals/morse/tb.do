#------------------------------------------------------
#-- testbench do Somador de n-bits
#-- atualmente configurado para 16bits
#-- Matheus Sandim Gon�alves
#-- Departamento de Eletr�nica, Florian�polis, IFSC
#-------------------------------------------------------

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom MorseCode_Package.vhd MorseCodeBuzzer.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
# Sem labels
add wave -radix uns  /clk_tb
add wave -radix uns  /rst_tb
add wave -radix uns  /entrada_tb
add wave -radix uns  /buzzer_tb
add wave -radix uns  /ledt_tb
add wave -radix uns  /led3t_tb
add wave -radix uns  /ledf_tb
add wave -label estado -radix binary /final/STATE


#SINAIS INTERMEDIARIOS CASO NECESSITE
#add wave -label cod -radix binary /final/morse_code
#add wave -label TC -radix binary /final/count_T_TC
#add wave -label T -radix dec /final/count_T
#add wave -label morse_code -radix uns /final/morse_code
#add wave -label temp -radix dec /final/temp
#add wave -label counter -radix dec /final/counter
#add wave -label tone -radix dec /final/tone

#Simula até um 50000ns
run 50000ns

wave zoomfull
write wave wave.ps
