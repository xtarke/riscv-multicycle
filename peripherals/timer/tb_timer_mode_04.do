# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
vcom Timer.vhd tb_timer_mode_04.vhd

# Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench_timer_mode_04

# Mosta forma de onda
view wave

# Adiciona ondas específicas
#  -radix: binary, hex, dec
#  -label: nome da forma de onda
add wave -radix binary -label clock /clock

add wave -radix binary -label ifcap /ifcap
add wave -radix binary -label ifc /timer/p2/ifc

add wave -radix binary -label reset /reset
add wave -radix binary -label timer_reset /timer/timer_reset

add wave -radix hex -label adress /daddress
add wave -radix binary -label mode /timer/timer_mode
add wave -radix unsigned -label prescaler /timer/prescaler
add wave -radix unsigned -label time /timer/time
add wave -radix unsigned -label captured_time /timer/captured_time
add wave -radix unsigned -label out /ddata_r


# Mostra sinais internos do processo
add wave -radix unsigned -label counter /timer/counter
add wave -radix binary -label internal_clock /timer/internal_clock

# Simula
run 500ns

wave zoomfull
write wave testbench_timer_mode_04_wave.ps
