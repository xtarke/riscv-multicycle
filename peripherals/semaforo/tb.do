#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom semaforo.vhd semaforo_testbench.vhd

#Simula (work é o diretorio, semaforo_testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.semaforo_testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
add wave -radix binary  /clk
add wave -radix binary  /rst
add wave -radix binary  /start
add wave -radix binary  /pedestre
add wave -radix binary  /carro
add wave -radix binary  /r1
add wave -radix binary  /y1
add wave -radix binary  /g1
add wave -radix uns  /ped_count
add wave -radix uns  /car_count
add wave -radix uns  /time_display
#add wave -radix uns  /visual_display
add wave /dut/pr_state



#Simula até um 500ns
run 2500

wave zoomfull
write wave wave.ps