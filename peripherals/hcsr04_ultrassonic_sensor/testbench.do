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
vcom HCSR04.vhd
vcom ../disp7seg/display_dec.vhd
vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../memory/databusmux.vhd
vcom ../../memory/instructionbusmux.vhd
vcom ../../alu/alu_types.vhd
vcom ../../alu/alu.vhd
vcom ../../alu/m/M_types.vhd
vcom ../../alu/m/M.vhd
vcom ../../decoder/decoder_types.vhd
vcom ../../decoder/iregister.vhd
vcom ../../decoder/decoder.vhd
vcom ../../registers/register_file.vhd
vcom ../../core/core.vhd
vcom ../../core/txt_util.vhdl
vcom ../../core/trace_debug.vhd
vcom testbench.vhd
vsim -voptargs="+acc" -t ns work.coretestbench
#vsim -t ns work.coretestbench

view wave
add wave -radix binary 	-label clk /clk
add wave -radix binary 	-label rst /rst
add wave -height 15 -divider "Instruction Memory"
add wave -label iAddr -radix hex /address
add wave -label iWord -radix hex idata
add wave -label decoded -radix ASCII /debugString
# add wave /debugString
# add wave -radix hex /imem/RAM
# add wave -radix hex /q

add wave -height 15 -divider "PC and Ctrl Targers"
add wave -radix hex -label pc 			/myRiscv/pc
add wave -radix hex -label jal_target 	/myRiscv/jal_target
add wave -radix hex -label jalr_target 	/myRiscv/jalr_target
add wave -label branch_cmp 				/myRiscv/branch_cmp

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
 add wave -label w_data -radix hex	/myRiscv/rw_data
 add wave -label r1_data -radix hex /myRiscv/rs1_data
 add wave -label r2_data -radix hex /myRiscv/rs2_data

# decoder debug
add wave -label states /myRiscv/decoder0/state

add wave -height 15 -divider "Alu debug"
add wave -label aluData -radix hex /myRiscv/alu_data
add wave -label aluOut 	-radix hex /myRiscv/alu_out
add wave -label comp_lu -radix hex /myRiscv/alu_0/comp_lu

add wave -height 15 -divider "Data memory debug"
add wave -label daddr -radix hex /myRiscv/memAddrTypeSBlock/addr
add wave -label fsm_data -radix hex /dmem/fsm_data
add wave -label ram_data -radix hex /dmem/ram_data
add wave -label mState /dmem/state
add wave -label fsm_we /dmem/fsm_we
add wave -label ddata_r_mem -radix hex /dmem/q
add wave -label datamemory -radix hex /dmem/ram_block

add wave -height 15 -divider "Data bus"
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix hex 	/ddata_r
add wave -label ddata_w -radix hex 	/ddata_w
add wave -label dmask -radix bin /dmask
add wave -label dcsel 	/dcsel
add wave -label d_we 	/d_we
add wave -label d_rd 	/d_rd
add wave -label d_sig   /d_sig

add wave -height 15 -divider "GPIO"
add wave -label echo /gpio_input
add wave -label Trig /gpio_output

add wave -height 15 -divider "Input/Output SIM"
add wave -label ARDUINO_IO /ARDUINO_IO

add wave -height 15 -divider "HCSR04_inst"
add wave -label measure_ms -radix unsigned /HCSR04_inst/measure_ms
add wave -label state -radix unsigned /HCSR04_inst/state

run 1000000 ns
wave zoomfull