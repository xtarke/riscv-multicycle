
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
#add wave -label can_tx    -radix binary /testbench/can_tx
add wave -label bus_addr  -radix hex    /testbench/bus_addr
add wave -label bus_data  -radix hex    /testbench/bus_wdata
add wave -label wr_en     -radix binary /testbench/reg_wr_en
add wave -label stuff_bit -radix binary /testbench/can_top_inst/can_engine_inst/stuff_nxt_bit
add wave -label state     -radix hex    /testbench/can_top_inst/can_fsm_inst/current_state_out
#add wave -label bit_mod   -radix binary /testbench/reg_bit_mod_en
#add wave -label data_in   -radix hex    /testbench/reg_data_in
#add wave -label bit_mask  -radix hex    /testbench/reg_bit_mask
#add wave -label data_out  -radix hex    /testbench/reg_data_out

add wave -label state_name /testbench/can_top_inst/can_fsm_inst/current_state

add wave -label can_rx    -radix binary /testbench/can_rx
add wave -label can_tx    -radix binary /testbench/can_tx

# Sinais Internos Críticos
#add wave -label FSM_State -radix hex    /testbench/current_state_out
#add wave -label bit_valid -radix binary /testbench/dut/w_bit_valid
#add wave -label rx_clean  -radix binary /testbench/dut/w_rx_bit_out
#add wave -label bit_count -radix unsigned  /testbench/dut/debu

add wave -label txb0ctrl_reg    -radix hex  /can_top_inst/txb0ctrl_out
add wave -label txb0sidh_reg    -radix hex  /can_top_inst/txb0sidh_out
add wave -label txb0sidl_reg    -radix hex  /can_top_inst/txb0sidl_out
add wave -label txb0dlc_reg     -radix hex  /can_top_inst/txb0dlc_out
add wave -label txb0d0          -radix hex  /can_top_inst/r_TXB0Dn(0)
add wave -label txb0d1          -radix hex  /can_top_inst/r_TXB0Dn(1)

#Como mostrar sinais internos do process
# add wave -radix dec /dut/p0/count

#Simula até um 5us
run 10us
wave zoomfull
write wave wave.ps