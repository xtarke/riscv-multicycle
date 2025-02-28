#******************************************************************************
#                                                                             *
#                  Copyright (C) 2019 IFSC                                    *
#                                                                             *
#                                                                             *
# All information provided herein is provided on an "as is" basis,            *
# without warranty of any kind.                                               *
#                                                                             *
# File Name: testbench.do                                                     *
#                                                                             *
# Function: riscv muticycle simulation script                                 *
#                                                                             *
# REVISION HISTORY:                                                           *
#  Revision 0.1.0    08/01/2018 - Initial Revision                            *
#  Revision 0.2.0    04/06/2021 - Update UART module                          *
#******************************************************************************

vlib work

vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../memory/instructionbusmux.vhd
vcom ../../memory/databusmux.vhd
vcom ../../memory/iodatabusmux.vhd
vcom ../../alu/alu_types.vhd
vcom ../../alu/alu.vhd
vcom ../../alu/m/division_functions.vhd
vcom ../../alu/m/quick_naive.vhd
vcom ../../alu/m/M_types.vhd
vcom ../../alu/m/M.vhd
vcom ../../decoder/decoder_types.vhd
vcom ../../decoder/iregister.vhd
vcom ../../decoder/decoder.vhd
vcom ../../registers/register_file.vhd
vcom ../../peripherals/gpio/gpio.vhd
vcom ../../peripherals/gpio/led_displays.vhd
vcom ../../peripherals/timer/Timer.vhd
vcom ../../core/csr.vhd
vcom ../../core/core.vhd
vcom ../../core/txt_util.vhdl
vcom ../../core/trace_debug.vhd
vcom RS485.vhd
vcom testbench.vhd

vsim -t ns work.RS485_testbench

view wave
# add wave -radix binary -label clk /clk
# add wave -radix binary  -label rst /rst
# add wave -height 15 -divider "Instruction Memory"
# add wave -label iAddr -radix hex /address
# add wave -label iWord -radix hex idata
# add wave -label decoded -radix ASCII /debugString
# add wave /debugString
# add wave -radix hex /imem/RAM
# add wave -radix hex /q

# add wave -height 15 -divider "PC and Ctrl Targers"
# add wave -radix hex -label pc           /myRiscv/pc
# add wave -radix hex -label jal_target   /myRiscv/jal_target
# add wave -radix hex -label jalr_target  /myRiscv/jalr_target
# add wave -label branch_cmp              /myRiscv/branch_cmp
# add wave -radix hex -label jumps    /myRiscv/jumps


# add wave -height 15 -divider "Iregister debug"
# add wave -label opcode  /myRiscv/opcodes
# add wave -label rd /myRiscv/rd
# add wave -label rs1 /myRiscv/rs1
# add wave -label rs2 /myRiscv/rs2
# add wave -label imm_i /myRiscv/imm_i
# add wave -label imm_s /myRiscv/imm_s
# add wave -label imm_b /myRiscv/imm_b
# add wave -label imm_u /myRiscv/imm_u
# add wave -label imm_j /myRiscv/imm_j


# add wave -height 15 -divider "Register file debug"
# add wave -label registers -radix hex /myRiscv/registers/ram
# add wave -label w_ena  /myRiscv/rf_w_ena
# add wave -label w_data -radix hex  /myRiscv/rw_data
# add wave -label r1_data -radix hex /myRiscv/rs1_data
# add wave -label r2_data -radix hex /myRiscv/rs2_data

# # decoder debug
# add wave -label states /myRiscv/decoder0/state
# 
# add wave -height 15 -divider "GPIO"
# add wave -label enable_exti_mask -radix hex /generic_gpio/enable_exti_mask
# add wave -label edge_exti_mask -radix hex /generic_gpio/edge_exti_mask
# add wave -label output_reg -radix hex /generic_gpio/output_reg
# 
# add wave -height 15 -divider "CSR"
# add wave -label interrupts -radix hex /myRiscv/interrupts
# add wave -label pending_interrupts -radix hex /myRiscv/ins_csr/pending_interrupts
# add wave -label mret -radix hex /myRiscv/ins_csr/mret
# add wave -label pending /myRiscv/pending
# add wave -label csr_write /myRiscv/csr_write
# add wave -label csr_addr /myRiscv/imm_i
# add wave -label csr_value -radix hex /myRiscv/csr_value
# add wave -label load_mepc -radix hex /myRiscv/load_mepc
# # add wave -label load_mepc_holder -radix hex /myRiscv/ins_csr/load_mepc_holder
# add wave -label mepc -radix hex /myRiscv/mepc
# add wave -label mretpc -radix hex /myRiscv/mretpc
# add wave -label csr_new -radix hex /myRiscv/rs1_data
# # add wave -label mreg -radix hex /myRiscv/ins_csr/mreg
# 
# 
# add wave -height 15 -divider "Alu debug"
# add wave -radix dec -label aluData /myRiscv/alu_data
# add wave -radix dec -label aluOut   /myRiscv/alu_out

