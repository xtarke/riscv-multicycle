#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom i2s.vhd sintese/ram.vhd men_cycle.vhd i2s_testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.test_bench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
add wave -label clk     -radix binary   /clk_tb
add wave -label sck     -radix binary   /sck_tb
add wave -label rst     -radix binary   /rst_tb
add wave -label enable  -radix binary   /enable_tb
add wave -label ws      -radix binary   /ws_tb
add wave -label sd      -radix binary   /sd_tb
add wave -label left    -radix binary   /left_channel_tb
add wave -label right   -radix binary   /right_channel_tb
add wave -label q                       /q_tb

add wave -label left_data  -radix binary /I2S_inst/left_data
add wave -label right_data -radix binary /I2S_inst/right_data
add wave -label state   -radix binary   /I2S_inst/state
add wave -label count   -radix uns      /I2S_inst/bit_count

add wave -label address -radix uns  /men_cycle_inst/address

#Simula até um 10000ns
run 10000ns

wave zoomfull
write wave wave.ps
