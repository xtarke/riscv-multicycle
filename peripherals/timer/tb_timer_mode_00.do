# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
vcom Timer.vhd tb_timer_mode_00.vhd

# Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_timer_mode_00

# Mosta forma de onda
view wave

# Adiciona ondas específicas
#  -radix: binary, hex, dec
#  -label: nome da forma de onda
add wave -radix binary  /clock
add wave -radix binary  /reset
add wave -radix dec  /timer_mode
add wave -radix dec  /prescaler
add wave -radix dec  /compare
add wave -radix binary  /output
add wave -radix binary  /inv_output

# Mostra sinais internos do processo
add wave -radix dec /dut/counter
add wave -radix binary /dut/internal_clock

# Simula
run 300ns

wave zoomfull
write wave wave.ps
