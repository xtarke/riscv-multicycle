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
# vcom ./memory/imemory_load.vhd
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
vcom ../../core/csr.vhd
vcom ../../core/core.vhd
vcom ../../core/txt_util.vhdl
vcom ../../core/trace_debug.vhd
vcom ../timer/Timer.vhd
vcom ../gpio/gpio.vhd
vcom ../gpio/led_displays.vhd
vcom ./i2c_master.vhd

# vcom ./uart/uart.vhd
# vcom ./vga/vga_controller.vhd ./vga/vga_buffer.vhd
# vcom ./sdram/sim/mti_pkg.vhd ./sdram/sim/mt48lc8m16a2.vhd ./sdram/sdram_controller.vhd 
vcom ./testbench.vhd

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

# add wave -height 15 -divider "Alu debug"
# add wave -label aluData /myRiscv/alu_data
#add wave -label aluOut 	/myRiscv/alu_out

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

add wave -height 15 -divider "Input/Output SIM"
add wave -label LEDR -radix hex /LEDR
add wave -label ARDUINO_IO -radix hex /ARDUINO_IO

add wave -radix binary /i2c_clk 
add wave -radix binary /i2c_rst 
add wave -radix binary /i2c_ena 
add wave -radix binary /i2c_rw 
add wave -radix binary /i2c_addr 
add wave -radix binary /i2c_data_w 
add wave -radix binary /i2c_ack_err 

run 950000 ns
