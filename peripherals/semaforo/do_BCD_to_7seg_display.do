#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom bcd_to_7seg_pkg.vhd BCD_to_7seg_display.vhd BCD_to_7seg_display_tb.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.BCD_to_7seg_display_tb

#Mosta forma de onda
view wave

#Adiciona ondas específicas
add wave -radix binary  /bcd_input
#add wave -radix binary  /seven_seg_output
add wave -radix binary  /seven_seg_output_1
add wave -radix binary  /seven_seg_output_2
add wave -radix uns  /bcd_input
#add wave -radix uns  /seven_seg_output
add wave -radix uns  /seven_seg_output_1
add wave -radix uns  /seven_seg_output_2
#add wave -radix HEX  /seven_seg_output
add wave -radix HEX  /seven_seg_output_1
add wave -radix HEX  /seven_seg_output_2


#Simula até um 100000ns
#run 99840
run 500

wave zoomfull
write wave wave.ps