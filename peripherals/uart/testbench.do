#******************************************************************************
#                                                                             *
#                  Copyright (C) 2019 IFSC                                    *
#                                                                             *
#                                                                             *
# All information provided herein is provided on an "as is" basis,            *
# without warranty of any kind.                                               *
#                                                                             *
# File Name: testbench.do          	      				        *
#                                                                             *
# Function: riscv muticycle simulation script		  	               *
#                                                                             *
# REVISION HISTORY:                                                           *
#  Revision 0.1.0    08/01/2018 - Initial Revision                            *
#******************************************************************************

vlib work
vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../alu/alu_types.vhd
vcom ../../alu/alu.vhd
vcom ../../alu/m/M_types.vhd
vcom ../../alu/m/M.vhd
vcom ../../decoder/decoder_types.vhd
vcom ../../decoder/iregister.vhd
vcom ../../decoder/decoder.vhd
vcom ../../registers/register_file.vhd
vcom ../gpio/gpio.vhd
vcom ../disp7seg/display_dec.vhd
vcom ../../core/csr.vhd
vcom ../../core/core.vhd
vcom ../../core/txt_util.vhdl
vcom ../../core/trace_debug.vhd

vcom uart.vhd
vcom coretestbench.vhd

vsim -t ns work.coretestbench

view wave
add wave -radix binary 	/clk
add wave -radix binary 	/rst
add wave -height 15 -divider "Instruction Memory"
add wave -label iAddr -radix hex /address
add wave -label iWord -radix hex idata
add wave -label decoded -radix ASCII /debugString
# add wave /debugString
# add wave -radix hex /imem/RAM
# add wave -radix hex /q



add wave -height 15 -divider "Iregister debug"
add wave -label opcode  /myRiscv/opcodes
add wave -label rd /myRiscv/rd
add wave -label rs1 /myRiscv/rs1
add wave -label rs2 /myRiscv/rs2
add wave -label imm_i /myRiscv/imm_i
add wave -label imm_s /myRiscv/imm_s
add wave -label imm_b /myRiscv/imm_b
add wave -label imm_u /myRiscv/imm_u
add wave -label imm_j /myRiscv/imm_j


add wave -height 15 -divider "Register file debug"
 add wave -label registers -radix hex /myRiscv/registers/ram
 add wave -label w_ena 	/myRiscv/rf_w_ena
 add wave -label w_data 	/myRiscv/rw_data
 add wave -label r1_data -radix hex /myRiscv/rs1_data
 add wave -label r2_data -radix hex /myRiscv/rs2_data

# decoder debug
add wave -label states /myRiscv/decoder0/state

# add wave -height 15 -divider "Alu debug"
# add wave -label aluData /myRiscv/alu_data
#add wave -label aluOut 	/myRiscv/alu_out

add wave -height 15 -divider "Data memory debug"
add wave -label daddr -radix hex /myRiscv/memAddrTypeSBlock/addr
add wave -label fsm_data -radix hex /dmem/fsm_data
add wave -label ram_data -radix hex /dmem/ram_data
add wave -label mState /dmem/state
add wave -label fsm_we /dmem/fsm_we

add wave -height 15 -divider "Data bus"
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix hex 	/ddata_r
add wave -label ddata_w -radix hex 	/ddata_w
add wave -label dmask -radix bin /dmask
add wave -label dcsel 	/dcsel
add wave -label d_we 	/d_we
add wave -label d_rd 	/d_rd

add wave -height 15 -divider "Input/Output SIM"
add wave -label LEDR -radix hex /LEDR
add wave -label ARDUINO_IO -radix hex /ARDUINO_IO

add wave -label dcsel 	/dcsel
add wave -label d_we 	/d_we
add wave -label d_rd 	/d_rd

add wave -radix binary -label clk_in_1M /clk
add wave -radix binary -label clk_baudState /clk_baud
add wave -radix binary -label csel /start

add wave -height 15 -divider "CSR Signals"
add wave -radix binary -label pending /myRiscv/ins_csr/pending_interrupts
add wave -radix hex -label mepc_out /myRiscv/ins_csr/mepc_out
add wave -radix hex -label mip_in /myRiscv/ins_csr/mip_in
add wave -radix hex -label mcause_in /myRiscv/ins_csr/mcause_in
add wave -radix hex -label csr_value 	/myRiscv/csr_value
add wave -radix binary -label load_mepc 	/myRiscv/load_mepc


add wave -height 15 -divider "TX"
add wave -radix hex -label data_in /uart_plus/data_in
add wave -radix hex -label to_tx /uart_plus/to_tx
add wave -radix hex -label tx /uart_plus/tx
add wave -label state_tx /uart_plus/state_tx
add wave -label csel_uart /csel_uart

add wave -height 15 -divider "RX"
add wave -label state_rx /uart_plus/state_rx
add wave -radix hex -label rx /rx
add wave -radix binary -label rx_flag /rx_cmp
add wave -radix hex -label data_out /data_out
add wave -radix binary -label uart_interrup /uart_interrup


add wave -radix hex -label config_all /config_all


run 20000 ns
