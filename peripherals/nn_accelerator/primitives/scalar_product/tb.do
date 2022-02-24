#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom scalar_product.vhd testbench.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix dec  /a_0
add wave -radix dec  /b_0
add wave -radix dec  /product_0

add wave -radix dec  /a_1
add wave -radix dec  /b_1
add wave -radix dec  /product_1

#Simula até um 500ns
run 500ns

wave zoomfull
write wave wave.ps
