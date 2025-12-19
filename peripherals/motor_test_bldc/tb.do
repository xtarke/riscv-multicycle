# ============================================================================
# Name        : tb.do
# Author      : João Pedro de Araújo Duarte
# Version     : 18/12/2025
# Description : Estrutura para compilação ModelSim para o motor_test_bldc, utilizou-se 
# como base os arquivos disponibilizados pelo professor.
# ============================================================================


# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os arquivos. Ordem é SEMPRE IMPORTANTE!
vcom pwm_bldc_tester.vhd motor_test_bldc.vhd testbench.vhd

# Simula (work é o diretório, tb_register é o nome da entity)
vsim -voptargs="+acc" -t ns work.tb_pwm_bldc_tester

# Mostra forma de onda
view wave

# Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
# Com labels
add wave -label CLK    /tb_pwm_bldc_tester/clk_tb
add wave -label STOP   /tb_pwm_bldc_tester/stop_tb
add wave -label MODE   /tb_pwm_bldc_tester/mode_tb
add wave -label ENTER  /tb_pwm_bldc_tester/enter_tb
add wave -label WEIGHT -radix unsigned /tb_pwm_bldc_tester/weight_tb
add wave -label FAULT  /tb_pwm_bldc_tester/fault_tb
add wave -label PWM    /tb_pwm_bldc_tester/pwm_out_tb


# Simula até 300ns
run 3 sec
wave zoom full

# Salva a forma de onda em um arquivo
#write wave wave.ps
