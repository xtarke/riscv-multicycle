# ============================================================================
# ARQUIVO: tb.do
# DESCRIÇÃO: 
# ============================================================================

# 1. Limpeza
if {[file exists work]} { vdel -lib work -all }
vlib work

vcom -2008 oneshot125.vhd
vcom -2008 testbench.vhd

vsim -voptargs="+acc" -t ns work.tb_oneshot125

view wave
wave zoom full

add wave -noupdate  -color "yellow" /clk_tb
add wave -radix binary  /rst_tb
add wave -noupdate  -radix unsigned /comando_tb

add wave -noupdate -radix unsigned -label "PWM_SAIDA" /pwm_saida_tb

add wave -noupdate  -radix unsigned -label "MILHAR"  /dut/digito_milhar
add wave -noupdate  -radix unsigned -label "CENTENA" /dut/digito_centena
add wave -noupdate  -radix unsigned -label "DEZENA"  /dut/digito_dezena
add wave -noupdate  -radix unsigned -label "UNIDADE" /dut/digito_unidade

add wave -noupdate  -radix binary /hex3_tb
add wave -noupdate  -radix binary /hex2_tb
add wave -noupdate  -radix binary /hex1_tb
add wave -noupdate  -radix binary /hex0_tb

run 10ms
wave zoom range 0ns 10ms