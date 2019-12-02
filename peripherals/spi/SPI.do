#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom SPI.vhd SPI_tb.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.SPI_tb

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -radix hex -label  i_clk       /i_clk
add wave -radix hex -label  i_rst       /i_rst
add wave -radix hex -label  i_tx_start  /i_tx_start
add wave -radix hex -label  i_data      /i_data
add wave -radix hex -label  i_miso      /i_miso
add wave -radix hex -label  o_data      /o_data
add wave -radix hex -label  o_tx_end    /o_tx_end
add wave -radix hex -label  o_sclk      /o_sclk
add wave -radix hex -label  o_ss        /o_ss
add wave -radix hex -label  o_mosi      /o_mosi

add wave -radix hex -label  debug_idle_flag   /debug_idle_flag
add wave -radix hex -label  debug_tx_flag     /debug_tx_flag
add wave -radix hex -label  debug_end_flag    /debug_end_flag


#Como mostrar sinais internos do processo
#add wave -radix dec /soma/p0/count

#Simula até um 500ns
run 280ns

wave zoomfull
write wave wave.ps
