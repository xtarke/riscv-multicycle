# Script ModelSim .do para simulação do CORDIC BUS

# Criar biblioteca de trabalho
vlib work

# Compilar os arquivos VHDL (design + testbench)
vcom cordic_core.vhd cordic_bus.vhd tb_cordic.vhd

# Iniciar simulação do testbench
vsim -voptargs="+acc" -t ns work.cordic_bus_tb

# Abrir janela de ondas
view wave

# Adicionar sinais principais com formatação adequada
add wave -divider "Entradas e Controle"
add wave -radix binary  /cordic_bus_tb/clk
add wave -radix binary  /cordic_bus_tb/rst
add wave -radix binary  /cordic_bus_tb/start_bus
add wave -radix hex     /cordic_bus_tb/daddress
add wave -radix hex     /cordic_bus_tb/ddata_w
add wave -radix binary  /cordic_bus_tb/dcsel
add wave -radix binary  /cordic_bus_tb/dmask

add wave -divider "Saídas"
add wave -radix hex     /cordic_bus_tb/ddata_r
add wave -radix binary  /cordic_bus_tb/valid_bus


# Configurar formato de visualização
configure wave -signalnamewidth 1
configure wave -timelineunits ns

# Executar simulação por 1000ns
run 1000ns

# Ajustar zoom para visualização completa
wave zoomfull

# (Opcional) Salvar ondas em arquivo
# write wave -format ps -output cordic_bus_wave.ps