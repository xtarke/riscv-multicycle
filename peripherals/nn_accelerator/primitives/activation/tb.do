#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom sigmoidal.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
add wave -radix signed  /input
add wave -radix signed  /output

#Simula
run 20ns

wave zoomfull
write wave wave.ps
