# ============================================================================
# Name        : tb.do
# Description : Script de compilação e simulação para o ModelSim
#               Periférico AS5600 PWM Input
# ============================================================================

# Cria biblioteca do projeto
vlib work
vmap work work

# Compila os arquivos VHDL do periférico e do testbench
vcom as5600_pwm.vhd testbench.vhd

# Inicia a simulação
vsim -voptargs="+acc" -t ns work.tb_as5600_pwm

# Mostra a janela de formas de onda
view wave

# --- Sinais Básicos ---
add wave -label clk /clk
add wave -label rst /rst
add wave -label pwm_in /pwm_in

# --- Barramento da CPU ---
add wave -divider "Barramento da CPU"
add wave -label dcsel /dcsel
add wave -label d_rd /d_rd
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix unsigned /ddata_r

# --- Sinais Internos do DUT ---
add wave -divider "Contadores Internos"
add wave -label high_counter -radix unsigned /DUT/high_counter
add wave -label period_counter -radix unsigned /DUT/period_counter

add wave -divider "Registradores de Saida"
add wave -label t_high_reg -radix unsigned /DUT/t_high_reg
add wave -label t_period_reg -radix unsigned /DUT/t_period_reg

# Roda a simulação por 25 ms (cobre os dois ciclos PWM de ~8.7ms + leituras CPU)
run 25 ms

# Ajusta o zoom para ver toda a simulação
wave zoomfull
