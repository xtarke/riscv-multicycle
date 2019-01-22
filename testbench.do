#******************************************************************************
#                                                                             *
#                  Copyright (C) 2019 IFSC                                    *
#                                                                             *
#                                                                             *
# All information provided herein is provided on an "as is" basis,            *
# without warranty of any kind.                                               *
#                                                                             *
# File Name: testbench.do          						    				  *
#                                                                             *
# Function: riscv muticycle simulation script		  	                 	  *
#                                                                             *
# REVISION HISTORY:                                                           *
#  Revision 0.1.0    08/01/2018 - Initial Revision                            *
#******************************************************************************

vlib work
# vcom ./memory/imemory.vhd
vcom ./memory/imemory_load.vhd
vcom ./memory/dmemory.vhd
vcom ./alu/alu_types.vhd
vcom ./alu/alu.vhd
vcom ./decoder/decoder_types.vhd
vcom ./decoder/iregister.vhd
vcom ./decoder/decoder.vhd
vcom ./registers/register_file.vhd

vcom ./core/core.vhd
vcom ./core/testbench.vhd

vsim -t ns work.testbench

view wave
add wave -radix binary /clk
add wave -radix binary /rst
add wave -radix hex /iaddress
add wave -radix hex idata

add wave -radix hex -label pc /myRiscv/pc
add wave -radix hex -label jal_target /myRiscv/jal_target
add wave -radix hex -label jalr_target /myRiscv/jalr_target
add wave -label branch_cmp /myRiscv/branch_cmp

# iregister debug 
add wave -label opcode  /myRiscv/opcodes 
add wave -label rd /myRiscv/rd   
add wave -label rs1 /myRiscv/rs1
add wave -label rs2 /myRiscv/rs2
add wave -label imm_i /myRiscv/imm_i
add wave -label imm_s /myRiscv/imm_s 
add wave -label imm_b /myRiscv/imm_b
add wave -label imm_u /myRiscv/imm_u
add wave -label imm_j /myRiscv/imm_j

# register file debug
add wave -label registers -radix hex /myRiscv/registers/ram
add wave -label w_ena /myRiscv/rf_w_ena
add wave -label w_data /myRiscv/rw_data
add wave -label r1_data -radix hex /myRiscv/rs1_data
add wave -label r2_data -radix hex /myRiscv/rs2_data

# decoder debug
add wave -label states /myRiscv/decoder0/state

# alu debug
add wave -label aluData /myRiscv/alu_data
add wave -label aluOut /myRiscv/alu_out

# data memory debug 
add wave -label mState /dmem/state
add wave -label fsm_we /dmem/fsm_we
add wave -label fsm_data -radix hex /dmem/fsm_data
add wave -label ram_data -radix hex /dmem/ram_data


add wave -label d_we /myRiscv/d_we
add wave -label daddress -radix hex /myRiscv/daddress
add wave -label dmask /myRiscv/dmask
add wave -label dmemory  /myRiscv/dmemory

add wave -label SRAM -radix hex /dmem/ram_block


run 3100 ns

wave zoom full
