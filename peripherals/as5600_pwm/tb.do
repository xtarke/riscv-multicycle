# ============================================================================
# Name        : tb.do
# Description : Script de compilação e simulação para o ModelSim
# ============================================================================

# Cria biblioteca do projeto (se já existir, ele sobrescreve/usa a existente)
vlib work
vmap work work

# Compila os arquivos VHDL do periférico e do testbench
vcom as5600_pwm.vhd testbench.vhd

# Inicia a simulação com otimização ativada para acesso a sinais internos
vsim -voptargs="+acc" -t ns work.tb_as5600_pwm

# Mostra a janela de formas de onda
view wave

# Adiciona os sinais do Testbench
add wave -label clk /clk
add wave -label rst /rst
add wave -label pwm_in /pwm_in
add wave -divider "Barramento da CPU"
add wave -label dcsel /dcsel
add wave -label d_rd /d_rd
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix unsigned /ddata_r

# Adiciona os sinais internos do DUT (Device Under Test)
add wave -divider "Sinais Internos (as5600_pwm)"
add wave -label high_counter -radix unsigned /DUT/high_counter
add wave -label period_counter -radix unsigned /DUT/period_counter
add wave -label t_high_reg -radix unsigned /DUT/t_high_reg
add wave -label t_period_reg -radix unsigned /DUT/t_period_reg

# Roda a simulação por 3 milissegundos (suficiente para ver os dois ciclos de 1ms)
run 3 ms

# Ajusta o zoom para ver toda a simulação
wave zoomfull
