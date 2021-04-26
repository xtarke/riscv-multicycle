# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
vcom watchdog2.vhd tb_wtd_mode_1.vhd

# Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.tb_wtd_mode_1

# Mosta forma de onda
view wave

# Adiciona ondas específicas
#  -radix: binary, hex, dec
#  -label: nome da forma de onda
add wave -radix binary -label clock /clock
add wave -radix binary -label reset /reset
add wave -radix binary -label mode /wtd_mode
add wave -radix unsigned -label prescaler /prescaler
add wave -radix unsigned -label top_counter /top_counter
add wave -radix unsigned -label counter /dut/counter
add wave -radix binary -label internal_clock /dut/internal_clock

add wave -radix unsigned -label wtd_reset /wtd_reset
add wave -radix binary -label wtd_hold /wtd_hold
add wave -radix binary -label wtd_out /wtd_out
add wave -radix binary -label wtd_interrupt /wtd_interrupt

# Mostra sinais internos do processo

# Simula
run 1000ns

wave zoomfull
write wave tb_wtd_mode_1.ps
