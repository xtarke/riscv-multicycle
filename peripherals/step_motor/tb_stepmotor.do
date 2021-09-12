vlib workstart

#compila projeto: todos os aquivo. Ordem é importante
vcom stepmotor.vhd tb_stepmotor.vhd 

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.tb_stepmotor

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix binary   -label clk /clk
add wave -radix binary   -label reverse /reverse
add wave -radix binary   -label reset /rst
add wave -radix binary   -label stop /stop
add wave -radix binary   -label enable /ena
add wave -radix binary   -label half_full /half_full
add wave -radix unsigned -label speed /speed 
add wave -radix binary   -label output /outputs
add wave                 -label state /motor0/state

#Simula até 500ms
run 500ms

wave zoomfull