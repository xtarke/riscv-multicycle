#******************************************************************************
# Script Questa para tb_sv_pwm_core
# Roda o RISC-V Multicycle com main_sv_pwm.c + periférico sv_pwm
#
# Como rodar (a partir de qualquer diretório no Questa):
#   do <caminho>/tb_sv_pwm_core.do
#
# Ou, com cd prévio no Questa:
#   cd /home/cicero/workspace/personal-projects/riscv-multicycle/peripherals/SpaceVectorPWM
#   do tb_sv_pwm_core.do
#******************************************************************************

# Muda para a raiz do projeto para que o init_file do altsyncram
# (./software/sv_pwm/quartus_main_sv_pwm.hex) seja encontrado corretamente.
cd ../../

vlib work

# -------------------------------------------------------
# Periférico sv_pwm
# -------------------------------------------------------
vcom peripherals/SpaceVectorPWM/sv_pwm.vhd

# -------------------------------------------------------
# Memórias e barramentos
# -------------------------------------------------------
vcom memory/iram_quartus.vhd
vcom memory/dmemory.vhd
vcom memory/instructionbusmux.vhd
vcom memory/databusmux.vhd
vcom memory/iodatabusmux.vhd

# -------------------------------------------------------
# ALU e extensão M (multiply/divide)
# -------------------------------------------------------
vcom alu/alu_types.vhd
vcom alu/alu.vhd
vcom alu/m/division_functions.vhd
vcom alu/m/quick_naive.vhd
vcom alu/m/M_types.vhd
vcom alu/m/M.vhd

# -------------------------------------------------------
# Decoder e banco de registradores
# -------------------------------------------------------
vcom decoder/decoder_types.vhd
vcom decoder/iregister.vhd
vcom decoder/decoder.vhd
vcom registers/register_file.vhd

# -------------------------------------------------------
# Periféricos auxiliares
# -------------------------------------------------------
vcom peripherals/gpio/gpio.vhd
vcom peripherals/gpio/led_displays.vhd
vcom peripherals/timer/Timer.vhd

# -------------------------------------------------------
# Core RISC-V
# -------------------------------------------------------
vcom core/csr.vhd
vcom core/core.vhd
vcom core/txt_util.vhdl
vcom core/trace_debug.vhd

# -------------------------------------------------------
# Testbench
# -------------------------------------------------------
vcom peripherals/SpaceVectorPWM/tb_sv_pwm_core.vhd

# Inicia a simulação
vsim -voptargs="+acc" -t ns work.coretestbench

view wave

# -------------------------------------------------------
# Clock e Reset
# -------------------------------------------------------
add wave -radix binary  -color "Orange" -label "clk"     /clk
add wave -radix binary  -color "Orange" -label "clk_32x" /clk_32x
add wave -radix binary  -label "rst"                     /rst

# -------------------------------------------------------
# CPU
# -------------------------------------------------------
add wave -divider "CPU"
add wave -label "estado_cpu"       /myRiscv/decoder0/state
add wave -radix hex -label "pc"    /myRiscv/pc
add wave -label "instrução"        /debugString

# -------------------------------------------------------
# Barramento de dados
# -------------------------------------------------------
add wave -divider "Barramento de Dados"
add wave -radix hex    -label "daddress" /daddress
add wave -radix hex    -label "ddata_w"  /ddata_w
add wave -radix hex    -label "ddata_r"  /ddata_r
add wave -radix binary -label "d_we"     /d_we
add wave -radix binary -label "d_rd"     /d_rd
add wave -radix binary -label "dcsel"    /dcsel

# -------------------------------------------------------
# GPIO (switches SW0 e SW1)
# -------------------------------------------------------
add wave -divider "GPIO (Entradas SW)"
add wave -radix binary -label "gpio_input"  /gpio_input
add wave -radix hex    -label "gpio_output" /gpio_output

# -------------------------------------------------------
# Registradores do sv_pwm (escritos pelo software)
# -------------------------------------------------------
add wave -divider "Registradores sv_pwm"
add wave -radix unsigned -label "v_bar (V)"  /sv_pwm_inst/reg_v_bar
add wave -radix decimal  -label "u_cmd (V)"  /sv_pwm_inst/reg_u_cmd
add wave -radix unsigned -label "f_sw (Hz)"  /sv_pwm_inst/reg_f_sw
add wave -radix binary   -label "start"      /sv_pwm_inst/reg_start

# -------------------------------------------------------
# Temporização interna SVPWM
# -------------------------------------------------------
add wave -divider "Temporização SVPWM (ciclos de clk_32x)"
add wave -radix unsigned -label "ts_cycles"        /sv_pwm_inst/ts_cycles
add wave -radix unsigned -label "t_v0"             /sv_pwm_inst/t_v0_reg
add wave -radix unsigned -label "t_v_ativo_metade" /sv_pwm_inst/t_v_at_metade_reg
add wave -radix unsigned -label "t_v3"             /sv_pwm_inst/t_v3_reg

# -------------------------------------------------------
# Máquina de estados
# -------------------------------------------------------
add wave -divider "FSM sv_pwm"
add wave -label        "estado"       /sv_pwm_inst/current_state
add wave -radix binary -label "vout+" /sv_pwm_inst/vout_is_positive

# -------------------------------------------------------
# Saídas gate (Ponte H)
# -------------------------------------------------------
add wave -divider "Gates (Ponte H)"
add wave -radix binary -color "Green"  -label "gate_s1" /gate_s1
add wave -radix binary -color "Red"    -label "gate_s2" /gate_s2
add wave -radix binary -color "Cyan"   -label "gate_s3" /gate_s3
add wave -radix binary -color "Yellow" -label "gate_s4" /gate_s4

# -------------------------------------------------------
# Displays 7-seg (exibem u_cmd no loop do main)
# -------------------------------------------------------
add wave -divider "Displays 7-seg (u_cmd)"
add wave -radix hex -label "HEX0" /HEX0
add wave -radix hex -label "HEX1" /HEX1

run 10 ms
wave zoomfull
