#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom fsm_cmd_data.vhd tb_write_fsm.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -radix binary  /clk
add wave -radix binary  /reset
add wave -radix binary  /start
add wave -radix binary  /ready
add wave -radix hex		/data
add wave -radix hex		/output
add wave -radix binary  /cs
add wave -radix binary  /rs
add wave -radix binary  /wr


#Como mostrar sinais internos do processo
add wave -radix dec /dut/state
add wave -radix hex /dut/data_cp

#Simula até um 50ns
run 1000ns

wave zoomfull
write wave wave.ps
