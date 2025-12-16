# ============================================================================
# Arquivo: tb.do
# Author: Sarah Bararua
# Descrição: Script de automação para ModelSim (Buzzer Dual Song)
# ============================================================================

# Cria biblioteca
if {[file exists work] == 0} { vlib work }

# Certifique-se que o nome do arquivo do design é 'buzzer.vhd'
vcom  buzzer1.vhd testbench.vhd


# Carrega simulação
vsim -voptargs="+acc" -t ns work.buzzer_tb

# Configura ondas
view wave
delete wave *

add wave -noupdate -divider "Controles"
add wave /buzzer_tb/clk_tb
add wave -color "blue"   /buzzer_tb/sw_imperial_tb
add wave -color "green" /buzzer_tb/sw_jingle_tb
add wave -color "yellow" /buzzer_tb/wave_out_tb


# Roda 40ms (Suficiente para ver várias notas agora!)
run 85 ms

wave zoomfull
