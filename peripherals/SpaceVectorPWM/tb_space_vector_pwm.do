# Cria a biblioteca de trabalho
vlib work

# Compila
vcom space_vector_pwm.vhd
vcom tb_space_vector_pwm.vhd

# Inicia a simulação
vsim -voptargs="+acc" -t ns work.tb_space_vector_pwm

# Abre a janela de ondas
view wave

# Adiciona Clock e Reset com novos nomes
add wave -radix binary -color "Orange" -label "Clock_Sistema" /clk_tb
add wave -radix binary -label "Reset_Global" /reset_tb

# Sinais de Controle
add wave -divider "Entradas de Controle"
add wave -radix unsigned -label "Tensao_Barramento_DC" /v_bar_tb
add wave -radix decimal -label "Tensao_Comando_Ref" /u_cmd_tb

# Sinais da Ponte H
add wave -divider "Saidas para Ponte H"
add wave -radix binary -color "Green" -label "Gate_S1" /g_s1_tb
add wave -radix binary -color "Green" -label "Gate_S2" /g_s2_tb
add wave -radix binary -color "Green" -label "Gate_S3" /g_s3_tb
add wave -radix binary -color "Green" -label "Gate_S4" /g_s4_tb

# Debug Interno
add wave -divider "Debug FSM e Timers"
add wave -label "Estado_Atual" /DUT/current_state
add wave -radix unsigned -label "T_Ativo_Metade" /DUT/t_v_at_metade_reg
add wave -radix unsigned -label "T_V0_Nulo" /DUT/t_v0_reg
add wave -radix unsigned -label "T_V3_Nulo" /DUT/t_v3_reg

# Roda e ajusta o zoom
run 1000 us
wave zoomfull