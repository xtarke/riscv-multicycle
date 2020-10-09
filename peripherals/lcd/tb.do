#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom lcd.vhd lcd_tb.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.lcd_tb

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -height 15 -divider "Input"
add wave -radix binary  /clk
add wave -radix binary  /reset
add wave -radix ASCII  /char
add wave -height 15 -divider "Output"
add wave -radix binary  /rst
add wave -radix binary /ce
add wave -radix binary /dc
add wave -radix binary /din
add wave -radix binary /serial_clk
add wave -radix binary /light

#Simula até um 500ns
run 5400us

wave zoomfull
write wave wave.ps
