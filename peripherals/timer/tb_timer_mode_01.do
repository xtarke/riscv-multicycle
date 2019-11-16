# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
vcom Timer.vhd tb_timer_mode_01.vhd

# Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_timer_mode_01

# Mosta forma de onda
view wave

# Adiciona ondas específicas
#  -radix: binary, hex, dec
#  -label: nome da forma de onda
add wave -radix binary -label clock /clock
add wave -radix binary -label reset /reset
add wave -radix dec -label mode /timer_mode
add wave -radix dec -label prescaler /prescaler
add wave -radix dec -label compare /compare
add wave -radix binary -label output /output
add wave -radix binary -label inv_output /inv_output

# Mostra sinais internos do processo
add wave -radix dec -label counter /dut/counter
add wave -radix binary -label internal_clock /dut/internal_clock

# Simula
run 300ns

wave zoomfull
write wave wave.ps
