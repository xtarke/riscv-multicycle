#Cria biblioteca do projeto
vlib work

#compila projeto: todos os arquivo. Ordem é importante
vcom ../de10_lite/sqrt.vhd raiz.vhd testbench.vhd

#Simula (work é o diretório, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns -L altera_mf work.testbench

#Mostra forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

# Adiciona ondas principais da testbench
add wave -radix binary /testbench/clk_tb
add wave -radix binary /testbench/rst_tb

add wave -radix unsigned /testbench/switches_tb
add wave -radix hex      /testbench/daddress_tb

# Sinais internos do periférico raiz
add wave -radix unsigned /testbench/raiz_inst/sqrt_q
add wave -radix unsigned /testbench/raiz_inst/sqrt_remainder


#Simula até um 500ns
run 1500 ns

wave zoomfull
write wave wave.ps