# add wave -height 15 -divider "M Extension debug"
# add wave -label clock_32x /myRiscv/clk_32x
# add wave -label code_operator /myRiscv/M_data.code
# add wave -radix dec -label a_integer    /myRiscv/M_data.a
# add wave -radix dec -label b_integer    /myRiscv/M_data.b
# add wave -radix dec -label M_out      /myRiscv/M_out
# 
# add wave -height 15 -divider "Data memory debug"
# add wave -label daddr -radix hex /myRiscv/memAddrTypeSBlock/addr
# add wave -label fsm_data -radix hex /dmem/fsm_data
# add wave -label ram_data -radix hex /dmem/ram_data
# add wave -label mState /dmem/state
# add wave -label fsm_we /dmem/fsm_we
# add wave -label ddata_r_mem -radix hex /dmem/q
# add wave -label datamemory -radix hex /dmem/ram_block


# add wave -height 15 -divider "Data bus"
# add wave -label daddress -radix hex /daddress
# add wave -label ddata_r -radix hex  /ddata_r
# add wave -label ddata_w -radix hex  /ddata_w
# add wave -label dmask -radix bin /dmask
# add wave -label dcsel   /dcsel
# add wave -label d_we    /d_we
# add wave -label d_rd    /d_rd
# add wave -label d_sig   /d_sig
# 
# add wave -height 15 -divider "Peripheral Data bus"
    add wave -label daddress -radix hex /daddress
# add wave -label ddata_r_periph -radix hex   /ddata_r_periph
# add wave -label ddata_r_gpio -radix hex     /ddata_r_gpio
# 
# add wave -label gpio_interrupts -radix hex /gpio_interrupts
# add wave -label gpio_input -radix hex /gpio_input

add wave -height 21 -divider "UART"
add wave -label clk /generic_RS485_uart/clk
add wave -label clk_baud /generic_RS485_uart/clk_baud
add wave -label transmit_byte -radix hex /transmit_byte
add wave -label transmit_frame /transmit_frame    
# add wave -label config /generic_RS485_uart/config_register
add wave -label uart_register -radix hex /generic_RS485_uart/uart_register
add wave -label ddata_w -radix hex /generic_RS485_uart/ddata_w
add wave -label ddata_r -radix hex /generic_RS485_uart/ddata_r
add wave -label tx_register -radix hex /generic_RS485_uart/tx_register
add wave -label rx_register -radix hex /generic_RS485_uart/rx_register
add wave -label from_rx -radix bin /generic_RS485_uart/rx_receive/from_rx
add wave -label baud_ready -radix bin /generic_RS485_uart/baud_ready
add wave -label byte_received -radix bin /generic_RS485_uart/byte_received
add wave -label byte_read -radix bin /generic_RS485_uart/byte_read
add wave -label tx_done /generic_RS485_uart/tx_done
add wave -label rx_done /generic_RS485_uart/rx_done
add wave -label cnt_tx /generic_RS485_uart/cnt_tx
add wave -label TX -radix hex /TX
add wave -label RX -radix hex /RX
add wave -label rx_state /generic_RS485_uart/state_rx
add wave -label state_tx /generic_RS485_uart/state_tx
add wave -label cnt_rx /generic_RS485_uart/cnt_rx
#add wave -label rx_out /generic_RS485_uart/rx_out
add wave -label DE_state /generic_RS485_uart/rs485_dir_DE
#add wave -label interrupts /generic_RS485_uart/interrupts
#add wave -label interrupts /generic_RS485_uart/interrupts
#add wave -label rx_cmp_irq /generic_RS485_uart/rx_cmp_irq


#add wave -height 6 -divider "BUFFER_UART"
#add wave -label buffer_rx -radix hex /generic_RS485_uart/buffer_rx
#add wave -label buffer_byte -radix hex /generic_RS485_uart/buffer_byte
#add wave -label cnt_rx_buffer -radix hex /generic_RS485_uart/cnt_rx_buffer
#add wave -label cnt_rx_irq -radix hex /generic_RS485_uart/rx_buffer_receive/cnt_rx_irq
#add wave -label buffer_mode -radix hex /generic_RS485_uart/buffer_mode
#add wave -label buffer_register -radix hex /generic_RS485_uart/buffer_register

add wave -height 15 -divider "Input/Output SIM"
#add wave -label LEDR -radix hex /LEDR
add wave -label HEX0 -radix hex /HEX0
add wave -label HEX1 -radix hex /HEX1

run 20 ms
#wave zoomfull
