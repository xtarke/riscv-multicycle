vlib work

vcom flash_bus.vhd 
vcom testbench_flash.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

view wave

# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label clk /clk
add wave -label rst /rst
add wave -radix hex -label daddress /daddress

add wave -radix dec -label ddata_w /ddata_w
add wave -radix dec -label ddata_r /ddata_r
add wave /d_we
add wave /d_rd
add wave -label FSM /dut/state

run 200 us

wave zoomfull
write wave wave.ps