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
vcom ./decoder/iregister.vhd
vcom ./registers/register_file.vhd
vcom ./core/core.vhd
vcom ./core/testbench.vhd

vsim -t ns work.testbench

view wave
add wave -radix binary /clk
add wave -radix binary /rst
add wave  /iaddress
add wave -radix hex /q

# iregister debug 
add wave -label opcode  /myRiscv/opcode 
add wave -label funct3 /myRiscv/funct3 
add wave -label funct7 /myRiscv/funct7 
add wave -label rd /myRiscv/rd   
add wave -label rs1 /myRiscv/rs1
add wave -label rs2 /myRiscv/rs2
add wave -label imm_i /myRiscv/imm_i
add wave -label imm_s /myRiscv/imm_s 
add wave -label imm_b /myRiscv/imm_b
add wave -label imm_u /myRiscv/imm_u
add wave -label imm_j /myRiscv/imm_j

# register file debug
add wave -label w_ena /myRiscv/rf_w_ena
add wave -label w_data /myRiscv/rd_data
add wave -label r1_data /myRiscv/rs1_data
add wave -label r2_data /myRiscv/rs2_data



run 100 ns
