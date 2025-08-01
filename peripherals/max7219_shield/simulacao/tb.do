#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom counter.vhd max7219cn.vhd testbench_max7219cn.vhd

#Simula (work é o diretório, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench_max7219cn

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -label clk -radix binary /clk
add wave -label rst -radix binary /rst
add wave -label data -radix hex /data
add wave -label modo -radix hex /modo
add wave -label din -radix hex /din
add wave -label clk_out -radix hex /clk_out
add wave -label cs -radix hex /cs
add wave -label program -radix hex /program
#add wave -label escrita_unica -radix binary /max7219cn_inst/saidas/escrita_unica
add wave -label estado -radix hex /max7219cn_inst/estado_display
add wave -label contador_max -radix hex /max7219cn_inst/count
add wave -label contador -radix hex /max7219cn_inst/counter_8bits/count
add wave -label termino -radix binary /max7219cn_inst/termino

#Como mostrar sinais internos do processo
#add wave -radix dec /dut/p0/count

#Simula até um 500ns
run 500ns

wave zoomfull

write wave wave.ps