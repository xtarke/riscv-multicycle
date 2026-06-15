
# 1. Fecha qualquer simulação ativa para liberar os arquivos
quit -sim

# 2. Deleta fisicamente a biblioteca 'work' antiga (Isso remove o cache do 'testbench')
if [file exists work] {
    vdel -all -lib work
}

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom can_pkg.vhd 
vcom can_engine.vhd 
vcom register_map.vhd
vcom can_fsm.vhd 
vcom can_top.vhd 
vcom testbench.vhd

#Simula (work é o diretório, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
#-radix: binary, hex, dec
#-label: nome da forma de onda

# Sinais do Testbench (Entradas e Saídas Principais)
# ====================================================================
add wave -label clk       -radix binary /testbench/clk
add wave -label reset     -radix binary /testbench/rst
add wave -label reg_addr  -radix hex    /testbench/reg_addr
add wave -label wr_en     -radix binary /testbench/reg_wr_en
add wave -label bit_mod   -radix binary /testbench/reg_bit_mod_en
add wave -label data_in   -radix hex    /testbench/reg_data_in
add wave -label bit_mask  -radix hex    /testbench/reg_bit_mask
add wave -label data_out  -radix hex    /testbench/reg_data_out
add wave -label can_rx    -radix binary /testbench/can_rx
add wave -label can_tx    -radix binary /testbench/can_tx

# Sinais Internos Críticos
add wave -label FSM_State -radix hex    /testbench/dut/w_state_vector
add wave -label bit_valid -radix binary /testbench/dut/w_bit_valid
add wave -label rx_clean  -radix binary /testbench/dut/w_rx_bit_out

#Como mostrar sinais internos do process
# add wave -radix dec /dut/p0/count

#Simula até um 5us
run 5us
wave zoomfull
write wave wave.ps