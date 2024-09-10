#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom controlador.vhd testbench_controlador.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench_controlador  

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

# Com labels
add wave -label clk -radix bin /clk_tb
add wave -label reset -radix bin /reset_tb
add wave -label start -radix bin /start_tb
add wave -label dout -radix bin /dout_tb
add wave -label state -radix dec /controlador_RGB/state
add wave -label bit_counter -radix dec /controlador_RGB/bit_counter

run 100000ns
wave zoomfull
