#Cria biblioteca do projeto
vlib work

#Compila
vcom lcd_hd44780.vhd testbench.vhd

#Simula 
vsim -t ns work.lcd_hd44780_tb

#Mostra forma de onda
view wave

#Adiciona ondas espec�ficas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -height 10 -divider "Core inputs"
add wave -radix binary  /clk
add wave -radix binary  /rst
add wave -height 10 -divider "Peripheral outputs"
add wave -radix binary  /lcd_rs
add wave -radix binary  /lcd_e
add wave -radix binary  /lcd_init
add wave -position insertpoint sim:/lcd_hd44780_tb/dut/command
add wave -position insertpoint sim:/lcd_hd44780_tb/lcd_data
add wave -position insertpoint sim:/lcd_hd44780_tb/lcd_e
add wave -position insertpoint sim:/lcd_hd44780_tb/dut/power_state
add wave -position insertpoint sim:/lcd_hd44780_tb/dut/lcd_cmd_init_state

#Simula at� um 500ns
run 200ms

wave zoomfull
#write wave wave.ps
