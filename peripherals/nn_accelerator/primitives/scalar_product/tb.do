#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom scalar_product_2.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix dec  /x0
add wave -radix dec  /x1
add wave -radix dec  /w0
add wave -radix dec  /w1
add wave -radix dec  /output


#Simula
run 10ns

wave zoomfull
write wave wave.ps
