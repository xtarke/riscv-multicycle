# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
vcom Timer.vhd tb_timer_mode_03.vhd

# Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_timer_mode_03

# Mosta forma de onda
view wave

# Adiciona ondas específicas
#  -radix: binary, hex, dec
#  -label: nome da forma de onda
add wave -radix binary -label clock /clock
add wave -radix binary -label reset /reset
add wave -radix binary -label mode /timer_mode
add wave -radix unsigned -label prescaler /prescaler
add wave -radix unsigned -label compare /compare
add wave -radix binary -label output /output
add wave -radix binary -label inv_output /inv_output

# Mostra sinais internos do processo
add wave -radix unsigned -label counter /dut/counter
add wave -radix binary -label internal_clock /dut/internal_clock
add wave -radix binary -label counter_direction /dut/internal_counter_direction

# Simula
run 2400ns

wave zoomfull
write wave testbench_timer_mode_03_wave.ps
