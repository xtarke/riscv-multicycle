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
add wave -radix binary -label mode /timer_mode
add wave -radix unsigned -label prescaler /prescaler
add wave -radix unsigned -label compare_0A /compare_0A
add wave -radix unsigned -label compare_0B /compare_0B
add wave -radix unsigned -label compare_1A /compare_1A
add wave -radix unsigned -label compare_1B /compare_1B
add wave -radix unsigned -label compare_2A /compare_2A
add wave -radix unsigned -label compare_2B /compare_2B
add wave -radix unsigned -label top_counter/ top_counter
add wave -radix binary -label output_0A /output_A(0)
add wave -radix binary -label output_0B /output_B(0)
add wave -radix binary -label output_1A /output_A(1)
add wave -radix binary -label output_1B /output_B(1)
add wave -radix binary -label output_2A /output_A(2)
add wave -radix binary -label output_2B /output_B(2)

# Mostra sinais internos do processo
add wave -radix unsigned -label counter /dut/counter
add wave -radix binary -label internal_clock /dut/internal_clock
add wave -radix binary -label counter_direction /dut/internal_counter_direction

# Simula
run 2400ns

wave zoomfull
write wave testbench_timer_mode_01_wave.ps
