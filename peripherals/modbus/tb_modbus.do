##
## Modbus RTU Testbench for Questa Sim
##

# Cria biblioteca de trabalho
vlib work

# Compila os arquivos VHDL
vcom -93 modbus_rtu.vhd
vcom -93 tb_modbus.vhd

# Inicia a simulação
vsim -t ns work.tb_modbus

# Configura forma de onda
view wave

# Adiciona sinais ao Wave
add wave -divider "Clock e Reset"
add wave -format logic /tb_modbus/clk
add wave -format logic /tb_modbus/rst

add wave -divider "Barramento de Dados"
add wave -format literal -radix hexadecimal /tb_modbus/daddress
add wave -format literal -radix hexadecimal /tb_modbus/ddata_w
add wave -format literal -radix hexadecimal /tb_modbus/ddata_r
add wave -format logic /tb_modbus/d_we
add wave -format logic /tb_modbus/d_rd
add wave -format literal /tb_modbus/dcsel
add wave -format literal /tb_modbus/dmask

add wave -divider "Sinais de Debug"
add wave -format literal -radix unsigned /tb_modbus/debug_state
add wave -format literal -radix hexadecimal /tb_modbus/debug_crc

add wave -divider "Sinais Internos Modbus"
add wave -format literal -radix hexadecimal /tb_modbus/dut/rx_address
add wave -format literal -radix hexadecimal /tb_modbus/dut/rx_function
add wave -format literal -radix hexadecimal /tb_modbus/dut/rx_data_high
add wave -format literal -radix hexadecimal /tb_modbus/dut/rx_data_low
add wave -format literal -radix hexadecimal /tb_modbus/dut/calculated_crc
add wave -format logic /tb_modbus/dut/crc_valid

add wave -divider "Registradores"
add wave -format literal -radix hexadecimal /tb_modbus/dut/control_reg
add wave -format literal -radix hexadecimal /tb_modbus/dut/status_reg
add wave -format literal -radix hexadecimal /tb_modbus/dut/holding_registers

add wave -divider "Estado da FSM"
add wave -format literal /tb_modbus/dut/state

# Configura formato de tempo
configure wave -timelineunits ns

# Executa simulação
run 10 us

# Ajusta zoom para visualizar toda a simulação
wave zoom full
